//
// Created by Tristan Pollard on 2017-10-02.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import AlamofireImage
import NVActivityIndicatorView

class ContactViewController : UICharacterViewController, NVActivityIndicatorViewable{

    @IBOutlet weak var tableView: UITableView!

    let esi = ESIClient.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        let group = DispatchGroup()

        self.startAnimating()

        self.view.layoutIfNeeded()
        self.title = "Contacts"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(getContactToAdd))

        self.tableView.separatorColor = UIColor.black

        group.enter()
        self.character.loadContacts() {
            self.tableView.reloadData()
            group.leave()
        }

        group.enter()
        self.character.loadContactLabels(){
            self.tableView.reloadData()
            group.leave()
        }

        group.notify(queue: .main){
            self.stopAnimating()
        }

    }


    @objc func getContactToAdd(){
        self.performSegue(withIdentifier: "contactToReturnContactForm", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "contactToReturnContactForm"{
            if let vc = segue.destination as? ReturnContactFormViewController{
                vc.didSelectCallback = { result, standing in
                    if self.character.contacts.contains(where: {$0.contact_id == result.id}){ //don't add duplicates
                        return
                    }

                    let headers : HTTPHeaders = ["Authorization" : self.character.token!.authorizationHeader(), "Content-type" : "application/json"]
                    var urlRequest = try! URLRequest(url: ESIClient.baseURI + "/characters/\(self.character.id)/contacts/?standing=\(standing)", method: .post, headers: headers)
                    urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: [result.id])
                    self.esi.invoke(urlRequest: urlRequest){ esiResult in
                        let contact = EveContact(contact: result.playerOwned()!, standing: standing, contactType: EveContact.ContactType(rawValue: result.type.rawValue)!)
                        self.character.contacts.append(contact)
                        self.character.sortContacts()
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}

extension ContactViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            let contact = self.character.contacts[indexPath.row]
            self.startAnimating()
            character.removeContact(contact: contact){
                self.tableView.reloadData()
                self.stopAnimating()
            }
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Contacts"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return character.contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)

        cell.imageView?.af_cancelImageRequest()
        cell.imageView?.image = nil
        cell.detailTextLabel?.text = nil

        let contact = self.character.contacts[indexPath.row]
        let placeHolder = contact.contact!.getPlaceholder(size: 64).af_imageRoundedIntoCircle().af_imageScaled(to: CGSize(width: 43, height: 43))
        var imageFilter : ImageFilter = ScaledToSizeFilter(size: CGSize(width: 43, height: 43))

        if contact.type == .character{
            imageFilter = ScaledToSizeCircleFilter(size: CGSize(width: 43, height: 43))
        }

        cell.imageView?.af_setImage(withURL: contact.contact!.imageURL(size: 64), placeholderImage: placeHolder, filter: imageFilter)

        cell.textLabel?.text = contact.contact!.name
        if let labelId = contact.label_id {
            if let label = self.character.contactLabels.first(where: { $0.label_id == labelId }) {
                cell.detailTextLabel?.text = label.label_name!
            }
        }

        switch contact.standing!{
        case 10:
            cell.backgroundColor = UIColor.darkBlue
        case 5:
            cell.backgroundColor = UIColor.lightBlue
        case -5:
            cell.backgroundColor = UIColor.orange
        case -10:
            cell.backgroundColor = UIColor.red
        default:
            cell.backgroundColor = UIColor.white
        }


        return cell
    }
}