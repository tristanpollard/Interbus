//
// Created by Tristan Pollard on 2018-12-30.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import UIKit

class KillAttackersViewController: UIViewController {

    @IBOutlet weak var attackerTable: UITableView!
    var attackers: [EveKillMailAttacker] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let corps = self.attackers.compactMap {
            $0.corporation
        }
        corps.fetchNames {
            self.attackerTable.reloadData()
        }
        let alliances = self.attackers.compactMap {
            $0.alliance
        }
        alliances.fetchNames {
            self.attackerTable.reloadData()
        }
    }
}

extension KillAttackersViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.attackers.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "attackerCell", for: indexPath) as! KillAttackerCell

        let attacker = self.attackers[indexPath.row]

        cell.characterName.text = attacker.name?.name
        cell.characterImage.image = nil
        cell.characterImage.roundImageWithBorder(color: .clear)
        cell.characterImage.fetchAndSetImage(eve: attacker)
        cell.shipImage.image = nil
        if let ship = attacker.ship {
            cell.shipImage.fetchAndSetImage(eve: ship)
            cell.shipName.text = ship.name?.name
        }
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        cell.damage.text = formatter.string(from: NSNumber(value: attacker.damage_done))

        cell.accessoryView = nil
        cell.characterCorporation.text = nil
        if let alliance = attacker.alliance?.name?.name {
            cell.characterCorporation.text = alliance
        } else if let corp = attacker.corporation?.name?.name {
            cell.characterCorporation.text = corp
        } else {
            let refreshIndicator = UIActivityIndicatorView(style: .gray)
            cell.accessoryView = refreshIndicator
            refreshIndicator.startAnimating()
        }

        return cell
    }
}

extension KillAttackersViewController: UITableViewDelegate {

}
