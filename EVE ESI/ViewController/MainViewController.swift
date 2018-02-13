//
//  ViewController.swift
//  EVE ESI
//
//  Created by Tristan Pollard on 2017-09-24.
//  Copyright © 2017 Sumo. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import PopupDialog

var searchResults  = [String: [SearchResult]]()

class MainViewController: UIViewController{

    @IBOutlet weak var loadEsiButton: UIButton!
    @IBOutlet weak var esiRoute: UITextField!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedToken : SSOToken?

    @IBOutlet weak var searchButton: UIBarButtonItem!

    let esi = ESIClient.sharedInstance

    var searchResults : SearchResults?
    var tokens = [SSOToken]()

    @IBAction func searchButtonTapped(_ sender: Any) {

        let searchVC = SearchPopupViewController(nibName: "SearchPopupController", bundle: nil)

        let popup = PopupDialog(viewController: searchVC, buttonAlignment: .horizontal, transitionStyle: .bounceDown, gestureDismissal: true)

        let buttonCancel = CancelButton(title: "Cancel", height: 60) {

        }

        let buttonSearch = DefaultButton(title: "Search", height: 60) {

            guard let searchValue = searchVC.searchField.text, searchValue.count > 3 else{
                return
            }

            let esi = ESIClient.sharedInstance

            let typeCount = SearchResult.SearchType.allTypes.count
            let categories = SearchResult.SearchType.allTypes[1..<typeCount].map({String($0.rawValue)})
            let parameters: Parameters  = ["search" : searchValue, "categories" : categories.joined(separator: ",")]
            esi.invoke(endPoint: "/search/", parameters: parameters){ response in

                if let esiErr = response.error{
                    print("ESI Error: \(esiErr)")
                    return
                }

                self.searchResults = SearchResults()
                self.searchResults?.resultsForSearch(search: response.result as! [String:[Int64]]) {
                    self.performSegue(withIdentifier: "SearchResults", sender: self)
                }

            }

        }

        popup.addButtons([buttonCancel, buttonSearch])

        present(popup, animated: true, completion: nil)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layoutIfNeeded()

        self.tokens = SSOToken.loadAllTokens()
        self.tokens = self.tokens.sorted(by: {$0.character_name! < $1.character_name!})

        self.tableView.reloadData()

    }

    @IBAction func addButtonPressed(_ sender: Any) {
        UIApplication.shared.open(URL(string: ESIClient.getESIUrl())!)
    }

    func didReceiveToken(token: SSOToken){

        token.characterDidUpdate = {

            self.tokens = self.tokens.filter({$0.character_id! != token.character_id})
            self.tokens.append(token)
            self.tokens = self.tokens.sorted(by: {$0.character_name! < $1.character_name!})
            self.tableView.reloadData()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchResults" {
            if let searchViewController = segue.destination as? SearchViewController{
                searchViewController.searchResults = searchResults!;
            }
        }else if segue.identifier == "tokenToAuthChar"{
            if let authCharViewController = segue.destination as? AuthCharacterViewController{
                authCharViewController.character = EveAuthCharacter(token: selectedToken!)
                authCharViewController.title = selectedToken!.character_name!
            }
        }
    }

}

extension MainViewController : UITableViewDataSource, UITableViewDelegate{

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let token = tokens[indexPath.row]
        selectedToken = token
        self.performSegue(withIdentifier: "tokenToAuthChar", sender: self)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            self.tokens[indexPath.row].deleteToken()
            self.tokens.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Characters"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokens.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "tokenCell", for: indexPath)

        cell.imageView?.af_cancelImageRequest()
        cell.imageView?.image = nil

        let token = self.tokens[indexPath.row]
        cell.textLabel?.text = token.character_name

        if !token.hasAllScopes(){
            cell.accessoryType = .detailButton
        }else{
            cell.accessoryType = .none
        }

        let placeholder = UIImage(named: "characterPlaceholder64.jpg")!.af_imageRoundedIntoCircle()
        let imageFilter = ScaledToSizeCircleFilter(size: CGSize(width: 44, height: 44))
        let char = EveCharacter(token.character_id!)
        cell.imageView?.af_setImage(withURL: char.imageURL(size: cell.imageView!.sizeForImage(maxImageSize: 64)), placeholderImage: placeholder, filter: imageFilter)
        cell.imageView?.contentMode = UIViewContentMode.scaleAspectFit

        return cell
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {

        UIApplication.shared.open(URL(string: ESIClient.getESIUrl())!)

    }
}

