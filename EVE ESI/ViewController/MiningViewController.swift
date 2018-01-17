//
// Created by Tristan Pollard on 2017-12-18.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import NVActivityIndicatorView

class MiningViewController : UICharacterViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var miningTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Mining"
        self.startAnimating()

        self.character.loadMining(){
            self.miningTable.reloadData()
            self.stopAnimating()
        }

    }

}

extension MiningViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.character.miningLedger.summed.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "miningLedgerCell", for: indexPath)

        cell.imageView?.af_cancelImageRequest()
        cell.imageView?.image = nil

        let entry = self.character.miningLedger.summed[indexPath.row]

        let placeholder = UIImage(named: "alliancePlaceholder64")?.af_imageScaled(to: CGSize(width: 44, height: 44))
        let filter = ScaledToSizeFilter(size: CGSize(width: 44, height: 44))
        cell.imageView?.af_setImage(withURL: entry.imageURL(size: cell.imageView!.sizeForImage()), placeholderImage: placeholder, filter: filter)

        cell.textLabel?.text = entry.name
        cell.detailTextLabel?.text = String(entry.quantity)

        return cell
    }
}
