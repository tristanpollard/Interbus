//
// Created by Tristan Pollard on 2018-12-16.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import UIKit

class MailViewController: UIViewController {

    var mail: EveMail!
    var refreshControl = UIRefreshControl()
    var lastSelected: IndexPath?

    @IBOutlet weak var mailTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(segueNewMail))
        ]

        self.mailTable.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: #selector(fetchNewMail), for: .valueChanged)

        self.fetchAllMail()
    }

    @objc
    func segueNewMail() {
        self.performSegue(withIdentifier: "mailToComposeMail", sender: self)
    }

    @objc
    func fetchNewMail() {
        self.refreshControl.beginRefreshing()
        self.mail.fetchNewMail {
            self.mailTable.reloadData()
            self.refreshControl.endRefreshing()
        }
    }

    @objc
    func fetchAllMail() {
        let group = DispatchGroup()
        self.refreshControl.beginRefreshing()

        group.enter()
        self.mail.fetchNextPageMail { success in
            group.leave()
        }

        group.enter()
        self.mail.fetchMailLabels {
            group.leave()
        }

        group.notify(queue: .main) {
            self.mailTable.reloadData()
            self.refreshControl.endRefreshing()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let send = segue.destination as? SendMailViewController {
            send.mail = self.mail
        }
        if let item = segue.destination as? MailItemViewController, let last = self.lastSelected {
            item.mail = self.mail
            item.mailItem = self.mail.mail[last.row]
            item.didDeleteMail = {
                self.mailTable.deleteRows(at: [last], with: .automatic)
            }
        }
    }
}

extension MailViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.lastSelected = indexPath
        self.performSegue(withIdentifier: "mailToMailItem", sender: self)
    }
}

extension MailViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mail.mail.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mailCell", for: indexPath)

        let mail = self.mail.mail[indexPath.row]

        cell.textLabel?.text = mail.subject

        cell.imageView?.image = UIImage(named: "characterPlaceholder64.jpg")
        cell.imageView?.roundImageWithBorder(color: .clear)
        if let sender = mail.sender {
            cell.imageView?.fetchAndSetImage(eve: sender)
        }

        cell.detailTextLabel?.text = nil
        if let recipients = mail.recipients {
            let recipientNames: [String] = recipients.flatMap({ $0.name?.name })
            cell.detailTextLabel?.text = recipientNames.joined(separator: ", ")
        }

        return cell
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let mail = self.mail.mail[indexPath.row]
            self.refreshControl.beginRefreshing()
            mail.deleteMail { deleted in
                if deleted {
                    self.mailTable.deleteRows(at: [indexPath], with: .automatic)
                }
                self.refreshControl.endRefreshing()
            }
        }
    }
}

extension MailViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {

        guard self.mail.isFetching == false else {
            return
        }

        let baseCount = self.mail.mail.count - 1
        for path in indexPaths {
            if path.row >= baseCount {
                self.mail.fetchNextPageMail { success in
                    if success {
                        self.mailTable.reloadData()
                    }
                }
                return
            }
        }
    }
}
