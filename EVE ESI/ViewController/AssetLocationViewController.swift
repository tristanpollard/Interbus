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

        self.stopAnimating()
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


        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {


        self.assetTable.deselectRow(at: indexPath, animated: true)

    }
}
