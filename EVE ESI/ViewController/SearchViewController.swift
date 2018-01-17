//
// Created by Tristan Pollard on 2017-09-26.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class SearchViewController : UIViewController{

    @IBOutlet weak var searchTableView: UITableView!

    var searchResults : SearchResults!
    var selectedCell : IndexPath?

    override func viewDidLoad(){
        super.viewDidLoad();
        self.searchTableView.delegate = self;
        self.searchTableView.dataSource = self;
    }

    func keyForSection(section: Int) -> String{
        let keys = Array(searchResults.results.keys)
        let key = keys[section]
        return key
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchToCharacter"{
            if let viewController = segue.destination as? CharacterViewController{
                if let path = self.selectedCell {
                    let key = keyForSection(section: path.section)
                    if let result = self.searchResults.results[key]?[path.row] {
                        viewController.character = EveCharacter(character_id: result.id)
                        viewController.title = result.name
                    }
                }
            }
        }else if segue.identifier == "searchToCorporation"{
            if let viewController = segue.destination as? CorporationViewController{
                if let path = self.selectedCell{
                    let key = keyForSection(section: path.section)
                    if let result = self.searchResults.results[key]?[path.row] {
                        viewController.corporation = EveCorporation(corporation_id: result.id)
                        viewController.title = result.name
                    }
                }
            }
        }else if segue.identifier == "searchToAlliance"{
            if let viewController = segue.destination as? AllianceViewController{
                if let path = self.selectedCell{
                    let key = keyForSection(section: path.section)
                    if let result = self.searchResults.results[key]?[path.row] {
                        viewController.alliance = EveAlliance(alliance_id: result.id)
                        viewController.title = result.name
                    }
                }
            }
        }
    }

}


extension SearchViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = keyForSection(section: section)
        if let characters = searchResults.results[key]{
            return characters.count
        }
        return 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return searchResults.results.count;
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = keyForSection(section: section)
        return String(describing: title.first!).capitalized + title.dropFirst()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath)
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = keyForSection(section: indexPath.section)
        selectedCell = indexPath

        switch (key){
        case "characters":
            self.performSegue(withIdentifier: "searchToCharacter", sender: self)
        case "corporations":
            self.performSegue(withIdentifier: "searchToCorporation", sender: self)
        case "alliances":
            self.performSegue(withIdentifier: "searchToAlliance", sender: self)
        default:
            break
        }

    }
}