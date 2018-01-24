//
// Created by Tristan Pollard on 2018-01-24.
// Copyright (c) 2018 Sumo. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class KillsViewController : UICharacterViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var killsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.startAnimating()
        self.character.loadKills(){
            self.stopAnimating()
            self.killsTableView.reloadData()
        }

    }

}


extension KillsViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.character.kills.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "killsCell", for: indexPath)

        cell.textLabel?.text = String(self.character.kills[indexPath.row].killmail_id!)


        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let kill = self.character.kills[indexPath.row]

        debugPrint(kill.killmail_id, kill.victim, kill.attackers)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}