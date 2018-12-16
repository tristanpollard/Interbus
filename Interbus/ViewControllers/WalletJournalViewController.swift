//
// Created by Tristan Pollard on 2018-12-16.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import UIKit

class WalletJournalViewController: UIViewController {
    var walletJournal: EveWalletJournal!
    let refreshIndicator = UIRefreshControl()

    @IBOutlet weak var journalTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshIndicator.addTarget(self, action: #selector(fetchJournalData), for: .valueChanged)
        self.journalTable.refreshControl = refreshIndicator
        self.fetchJournalData()
    }

    @objc
    func fetchJournalData() {
        self.refreshIndicator.beginRefreshing()
        self.walletJournal.fetchJournalEntries {
            self.refreshIndicator.endRefreshing()
            self.journalTable.reloadData()
        }
    }

    func fetchJournalNames(completion: @escaping () -> ()) {

    }
}


extension WalletJournalViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let entry = self.walletJournal.entries[indexPath.row]
        print(entry.description, entry.first_party_id, entry.second_party_id)
    }
}

extension WalletJournalViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.walletJournal.entries.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "journalCell", for: indexPath)
        let journalEntry = self.walletJournal.entries[indexPath.row]

        var parties: [String] = []
        if let firstParty = journalEntry.first_party?.name?.name {
            parties.append(firstParty)
        }
        if let secondParty = journalEntry.second_party?.name?.name {
            parties.append(secondParty)
        }
        if parties.count > 0 {
            cell.textLabel?.text = parties.joined(separator: " -> ")
        } else {
            cell.textLabel?.text = "Concord"
        }

        var imageParty = journalEntry.first_party
        if let party = imageParty, party.id == self.walletJournal.character.id {
            imageParty = journalEntry.second_party
        } else if imageParty == nil {
            imageParty = journalEntry.second_party
        }

        cell.imageView?.image = UIImage(named: "characterPlaceholder64.jpg")
        cell.imageView?.roundImageWithBorder(color: .clear)
        if let party = imageParty {
            cell.imageView?.fetchAndSetImage(eve: party) {
            }
        }

        if let amount = journalEntry.amount {
            cell.detailTextLabel?.text = String(amount)
        } else {
            cell.detailTextLabel?.text = nil
        }

        return cell
    }
}