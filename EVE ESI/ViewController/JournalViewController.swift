//
// Created by Tristan Pollard on 2017-10-03.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import AlamofireImage
import NVActivityIndicatorView

class JournalViewController : UICharacterViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {

        self.view.layoutIfNeeded()

        self.startAnimating()

        self.title = "Wallet Journal"

        self.character.loadWalletJournal(){
            self.tableView.reloadData()
            self.stopAnimating()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension JournalViewController : UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.character.journal.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "journalCell", for: indexPath) as! JournalTableViewCell

        cell.entryImage.af_cancelImageRequest()
        cell.entryImage.image = nil

        cell.nameLabel.text = nil
        cell.amountLabel.text = nil
        cell.typeLabel.text = nil

        let entry = self.character.journal[indexPath.row]
        if let first = entry.first_party, let second = entry.second_party {

            let filter = ScaledToSizeCircleFilter(size: CGSize(width: 44, height: 44))

            var player = first
            cell.amountLabel.textColor = .green
            if player.id == self.character.id{
                player = second
                cell.amountLabel.textColor = .red
            }

            cell.nameLabel.text = player.name
            let placeHolder = player.getPlaceholder(size: 64).af_imageRoundedIntoCircle().af_imageScaled(to: CGSize(width: 44, height: 44))
            cell.entryImage.af_setImage(withURL: player.imageURL(size: cell.entryImage.sizeForImage()), placeholderImage: placeHolder, filter: filter)

        } else {
            cell.nameLabel.text = "CONCORD"
            cell.amountLabel.text = nil
            cell.entryImage.image = UIImage(named: "characterPlaceholder64.jpg")!.af_imageRoundedIntoCircle().af_imageScaled(to: CGSize(width: 44, height: 44))
        }

        if let amt = entry.amount{

            if amt == 0{
                cell.amountLabel.text = "0"
                cell.amountLabel.textColor = UIColor.black
            }else {
                let nf = NumberFormatter()
                nf.numberStyle = .decimal
                cell.amountLabel.text = nf.string(from: NSNumber(value: amt))
            }
        }

        if let journalType = entry.ref_type{
            cell.typeLabel.text = journalType.lowerToUpper()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entry = self.character.journal[indexPath.row]
        debugPrint(entry, entry.first_party_id, entry.second_party_id, entry.first_party?.name, entry.second_party?.name)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
