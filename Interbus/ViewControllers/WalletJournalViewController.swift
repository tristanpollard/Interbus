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
//        let entry = self.walletJournal.entries[indexPath.row]
//        print(entry.description, entry.first_party_id, entry.second_party_id)
    }
}

extension WalletJournalViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.walletJournal.entries.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "journalCell", for: indexPath) as! WalletJournalCell
        let journalEntry = self.walletJournal.entries[indexPath.row]

        cell.partyLabel.text = self.walletJournal.character.name?.name
        if let firstParty = journalEntry.first_party {
            if firstParty.id != self.walletJournal.character.id {
                cell.partyLabel.text = firstParty.name?.name
            }
        }
        if let secondParty = journalEntry.second_party {
            if secondParty.id != self.walletJournal.character.id {
                cell.partyLabel.text = secondParty.name?.name
            }
        }

        cell.amountLabel.textColor = .darkText
        if let amt = journalEntry.amount {
            let formatter = NumberFormatter()
            formatter.groupingSeparator = ","
            formatter.numberStyle = .decimal
            cell.amountLabel.text = formatter.string(from: NSNumber(value: amt))
            if amt > 0 {
                cell.amountLabel.textColor = UIColor(red: 0.00, green: 0.75, blue: 0.13, alpha: 1.0)
            } else if amt < 0 {
                cell.amountLabel.textColor = .red
            }
        } else {
            cell.amountLabel.text = nil
        }

        if let ref = journalEntry.ref_type {
            cell.refLabel.text = ref.replacingOccurrences(of: "_", with: " ").capitalized
        } else {
            cell.refLabel.text = nil
        }

        var imageParty = journalEntry.first_party
        if let party = imageParty, party.id == self.walletJournal.character.id {
            imageParty = journalEntry.second_party
        } else if imageParty == nil {
            imageParty = journalEntry.second_party
        }

        cell.partyImage.image = UIImage(named: "characterPlaceholder64.jpg")
        cell.partyImage.roundImageWithBorder(color: .clear)
        if let party = imageParty {
            cell.partyImage.fetchAndSetImage(eve: party)
        }

        return cell
    }
}