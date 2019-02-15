import UIKit

class SelectedCharacterViewController: UIViewController {

    var character: EveCharacter!
    var fetchingFleet: Bool = false

    let options = ["Assets", "Clones", "Contacts", "Fleet", "Kills", "Mail", "Market", "Journal", /*"Notifications", "Wallet"*/]

    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var corporationImage: UIImageView!
    @IBOutlet weak var allianceImage: UIImageView!
    @IBOutlet weak var corporationLabel: UILabel!
    @IBOutlet weak var allianceLabel: UILabel!
    @IBOutlet weak var navigationTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.character.name?.name

        var characterBorderColor: UIColor = .red
        if let online = self.character.locationOnline?.online, online {
            characterBorderColor = .green
        }
        self.characterImage.roundImageWithBorder(color: characterBorderColor)
        self.corporationImage.roundImageWithBorder(color: .clear)

        self.characterImage.fetchAndSetImage(eve: self.character.characterData!)
        if let corp = self.character.characterData?.corporation {
            self.corporationImage.fetchAndSetImage(eve: corp) {
            }
            self.corporationLabel.text = corp.name?.name
        }
        if let alliance = self.character.characterData?.alliance {
            self.allianceImage.fetchAndSetImage(eve: alliance)
            self.allianceLabel.text = alliance.name?.name
        }

        self.fetchFleet()
    }

    func fetchFleet() {
        self.fetchingFleet = true
        self.reloadFleetCell()
        self.character.fetchFleet { fleet in
            self.fetchingFleet = false
            self.reloadFleetCell()
        }
    }

    func reloadFleetCell() {
        let fleetIndex = self.options.firstIndex(of: "Fleet")!
        let indexPath = IndexPath(row: fleetIndex, section: 0)
        self.navigationTableView.reloadRows(at: [indexPath], with: .automatic)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let journal = segue.destination as? WalletJournalViewController {
            journal.walletJournal = self.character.walletJournal
        } else if let mail = segue.destination as? MailViewController {
            mail.mail = self.character.mail
        } else if let notifications = segue.destination as? NotificationsViewController {
            notifications.notifications = self.character.notifications
        } else if let contacts = segue.destination as? ContactsViewController {
            contacts.contacts = self.character.contacts
        } else if let assets = segue.destination as? AssetsViewController {
            assets.assets = self.character.assets
        } else if let fleet = segue.destination as? FleetViewController {
            if let fleetViewControllers = fleet.viewControllers {
                for fleetVC in fleetViewControllers {
                    if let uiFleetController = fleetVC as? UIFleetController {
                        uiFleetController.fleet = self.character.fleet!
                    }
                }
            }
        } else if let kills = segue.destination as? KillsViewController {
            kills.kills = self.character.kills
        } else if let clones = segue.destination as? JumpCloneViewController {
            clones.clones = self.character.clones
        }
    }
}

extension SelectedCharacterViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedOption = self.options[indexPath.row].replacingOccurrences(of: " ", with: "")
        if selectedOption == "Fleet" && self.character.fleet == nil {
            self.fetchFleet()
            return
        }
        self.performSegue(withIdentifier: "selectedCharacterTo\(selectedOption)", sender: self)
    }
}

extension SelectedCharacterViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "navigationOptionCell", for: indexPath)

        cell.textLabel?.text = options[indexPath.row]
        cell.accessoryView = nil
        cell.accessoryType = .disclosureIndicator

        if cell.textLabel?.text == "Fleet" {
            if self.fetchingFleet {
                let indicator = UIActivityIndicatorView(style: .gray)
                cell.accessoryView = indicator
                indicator.startAnimating()
            } else if self.character.fleet == nil {
                cell.accessoryType = .none
            }
        }

        return cell
    }
}