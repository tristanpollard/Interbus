//
// Created by Tristan Pollard on 2017-12-18.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class StatsViewController : UICharacterViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var statsTable: UITableView!
    var selectedYear : Int64!

    public override func viewDidLoad() {

        super.viewDidLoad()
        self.title = "Stats"
        self.startAnimating()

        self.character.loadStats(){
            self.statsTable.reloadData()
            self.stopAnimating()
        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let vc = segue.destination as? StatsYearViewController{
            vc.character = self.character
            vc.year = self.selectedYear
        }
    }
}

extension StatsViewController : UITableViewDataSource, UITableViewDelegate{

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.character.stats.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statsCell", for: indexPath)

        if let year = self.character.stats[indexPath.row]["year"] as? Int64{
            cell.textLabel?.text = String(year)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let year = self.character.stats[indexPath.row]["year"] as? Int64{
            selectedYear = year
            self.performSegue(withIdentifier: "statsToYearStats", sender: self)
        }

    }

}
