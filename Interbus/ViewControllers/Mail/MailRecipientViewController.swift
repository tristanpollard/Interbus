import UIKit
import SDWebImage

class MailRecipientViewController: UIViewController {
    @IBOutlet weak var recipientTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var searchResults: [EveSearchResult] = []
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
        if let q = self.searchBar.text {
            EveSearch.search(q, categories: searchScopes[searchBar.selectedScopeButtonIndex]) { results in
                results.fetchNames {
                    self.searchResults = results.sorted {
                        $0.name!.name < $1.name!.name
                    }
                    DispatchQueue.main.async {
                        self.recipientTable.reloadData()
                        self.recipientTable.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                    }
                }
            }
        }
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
        if let text = searchBar.text, text.count > 0 {
            performSearch()
        }
    }
}

extension MailRecipientViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipientCell", for: indexPath)

        cell.imageView?.roundImageWithBorder(color: .clear)
        let result = searchResults[indexPath.row]
        cell.textLabel?.text = result.name?.name
        cell.imageView?.fetchAndSetImage(eve: result)

        return cell
    }
}

extension MailRecipientViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = self.searchResults[indexPath.row]
        if let callback = self.selectItem {
            callback(selectedItem)
        }
        self.navigationController?.popViewController(animated: true)
    }
}
