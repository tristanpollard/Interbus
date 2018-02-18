//
// Created by Tristan Pollard on 2017-10-08.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import AlamofireImage
import NVActivityIndicatorView

class ContractListViewController : UICharacterViewController, NVActivityIndicatorViewable{

    @IBOutlet weak var tableView: UITableView!

    var selectedContract : EveContract?

    override func viewDidLoad() {

        self.title = "Contracts"

        self.startAnimating()

        self.character.loadContracts(){

            let issuers : [EvePlayerOwned] = self.character.contracts.map({$0.issuer!})
            let assignees : [EvePlayerOwned] = self.character.contracts.map({$0.assignee!})
            let toFetch = issuers + assignees

            toFetch.loadNames(){
                self.tableView.reloadData()
                self.stopAnimating()
            }

            self.tableView.reloadData()
        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "contractListToContract"{
            if let vc = segue.destination as? ContractViewController{
                vc.character = self.character
                vc.contract = self.selectedContract
            }
        }
    }
}

extension ContractListViewController : UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.character.contracts.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contractCell", for: indexPath) as! ContractHeaderCell
        let contract = self.character.contracts[indexPath.row]

        cell.contractTypeLabel.text = contract.type!.lowerToUpper()
        cell.contractIssuerLabel.text = "Unknown"
        cell.contractStatusLabel.text = "Unknown"
        cell.contractImage.af_cancelImageRequest()
        cell.contractImage.image = nil

        if let issuer = contract.issuer, let assignee = contract.assignee{
            let placeHolder = UIImage(named: "characterPlaceholder64.jpg")!.af_imageRoundedIntoCircle().af_imageScaled(to: CGSize(width: 43, height: 43))
            let filter = ScaledToSizeCircleFilter(size: CGSize(width: 43, height: 43))

            if issuer.id == self.character.id{
                cell.contractImage.af_setImage(withURL: assignee.imageURL(size: cell.contractImage.sizeForImage()), placeholderImage: placeHolder, filter: filter)
            }else{
                cell.contractImage.af_setImage(withURL: issuer.imageURL(size: cell.contractImage.sizeForImage()), placeholderImage: placeHolder, filter: filter)
            }

            cell.contractIssuerLabel.text = "\(issuer.name) -> \(assignee.name)"

            if let status = contract.status{
                cell.contractStatusLabel.text = status.lowerToUpper()
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedContract = self.character.contracts[indexPath.row]
        self.tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "contractListToContract", sender: self)
    }
}
