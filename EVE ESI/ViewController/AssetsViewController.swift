//
// Created by Tristan Pollard on 2017-12-18.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class AssetsViewController : UICharacterViewController, NVActivityIndicatorViewable{

    @IBOutlet weak var assetTable: UITableView!

    var selectedLocation : Int64 = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.startAnimating()
        self.character.loadAssets(){
            self.character.assets.loadLocations(){
                self.assetTable.reloadData()
                self.stopAnimating()
            }
        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch segue.identifier as! String{
            case "assetsToAssetLocation":
                if let vc = segue.destination as? AssetLocationViewController{
                    vc.character = self.character
                    vc.locationId = self.selectedLocation
                }
            default:
                break
        }
    }
}

extension AssetsViewController : UITableViewDataSource, UITableViewDelegate{

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.character.assets.assetLocations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "assetCell", for: indexPath)

        let location = self.character.assets.assetLocations.values.sorted(by: {$0 < $1})[indexPath.row]

        cell.textLabel?.text = location

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let locationName = self.character.assets.assetLocations.values.sorted(by: {$0 < $1})[indexPath.row]
        let locationId = self.character.assets.assetLocations.first(where: {$0.value == locationName})!.key

        self.selectedLocation = locationId

        self.performSegue(withIdentifier: "assetsToAssetLocation", sender: self)

        tableView.deselectRow(at: indexPath, animated: true)

    }
}
