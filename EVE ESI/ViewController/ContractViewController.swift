//
// Created by Tristan Pollard on 2017-10-08.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import AlamofireImage
import NVActivityIndicatorView

class ContractViewController : UICharacterViewController, NVActivityIndicatorViewable{

    @IBOutlet weak var contractLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var contract : EveContract!

    override func viewDidLoad() {

        self.startAnimating()

        let group = DispatchGroup()

        group.enter()
        self.character.loadContractItems(contract: self.contract){ response, contract in
            self.tableView.reloadData()
            group.leave()
        }

        group.enter()
        self.contract.loadAssigneeIssuer(){
            group.leave()
        }

        group.notify(queue: .main){
            self.stopAnimating()
        }

    }

}

extension ContractViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contract.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contractCell", for: indexPath)

        let item = self.contract.items[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = String(item.quantity!)

        cell.imageView?.af_cancelImageRequest()
        cell.imageView?.image = nil

        let filter = ScaledToSizeFilter(size: CGSize(width: 43, height: 43))
        let placeholder = UIImage(named: "characterPlaceholder64.jpg")!.af_imageScaled(to: CGSize(width: 43, height: 43))
        cell.imageView?.af_setImage(withURL: item.urlForItem(), placeholderImage: placeholder, filter: filter)

        return cell
    }
}