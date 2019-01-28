//
// Created by Tristan Pollard on 2018-12-27.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController {

    var contacts: EveContacts!
    @IBOutlet weak var contactsTable: UITableView!
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.contactsTable.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: #selector(self.sort), for: .valueChanged)
        self.load()
    }

    @objc
    func sort() {
        self.contacts.sort()
    }

    @objc
    func load() {
        refreshControl.beginRefreshing()
        self.contacts.fetchContactsAndLabels {
            self.contactsTable.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
}

extension ContactsViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.contacts.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)

        let contact = self.contacts.contacts[indexPath.row]
        cell.textLabel?.text = contact.name?.name
        cell.imageView?.image = nil
        cell.imageView?.roundImageWithBorder(color: .clear)
        cell.imageView?.fetchAndSetImage(eve: contact)

        var bgColor: UIColor = .white
        if contact.standing > 5.0 {
            bgColor = .blue
        } else if contact.standing > 0.0 {
            bgColor = UIColor(red: 0.32, green: 0.58, blue: 0.96, alpha: 1.0)
        } else if contact.standing < -5.0 {
            bgColor = .red
        } else if contact.standing < 0.0 {
            bgColor = .orange
        }
        cell.backgroundColor = bgColor

        return cell
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contact = self.contacts.contacts[indexPath.row]
            self.contacts.removeContact(contact: contact) {
                self.contactsTable.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

extension ContactsViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let contact = self.contacts.contacts[indexPath.row].name
    }
}
