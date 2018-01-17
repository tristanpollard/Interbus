//
//  CharacterViewController.swift
//  EVE ESI
//
//  Created by Tristan Pollard on 2017-09-26.
//  Copyright © 2017 Sumo. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import NVActivityIndicatorView

class CharacterViewController : UIViewController, NVActivityIndicatorViewable{

    @IBOutlet weak var characterName: UILabel!
    @IBOutlet weak var characterCorporation: UILabel!
    @IBOutlet weak var characterAlliance: UILabel!
    @IBOutlet weak var characterBirth: UILabel!
    @IBOutlet weak var characterImage: UIImageView!

    @IBOutlet weak var allianceImage: UIImageView!
    @IBOutlet weak var corporationImage: UIImageView!
    var character : EveCharacter!

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.startAnimating()

        self.view.backgroundColor = UIColor.orange

        self.view.layoutIfNeeded()

        let circleFilter = CircleFilter()
        let characterPlaceholder = UIImage(named: "characterPlaceholder256.jpg")?.af_imageRoundedIntoCircle()
        self.characterImage.af_setImage(withURL: self.character.imageURL(size: self.characterImage.sizeForImage()), placeholderImage: characterPlaceholder, filter: circleFilter) { response in
            self.characterImage.borderCircle(color: UIColor.white)
        }


        self.character.load() {
            self.characterName.text = self.character!.name

            let corporationPlaceholder = UIImage(named: "corporationPlaceholder128.png")
            self.corporationImage.af_setImage(withURL: self.character!.corporation!.imageURL(size: self.corporationImage.sizeForImage()), placeholderImage: corporationPlaceholder)

            if let all_id = self.character.alliance_id{
                let alliancePlaceholder = UIImage(named: "alliancePlaceholder128.png")
                self.allianceImage.af_setImage(withURL: EveAlliance.imageURL(alliance_id: all_id, size: self.allianceImage.sizeForImage()), placeholderImage: alliancePlaceholder)
            }

            self.character?.corporation?.load(){
                self.characterCorporation.text = self.character!.corporation!.name
                if let alliance = self.character?.alliance {
                    alliance.load() {
                        self.characterAlliance.text = self.character!.alliance!.name
                        self.stopAnimating()
                    }
                }else{
                    self.stopAnimating()
                }

            }

        }


        let allianceGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(imageTapped(tapGestureRecognizer: )))
        let corporationGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(imageTapped(tapGestureRecognizer: )))
        self.corporationImage.isUserInteractionEnabled = true
        self.allianceImage.isUserInteractionEnabled = true
        self.allianceImage.addGestureRecognizer(allianceGestureRecognizer)
        self.corporationImage.addGestureRecognizer(corporationGestureRecognizer)


    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        if let tappedImage = tapGestureRecognizer.view as? UIImageView{
            if tappedImage == allianceImage && self.character?.alliance != nil{
                print("Alliance image tapped.")
                performSegue(withIdentifier: "characterToAlliance", sender: self)
            }else if tappedImage == corporationImage && self.character?.corporation != nil{
                print("Corporation Image Tapped.")
                performSegue(withIdentifier: "characterToCorporation", sender: self)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "characterToCorporation"{
            if let viewController = segue.destination as? CorporationViewController{
                viewController.corporation = self.character.corporation!
                viewController.title = self.character.corporation!.name
            }
        }else if segue.identifier == "characterToAlliance"{
            if let viewController = segue.destination as? AllianceViewController{
                viewController.alliance = self.character.alliance!
                viewController.title = self.character.alliance!.name
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
