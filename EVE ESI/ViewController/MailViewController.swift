//
// Created by Tristan Pollard on 2017-10-04.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import AlamofireImage

class MailViewController : UICharacterViewController, NVActivityIndicatorViewable{

    @IBOutlet weak var tableView:
    UITableView!

    var selectedMail : EveMail?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.startAnimating()

        self.title = "Mail"

        self.view.layoutIfNeeded()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newMail))

        self.character.loadMailHeaders(lastMailId: nil){
            self.tableView.reloadData()
            self.stopAnimating()
        }

        self.character.loadMailLabels(){
            self.tableView.reloadData()
        }

    }

    @objc func newMail(){
        self.performSegue(withIdentifier: "mailToSendMail", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mailToReadMail"{
            if let viewController = segue.destination as? ReadMailViewController{
                viewController.mail = self.selectedMail
                viewController.character = self.character
                viewController.title = self.selectedMail!.subject
            }
        }else if segue.identifier == "mailToSendMail"{
            if let viewController = segue.destination as? SendMailViewController{
                viewController.character = self.character
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension MailViewController : UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            character.deleteMail(mail: self.character.mail[indexPath.row]){ deleted in
                if deleted {
                    self.tableView.reloadData()
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedMail = self.character.mail[indexPath.row]
        self.performSegue(withIdentifier: "mailToReadMail", sender: self)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.character.mail.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mailCell", for: indexPath) as! MailHeaderCell

        cell.senderImageView.af_cancelImageRequest()
        cell.senderImageView.image = nil
        cell.mailLabel.text = nil

        let mail = self.character.mail[indexPath.row]

        cell.subjectLabel.text = mail.subject!
        let placeHolder = UIImage(named: "characterPlaceholder64.jpg")!.af_imageRoundedIntoCircle().af_imageScaled(to: CGSize(width: 44, height: 44))
        let imageFilter = ScaledToSizeCircleFilter(size: CGSize(width: 44, height: 44))
        cell.senderImageView.af_setImage(withURL: mail.from!.imageURL(size: cell.imageView!.sizeForImage()), placeholderImage: placeHolder, filter: imageFilter)

        if let sender = mail.from?.name{
            cell.senderLabel.text = sender
        }

        let keys = mail.labels
        let labels = self.character.mailLabels.filter({keys.contains($0.label_id!)})
        cell.mailLabel.text = labels.map({$0.name!}).joined(separator: ", ")

        if let date = mail.date{
            let df = DateFormatter()
            df.dateFormat = "MMM d, HH:mm"
            cell.dateLabel.text = df.string(from: date)
        }

        if indexPath.row == self.character.mail.count - 1 { // last cell
            self.character.loadMailHeaders(lastMailId: self.character.mail[self.character.mail.count-1].mail_id!){
                self.tableView.reloadData()
            }
        }

        return cell
    }

}