//
// Created by Tristan Pollard on 2018-12-15.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import UIKit

class SelectedCharacterViewController: UIViewController {

    var character: EveCharacter!

    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var corporationImage: UIImageView!
    @IBOutlet weak var allianceImage: UIImageView!
    @IBOutlet weak var corporationLabel: UILabel!
    @IBOutlet weak var allianceLabel: UILabel!

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
}
