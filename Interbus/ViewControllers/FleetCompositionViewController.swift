//
// Created by Tristan Pollard on 2018-12-29.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import UIKit

class FleetCompositionViewController: UIFleetController {
    @IBOutlet weak var fleetCompositionTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension FleetCompositionViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "compositionCell", for: indexPath)

        return cell
    }
}

extension FleetCompositionViewController: UITableViewDelegate {

}