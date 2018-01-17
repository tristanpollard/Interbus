//
// Created by Tristan Pollard on 2017-10-11.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SkillQueueViewController : UICharacterViewController, NVActivityIndicatorViewable{

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.startAnimating()

        self.character.loadSkillQueue(){
            self.tableView.reloadData()
            self.stopAnimating()
        }

    }

}

extension SkillQueueViewController : UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.character.skillQueue.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "skillQueueCell", for: indexPath)

        let skillQueue = self.character.skillQueue[indexPath.row]
        cell.textLabel?.text = skillQueue.name
        cell.detailTextLabel?.text = "\(skillQueue.finished_level! - 1) -> \(skillQueue.finished_level!)"

        return cell
    }
}
