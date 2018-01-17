//
// Created by Tristan Pollard on 2017-10-04.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import WebKit
import NVActivityIndicatorView

class ReadMailViewController : UICharacterViewController, NVActivityIndicatorViewable{

    var mail : EveMail!

    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var dateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteMail))
        let replyButton = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(replyMail))
        self.navigationItem.rightBarButtonItems = [deleteButton, replyButton]
        self.startAnimating()

        self.character.loadMail(mail: self.mail){ result in
            self.mail.loadRecipients() {
                self.textView.text = self.mail.getBodyString()
                self.subjectLabel.text = self.mail.subject
                let recips = self.mail.recipients.map({$0.name})
                self.toLabel.text = "To: " + recips.joined(separator: ", ")
                let df = DateFormatter()
                df.dateFormat = "MMM d, HH:mm"
                self.dateLabel.text = df.string(from: self.mail.date!)
                self.fromLabel.text = "From \(self.mail.from!.name)"
                self.stopAnimating()
            }
        }

    }

    @objc func replyMail(){
        performSegue(withIdentifier: "readMailToSendMail", sender: self)
    }

    @objc func deleteMail(){
        self.character.deleteMail(mail: self.mail){ deleted in
            if deleted{
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "readMailToSendMail"{
            if let viewController = segue.destination as? SendMailViewController{
                viewController.character = self.character
                viewController.mail = self.mail
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
