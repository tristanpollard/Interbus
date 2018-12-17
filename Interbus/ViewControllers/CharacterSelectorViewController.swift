//
//  CharacterSelectorViewController.swift
//  Interbus
//
//  Created by Tristan Pollard on 2018-12-13.
//  Copyright © 2018 Tristan Pollard. All rights reserved.
//

import UIKit

class CharacterSelectorViewController: UIViewController {

    @IBOutlet weak var tokenTableView: UITableView!
    var characters: [EveCharacter] = []
    var selectedCharacter: EveCharacter?
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Characters"
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonTapped))
        ];

        refreshControl.addTarget(self, action: #selector(refreshAllCharacters), for: .valueChanged)
        self.tokenTableView.refreshControl = self.refreshControl

        let tokens = SSOToken.loadAllTokens()
        self.characters = tokens.map { token in
            return EveCharacter(token: token)
        }
        self.refreshAllCharacters()
    }

    @objc
    func refreshAllCharacters() {

        self.characters.sort {
            $0.character_name < $1.character_name
        }

        self.characters.refreshTokens {
            for (idx, character) in self.characters.enumerated() {
                let group = DispatchGroup()

                group.enter()
                character.fetchLocationOnline { online in
                    group.leave()
                }

                group.enter()
                character.fetchLocationShip { ship in
                    group.leave()
                }

                group.enter()
                character.fetchLocationSystem { system in
                    group.leave()
                }

                group.enter()
                character.characterData.fetchCharacterCorpAllianceData {
                    group.leave()
                }

                group.notify(queue: .main) {
                    let indexPath = IndexPath(row: idx, section: 0)
                    self.tokenTableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
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
        self.characters = self.characters.filter {
            $0.id != char.id
        }
        self.characters.append(char)
        self.characters.sort {
            $0.character_name < $1.character_name
        }
        self.tokenTableView.reloadData()
        char.characterData?.fetchCharacterCorpAllianceData {
            let group = DispatchGroup()

            group.enter()
            char.fetchLocationOnline { online in
                group.leave()
            }

            group.enter()
            char.fetchLocationShip { ship in
                group.leave()
            }

            group.enter()
            char.fetchLocationSystem { system in
                system.fetchName { name in
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.tokenTableView.reloadData()
            }
        }
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

        cell.characterName.text = character.character_name

        cell.characterImage.fetchAndSetImage(eve: character.characterData!)

        var corpAllianceData: [String] = []
        if let corp = character.characterData?.corporation?.corporation_name {
            corpAllianceData.append(corp)
            if let alliance = character.characterData?.alliance?.alliance_name {
                corpAllianceData.append(alliance)
            }
        }
        cell.corpAllianceLabel.text = corpAllianceData.joined(separator: " - ")

        if !character.token!.hasAllScopes() {
            cell.accessoryView = nil
            cell.accessoryType = .detailButton
        } else {
            if let _ = character.characterData?.corporation {
                cell.accessoryView = nil
                cell.accessoryType = .disclosureIndicator
            } else {
                let indicator = UIActivityIndicatorView(style: .gray)
                cell.accessoryView = indicator
                indicator.startAnimating()
            }
        }

        var locationLabelItems: [String] = []
        if let location = character.locationSystem?.name?.name {
            locationLabelItems.append(location)
        }
        if let ship = character.locationShip?.ship_name {
            locationLabelItems.append(ship)
        }

        cell.locationLabel.text = locationLabelItems.joined(separator: ": ")

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
