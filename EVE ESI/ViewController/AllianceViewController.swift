//
// Created by Tristan Pollard on 2017-09-28.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import NVActivityIndicatorView

class AllianceViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable {

    var alliance : EveAlliance!

    @IBOutlet weak var allianceImage: UIImageView!
    @IBOutlet weak var allianceName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let corps = self.alliance.corporations{
            return corps.count
        }

        return 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Corporations"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "corporationListCell", for: indexPath)

        cell.imageView?.af_cancelImageRequest()
        cell.imageView?.image = nil

        if let corp = self.alliance.corporations?[indexPath.row]{
            cell.textLabel?.text = corp.name

            let placeholder = UIImage(named: "corporationPlaceholder64.png")
            let imageFilter = ScaledToSizeFilter(size: CGSize(width: 44, height: 44))
            cell.imageView?.af_setImage(withURL: corp.imageURL(size:64), placeholderImage: placeholder, filter: imageFilter)
            cell.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        }


        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let group = DispatchGroup()

        self.startAnimating()

        let placeholder = UIImage(named: "alliancePlaceholder128.png")
        self.allianceImage.af_setImage(withURL: self.alliance.imageURL(size: self.allianceImage.sizeForImage(maxImageSize: 128)), placeholderImage: placeholder)

        group.enter()
        self.alliance.loadAllianceCorporations(){
            self.tableView.reloadData()
            group.leave()
        }

        group.enter()
        self.alliance.load(){
            self.allianceName.text = self.alliance.name
            group.leave()
        }

        group.notify(queue: .main){
            self.stopAnimating()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "allianceToCorporation"{
            if let cell = sender as? UITableViewCell{
                if let indexPath = tableView.indexPath(for: cell) {
                    if let viewController = segue.destination as? CorporationViewController {
                        let corporation = self.alliance.corporations![indexPath.row]
                        viewController.corporation = corporation
                        viewController.title = corporation.name
                    }
                }
            }
        }
    }
}
