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

        self.title = self.character.name

        self.characterImage.roundImageWithBorder(color: .clear)
        self.corporationImage.roundImageWithBorder(color: .clear)

        self.characterImage.fetchAndSetImage(eve: self.character.characterData!) {
        }
        if let corp = self.character.characterData?.corporation {
            self.corporationImage.fetchAndSetImage(eve: corp) {
            }
            self.corporationLabel.text = corp.name
        }
        if let alliance = self.character.characterData?.alliance {
            self.allianceImage.fetchAndSetImage(eve: alliance) {
            }
            self.allianceLabel.text = alliance.name
        }
    }

    func getSegueIdentifier() -> String? {
        guard let selected = self.selectedOption else {
            return nil
        }
        return "selectedCharacterTo\(selected)"
    }
}

extension SelectedCharacterViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedOption = self.options[indexPath.row]
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