//
// Created by Tristan Pollard on 2017-12-18.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import AlamofireImage

class AssetsViewController : UICharacterViewController, NVActivityIndicatorViewable{

    @IBOutlet weak var assetTable: UITableView!

    var names = [Int64:String]()

    var sortedLabels = [String]()

    var collapsed = [Int64:Bool]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.assetTable.sectionHeaderHeight = AssetHeaderView.height
        self.assetTable.register(UINib(nibName: "AssetHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "AssetHeader")

        self.startAnimating()

        let group = DispatchGroup()

        self.character.loadAssets{

            var assets = self.character.assets.assetList

            var stations = assets.filter{ $0.location_type == "station" }
            var citadels = assets.filter{ $0.location_type == "other" && $0.location_flag.lowercased() == "hangar"}

            var stationIds : [Int64] = Set(stations.map({$0.location_id})).map{$0}
            var citadelIds : [Int64] = Set(citadels.map({$0.location_id})).map{$0}

            group.enter()
            stationIds.loadNames{ names in
                for n in names{
                    self.names[n.key] = n.value
                }
                group.leave()
            }

            let esi = ESIClient.sharedInstance

            for id in citadelIds{

                group.enter()
                let structure = EveStructure(id)
                structure.loadStructure(token: self.character.token!){
                    self.names[structure.structure_id] = structure.name
                    group.leave()
                }

            }

            group.notify(queue: .main){

                for key in self.names.keys{
                    self.collapsed[key] = true
                }

                self.sortedLabels = self.names.map{$0.value}.sorted{$0 < $1}
                self.assetTable.reloadData()
                self.stopAnimating()
            }
        }


    }

    func locationForSection(_ section : Int) -> Int64{

        let location = self.names.first{$0.value == self.sortedLabels[section]}!.key
        return location

    }

}

extension AssetsViewController : UITableViewDataSource, UITableViewDelegate{

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.names.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let location = self.names.first(where: {$0.value == self.sortedLabels[section]})!.key

        if collapsed[location] == true{
            return 0
        }

        return self.character.assets.assetList.filter{$0.location_id == location}.count
    }


    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AssetHeader") as? AssetHeaderView{

            let name = self.sortedLabels[section]
            header.headerLabel.text = name
            header.location = self.names.first{$0.value == name}!.key
            header.delegate = self
            header.selectedLabel.transform = CGAffineTransform(rotationAngle: (self.collapsed[locationForSection(section)]! ? 0 : .pi))
            header.backgroundView = UIView(frame: header.bounds)
            header.backgroundView!.backgroundColor = .white

            return header

        }

        return nil

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "assetCell", for: indexPath)

        cell.imageView?.af_cancelImageRequest()
        cell.imageView?.image = nil

        let location = self.names.first(where: {$0.value == self.sortedLabels[indexPath.section]})!.key
        let assetsInLocation = self.character.assets.assetList.filter{$0.location_id == location}.sorted(by: {$0.name < $1.name})
        let asset = assetsInLocation[indexPath.row]

        let placeHolder = UIImage(named: "alliancePlaceholder64")!.af_imageScaled(to: CGSize(width: 43, height: 43)).af_imageRoundedIntoCircle()

        let filter = ScaledToSizeFilter(size: CGSize(width: 43, height: 43))

        cell.imageView?.af_setImage(withURL: asset.imageURL(), placeholderImage: placeHolder, filter: filter)

        cell.textLabel?.text = asset.name
        cell.detailTextLabel?.text = String(asset.quantity)

        if asset.childrenAssets.count > 0{
            cell.accessoryType = .disclosureIndicator
        }else{
            cell.accessoryType = .none
        }

         return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let location = self.names.first(where: {$0.value == self.sortedLabels[indexPath.section]})!.key
        let assetsInLocation = self.character.assets.assetList.filter{$0.location_id == location}
        let asset = assetsInLocation[indexPath.row]

        for child in asset.childrenAssets{
            debugPrint(child.name)
        }

        tableView.deselectRow(at: indexPath, animated: true)

    }
}

extension AssetsViewController : AssetHeaderViewDelegate {

    func locationToggled(header: AssetHeaderView, location: Int64) {
        self.collapsed[location] = !self.collapsed[location]!

        header.rotateSelectedLabel(isShowing: self.collapsed[location]!) {
            self.assetTable.reloadSections([self.sortedLabels.index(of: self.names[location]!)!], with: .fade)
        }

    }

}