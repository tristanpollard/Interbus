//
// Created by Tristan Pollard on 2018-12-15.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import UIKit

class SelectedCharacterViewController: UIViewController {

    var character: EveCharacter!

    let options = ["Assets", "Clones", "Contacts", "Fleet", "Mail", "Journal", "Wallet"]
    var selectedOption: String?

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

        self.characterImage.fetchAndSetImage(eve: self.character.characterData!) {
        }
        if let corp = self.character.characterData?.corporation {
            self.corporationImage.fetchAndSetImage(eve: corp) {
            }
            self.corporationLabel.text = corp.name?.name
        }
        if let alliance = self.character.characterData?.alliance {
            self.allianceImage.fetchAndSetImage(eve: alliance) {
            }
            self.allianceLabel.text = alliance.name?.name
        }
    }

    func getSegueIdentifier() -> String? {
        guard let selected = self.selectedOption else {
            return nil
        }
        return "selectedCharacterTo\(selected)"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let journal = segue.destination as? WalletJournalViewController {
            journal.walletJournal = self.character.walletJournal
        }
    }
}

extension SelectedCharacterViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedOption = self.options[indexPath.row]
        self.performSegue(withIdentifier: "selectedCharacterTo\(self.selectedOption!)", sender: self)
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

        return cell
    }
}