import UIKit
import SDWebImage

class MailRecipientViewController: UIViewController {
    @IBOutlet weak var recipientTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var searchResults: [EveSearchCategory: [EveSearchResult]] = [:]
    var selectItem: ((EveSearchResult) -> (Void))?

    let searchScopes: [[EveSearchCategory]] = [
        [.character, .corporation, .alliance],
        [.character],
        [.corporation],
        [.alliance]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.becomeFirstResponder()
        searchBar.autocorrectionType = .no
        searchBar.keyboardAppearance = .default
        searchBar.keyboardType = .alphabet
    }

    func performSearch() {
        self.searchResults = [:]
        self.recipientTable.reloadData()
        if let q = self.searchBar.text, q.count > 0 {
            EveSearch.search(q, categories: searchScopes[searchBar.selectedScopeButtonIndex]) { results in
                results.fetchNames {
                    var newSearchResults: [EveSearchCategory: [EveSearchResult]] = [:]
                    results.sorted {
                        $0.name!.name.lowercased() < $1.name!.name.lowercased()
                    }.forEach { result in
                        if newSearchResults[result.category] != nil {
                            newSearchResults[result.category]!.append(result)
                        } else {
                            newSearchResults[result.category] = [result]
                        }
                    }
                    self.searchResults = newSearchResults

                    DispatchQueue.main.async {
                        self.recipientTable.reloadData()
                        self.recipientTable.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                    }
                }
            }
        }
    }

    public func searchSection(_ section: Int) -> EveSearchCategory {
        return searchResults.keys.sorted(by: { $0.rawValue < $1.rawValue })[section]
    }

    public func resultsForSection(_ section: Int) -> [EveSearchResult] {
        return searchResults[searchSection(section)]!
    }
}

extension MailRecipientViewController: UISearchBarDelegate {
    public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.resignFirstResponder()
        performSearch()
        return true
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        performSearch()
    }

    public func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        performSearch()
    }
}

extension MailRecipientViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let name = searchSection(section).rawValue
        return name.prefix(1).uppercased() + name.dropFirst() + "s"
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsForSection(section).count
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return searchResults.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipientCell", for: indexPath)

        cell.imageView?.roundImageWithBorder(color: .clear)
        let result = resultsForSection(indexPath.section)[indexPath.row]
        cell.textLabel?.text = result.name?.name
        cell.imageView?.fetchAndSetImage(eve: result)

        return cell
    }
}

extension MailRecipientViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = resultsForSection(indexPath.section)[indexPath.row]
        if let callback = self.selectItem {
            callback(selectedItem)
        }
        self.navigationController?.popViewController(animated: true)
    }
}
