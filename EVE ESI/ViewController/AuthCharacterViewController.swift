//
// Created by Tristan Pollard on 2017-10-01.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import NVActivityIndicatorView

class AuthCharacterViewController : UICharacterViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var corporationImage: UIImageView!
    @IBOutlet weak var allianceImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!

    var options = ["Assets", "Clones", "Contacts", "Contracts", "Fleet", "Journal", "Kills", "Mail", "Mining", "Orders", "Skills", "Skill Queue", "Transactions"/*"Stats"*/]

    func updateOnline(){
        self.character.isOnline(){ online in
            if online{
                self.characterImage.borderCircle(color: UIColor.green)
            } else {
                self.characterImage.borderCircle(color: UIColor.red)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let group = DispatchGroup()

        self.startAnimating()
        self.view.layoutIfNeeded()

        let circleFilter = CircleFilter()
        let characterPlaceholder = UIImage(named: "characterPlaceholder256.jpg")?.af_imageRoundedIntoCircle()

        self.characterImage.af_setImage(withURL: self.character.imageURL(size: self.characterImage.sizeForImage()), placeholderImage: characterPlaceholder, filter: circleFilter) { response in
            self.updateOnline()
        }

        group.enter()
        self.character.load(){
            let corporationPlaceholder = UIImage(named: "corporationPlaceholder128.png")
            self.corporationImage.af_setImage(withURL: self.character!.corporation!.imageURL(size: self.corporationImage.sizeForImage()), placeholderImage: corporationPlaceholder)

            if let all_id = self.character.alliance_id{
                let alliancePlaceholder = UIImage(named: "alliancePlaceholder128.png")
                self.allianceImage.af_setImage(withURL: EveAlliance.imageURL(alliance_id: all_id, size: self.allianceImage.sizeForImage()), placeholderImage: alliancePlaceholder)
            }

            group.leave()

        }


        //TODO can we solve a character not having anything elegantly?
        /*group.enter()
        self.character.loadMining{
            if self.character.miningLedger.entries.count == 0{
                self.options.remove(at: self.options.index(of: "Mining")!)
            }
            group.leave()
        }

        group.enter()
        self.character.loadClones{
            if self.character.clones.count == 0{
                self.options.remove(at: self.options.index(of: "Clones")!)
            }
            group.leave()
        }

        group.enter()
        self.character.loadKills{
            if self.character.kills.count == 0{
                self.options.remove(at: self.options.index(of: "Kills")!)
            }
            group.leave()
        }

        group.enter()
        self.character.loadContracts{
            if self.character.contacts.count == 0{
                self.options.remove(at: self.options.index(of: "Contracts")!)
            }
            group.leave()
        }

        group.enter()
        self.character.loadMarketOrders{
            if self.character.orders.count == 0{
                self.options.remove(at: self.options.index(of: "Orders")!)
            }
            group.leave()
        }

        group.enter()
        self.character.loadTransactions{
            if self.character.transactions.count == 0{
                self.options.remove(at: self.options.index(of: "Transactions")!)
            }
            group.leave()
        }*/

        group.enter()
        self.character.loadLocation{
            group.leave()
        }

        group.enter()
        self.character.loadShip{
            group.leave()
        }

        group.notify(queue: .main){
            self.tableView.reloadData()
            self.stopAnimating()
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

       // self.updateOnline()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let vc = segue.destination as? UICharacterViewController {
            vc.character = self.character
        }else if let tabViews = segue.destination as? UITabBarController, let controllers = tabViews.viewControllers{
            for view in controllers{
                if let vc = view as? UICharacterViewController{
                    vc.character = self.character
                }
            }
        }

    }

}

extension AuthCharacterViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)

        cell.textLabel?.text = options[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "authCharacterTo\(options[indexPath.row].components(separatedBy: " ").joined())", sender: self)
    }
}