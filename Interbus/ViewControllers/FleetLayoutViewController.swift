//
// Created by Tristan Pollard on 2018-12-29.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import UIKit

class FleetLayoutViewController: UIFleetController {
    @IBOutlet weak var fleetLayoutTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension FleetLayoutViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "layoutCell", for: indexPath)

        return cell
    }
}

extension FleetLayoutViewController: UITableViewDelegate {

}