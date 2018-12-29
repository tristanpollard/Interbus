//
// Created by Tristan Pollard on 2018-12-26.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {

    var notifications: EveNotifications!
    @IBOutlet weak var notificationTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.notifications.fetchNotifications {
            self.notificationTable.reloadData()
        }
    }
}


extension NotificationsViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension NotificationsViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifications.notifications.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath)

        let item = self.notifications.notifications[indexPath.row]
        cell.textLabel?.text = item.text
        cell.detailTextLabel?.text = item.type

        return cell
    }
}
