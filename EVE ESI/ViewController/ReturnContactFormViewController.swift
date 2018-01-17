//
// Created by Tristan Pollard on 2017-10-06.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Eureka
import Alamofire
import AlamofireImage

class ReturnContactFormViewController : FormViewController{

    var searching = false
    var searchResults = SearchResults()
    let esi = ESIClient.sharedInstance
    var didChange = false

    var didSelectCallback:((SearchResult, Float) -> (Void))?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Add Contact"

        form
            +++ Section("Search")
                <<< TextRow("search"){ row in
                    row.placeholder = "Search"
                    row.disabled = Condition.predicate(NSPredicate(value: searching))
                    row.cell.textField.becomeFirstResponder()
                }.onCellHighlightChanged() { cell, row in

                    if row.value != nil && self.didChange{
                        self.didChange = false
                        self.loadCharacters()
                    }

                }.onChange() { row in
                    self.didChange = true
                }
            +++ Section("Contact")
                <<< SliderRow("standing"){ row in
                    row.value = 0.0
                    row.minimumValue = -10.0
                    row.maximumValue = 10.0
                    row.steps = 4
                    row.title = "Standing"
                }
            +++ Section("Search Results"){ section in
                section.tag = "searchResults"
            }

    }

    func loadCharacters(){

        self.searching = true
        self.evaluateSearchTextRow()

        let categories : [SearchResult.SearchType] = [.alliance, .character, .corporation]
        let searchQuery = (self.form.rowBy(tag: "search") as! TextRow).value!
        let parameters: Parameters  = ["search" : searchQuery, "categories" : categories.map({$0.rawValue}).joined(separator: ",")]
        esi.invoke(endPoint: "/search/", parameters: parameters){ response in

            if let esiErr = response.error{
                print("ESI Error: \(esiErr)")
                self.showErrorMsg(msg: esiErr.errorMsg!)
                return
            }

            debugPrint(response.rawResponse)

            self.searchResults = SearchResults()
            self.searchResults.resultsForSearch(search: response.result as! [String:[Int64]]) {
                self.searching = false
                self.evaluateSearchTextRow()
                self.updateResultRows()
            }
        }
    }

    func updateResultRows(){
        var searchSection = self.form.sectionBy(tag: "searchResults")!
        let results = self.searchResults.results.map({$0.1})
        var allResults = [SearchResult]()
        results.map({allResults = allResults + $0})
        debugPrint(allResults)
        allResults = allResults.sorted(by: {$0.name! < $1.name!})
        searchSection.removeAll()
        for searchResult in allResults {
            let tag = "result_\(searchResult.id)"
            searchSection <<< ReturnResultRow(tag) { row in
                row.value = searchResult
            }.onCellSelection(){ cell, row in
                let slider = self.form.rowBy(tag: "standing") as! SliderRow
                self.didSelectCallback?(row.value!, slider.value!)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    func evaluateSearchTextRow(){
        self.form.rowBy(tag: "search")!.evaluateDisabled()
    }

}
