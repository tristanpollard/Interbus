//
// Created by Tristan Pollard on 2017-09-27.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import NVActivityIndicatorView

class CorporationViewController : UIViewController, NVActivityIndicatorViewable{

    @IBOutlet weak var corporationImage: UIImageView!
    @IBOutlet weak var allianceImage: UIImageView!
    @IBOutlet weak var corporationName: UILabel!
    @IBOutlet weak var allianceName: UILabel!
    
    var corporation : EveCorporation!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layoutIfNeeded()

        self.startAnimating()

        self.corporation.load(){
            if let all_id = self.corporation.alliance_id {
                let placeholder = UIImage(named: "alliancePlaceholder128.png")
                self.allianceImage.af_setImage(withURL: EveAlliance.imageURL(alliance_id: all_id, size:self.allianceImage.sizeForImage()), placeholderImage: placeholder)
            }
            self.corporationName.text = self.corporation.name

            if let alliance = self.corporation.alliance {
                alliance.load() {
                    self.allianceName.text = self.corporation.alliance!.name
                    self.stopAnimating()
                }
            }else{
                self.stopAnimating()
            }
        }

        let placeholder = UIImage(named: "corporationPlaceholder256.png")
        self.corporationImage.af_setImage(withURL: self.corporation.imageURL(size: self.corporationImage.sizeForImage()), placeholderImage: placeholder)

        let allianceGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(imageTapped(tapGestureRecognizer: )))
        self.allianceImage.isUserInteractionEnabled = true
        self.allianceImage.addGestureRecognizer(allianceGestureRecognizer)

    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        if let tappedImage = tapGestureRecognizer.view as? UIImageView{
            if tappedImage == allianceImage && self.corporation.alliance != nil{
                performSegue(withIdentifier: "corporationToAlliance", sender: self)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "corporationToAlliance"{
            if let viewController = segue.destination as? AllianceViewController{
                viewController.alliance = self.corporation.alliance!
                viewController.title = self.corporation.alliance!.name
            }
        }
    }

}
