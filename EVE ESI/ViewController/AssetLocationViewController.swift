//
// Created by Tristan Pollard on 2017-12-18.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import AlamofireImage
import NVActivityIndicatorView

class AssetLocationViewController : UICharacterViewController, NVActivityIndicatorViewable{

    var locationId : Int64!
    @IBOutlet weak var assetTable: UITableView!

    var assets = [EveAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startAnimating()
        var loadingAssets = self.character.assets.assetsForLocation(location: locationId)
        loadingAssets.loadNames(){
            loadingAssets.sort(by: {$0.name < $1.name})
            self.assets = loadingAssets
            self.assetTable.reloadData()
            self.stopAnimating()
        }
    }
}

extension AssetLocationViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "assetCell", for: indexPath)

        let asset = self.assets[indexPath.row]

        cell.imageView?.af_cancelImageRequest()
        cell.imageView?.image = nil

        let placeholder = UIImage(named: "alliancePlaceholder64")!.af_imageScaled(to: CGSize(width: 44, height: 44))
        let filter = ScaledToSizeFilter(size: CGSize(width: 44, height: 44))
        cell.imageView?.af_setImage(withURL: asset.imageURL(size: cell.imageView!.sizeForImage()), placeholderImage: placeholder, filter: filter)

        cell.textLabel?.text = asset.name
        cell.detailTextLabel?.text = String(asset.quantity)

        return cell
    }
}
