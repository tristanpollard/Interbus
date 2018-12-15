//
//  CharacterSelectorViewController.swift
//  Interbus
//
//  Created by Tristan Pollard on 2018-12-13.
//  Copyright © 2018 Tristan Pollard. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class CharacterSelectorViewController: UIViewController {

    @IBOutlet weak var tokenTableView: UITableView!
    var characters: [EveCharacter] = []
    var selectedCharacter: EveCharacter?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Characters"
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonTapped))
        ];

        let tokens = SSOToken.loadAllTokens()
        self.characters = tokens.map { token in
            return EveCharacter(token: token)
        }

        self.characters.fetchAllCharacterData {
            self.characters.map({ $0.characterData! }).fetchCorpsAndAlliances {
                self.tokenTableView.reloadData()
            }
        }

        self.characters.fetchAllCharacterLocationOnline {
            self.tokenTableView.reloadData()
        }
    }

    @objc
    func addBarButtonTapped() {
        let verifier = String.verifier()
        ESIClient.sharedInstance.setLastCodeChallenge(challenge: verifier)
        let url = ESIClient.getESIUrl(codeChallenge: verifier)
        UIApplication.shared.open(URL(string: url)!)
    }

    func didReceiveToken(token: SSOToken) {
        let char = EveCharacter(token: token)
        self.characters = self.characters.filter({ $0.id != char.id })
        self.characters.append(char)
        self.tokenTableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SelectedCharacterViewController {
            if let character = self.selectedCharacter {
                vc.character = character
            }
        }
    }
}


extension CharacterSelectorViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TokenCell", for: indexPath) as! TokenTableViewCell
        cell.characterImage.image = UIImage(named: "characterPlaceholder64.jpg")

        let character = self.characters[indexPath.row]

        var color = UIColor.red
        if let online = character.locationOnline?.online, online {
            color = UIColor.green
        }
        cell.characterImage.roundImageWithBorder(color: color)

        cell.characterName.text = character.name

        cell.characterImage.fetchAndSetImage(eve: character.characterData!) {
        }

        var corpAllianceData: [String] = []
        if let corp = character.characterData?.corporation?.name {
            corpAllianceData.append(corp)
            if let alliance = character.characterData?.alliance?.name {
                corpAllianceData.append(alliance)
            }
        }
        cell.corpAllianceLabel.text = corpAllianceData.joined(separator: " - ")

        if !character.token!.hasAllScopes() {
            cell.accessoryType = .detailButton
        } else {
            if let _ = character.characterData?.corporation {
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.accessoryType = .none
            }
        }

        return cell
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.characters.count
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension CharacterSelectorViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let character = self.characters[indexPath.row]
        self.selectedCharacter = character
        if let _ = character.characterData?.corporation {
            self.performSegue(withIdentifier: "characterSelectorToSelected", sender: self)
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.characters[indexPath.row].token!.deleteToken()
            self.characters.remove(at: indexPath.row)
            self.tokenTableView.reloadData()
        }
    }
}
