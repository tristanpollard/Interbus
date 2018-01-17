//
// Created by Tristan Pollard on 2017-10-05.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import Eureka
import Alamofire
import AlamofireImage

class ReturnSearchViewController : UIViewController, TypedRowControllerType{

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    var row: RowOf<SearchResult>!
    var onDismissCallback: ((UIViewController) -> Void)?

    let esi = ESIClient.sharedInstance
    var searchResults : SearchResults = SearchResults()
    var selectedResult : SearchResult?

    var selectedCallback : ((SearchResult) -> (Void))?

    var initString : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchTextField.autocorrectionType = .no
        self.searchTextField.text = initString
        searchTextField.becomeFirstResponder()
    }



    func loadCharacters(){
        let categories : [SearchResult.SearchType] = [.alliance, .character, .corporation]
        let parameters: Parameters  = ["search" : searchTextField.text!, "categories" : categories.map({$0.rawValue}).joined(separator: ",")]
        esi.invoke(endPoint: "/search/", parameters: parameters){ response in

            if let esiErr = response.error{
                print("ESI Error: \(esiErr)")
                self.showErrorMsg(msg: esiErr.errorMsg!)
                return
            }

            self.searchResults = SearchResults()
            self.searchResults.resultsForSearch(search: response.result as! [String:[Int64]]) {
                self.tableView.reloadData()
            }
        }
    }

    func callback(){
        self.selectedCallback?(self.selectedResult!)
    }

}

extension ReturnSearchViewController : UITextFieldDelegate{

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.loadCharacters()
        textField.resignFirstResponder()
        return true
    }
}


extension ReturnSearchViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mailRecipientCell", for: indexPath)

        cell.imageView?.af_cancelImageRequest()
        cell.imageView?.image = nil
        let key = keyForSection(section: indexPath.section)
        if let character = searchResults.results[key]?[indexPath.row]{
            cell.textLabel?.text = character.name
            if let url = character.imageUrlForSearchResult() {
                var placeHolder : Image?
                var imageFilter : ImageFilter?

                switch (character.type){
                case .character:
                    placeHolder = UIImage(named: "characterPlaceholder64.jpg")?.af_imageRoundedIntoCircle()
                    imageFilter = ScaledToSizeCircleFilter(size: CGSize(width: 44, height: 44))
                case .corporation:
                    placeHolder = UIImage(named: "corporationPlaceholder64")
                    imageFilter = ScaledToSizeFilter(size: CGSize(width: 44, height: 44))
                case .alliance:
                    placeHolder = UIImage(named: "alliancePlaceholder64")
                    imageFilter = ScaledToSizeFilter(size: CGSize(width: 44, height: 44))
                default:
                    break
                }

                cell.imageView?.af_setImage(withURL: url, placeholderImage: placeHolder, filter: imageFilter)
                cell.imageView?.contentMode = UIViewContentMode.scaleAspectFit
            }
        }

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.searchResults.results.count;
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = keyForSection(section: section)
        return String(describing: title.first!).capitalized + title.dropFirst()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = keyForSection(section: section)
        if let characters = searchResults.results[key]{
            return characters.count
        }
        return 0
    }

    func keyForSection(section: Int) -> String{
        let keys = Array(searchResults.results.keys)
        let key = keys[section]
        return key
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = keyForSection(section: indexPath.section)
        let searchResult = self.searchResults.results[key]![indexPath.row]
        self.selectedResult = searchResult
        self.callback()
        self.navigationController?.popViewController(animated: true)
    }
}