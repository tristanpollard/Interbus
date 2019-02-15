//
// Created by Tristan Pollard on 2018-12-29.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import UIKit

class FleetCompositionViewController: UIFleetController {
    @IBOutlet weak var fleetCompositionTable: UITableView!

    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer = Timer.scheduledTimer(timeInterval: 30, target: fleet, selector: #selector(Fleet.refreshFleet), userInfo: nil, repeats: true)
        fleet.refreshFleet() {
            self.fleetCompositionTable.reloadData()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
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