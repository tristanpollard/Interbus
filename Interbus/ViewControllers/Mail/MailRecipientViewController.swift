//
// Created by Tristan Pollard on 2018-12-17.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import UIKit
import SDWebImage

class MailRecipientViewController: UIViewController {
    @IBOutlet weak var recipientTable: UITableView!
    @IBOutlet weak var searchField: UITextField!

    var searchResults: [EveSearchResult] = []
    var selectItem: ((EveSearchResult) -> (Void))?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchField.autocorrectionType = .no
        self.searchField.becomeFirstResponder()
        self.searchField.keyboardAppearance = .default
        self.searchField.keyboardType = .alphabet
    }

    func performSearch() {
        if let q = self.searchField.text {
            EveSearch.search(q) { results in
                results.fetchNames {
                    self.searchResults = results.sorted {
                        $0.name!.name < $1.name!.name
                    }
                    self.recipientTable.reloadData()
                    let topIndex = IndexPath(row: 0, section: 0)
                    self.recipientTable.scrollToRow(at: topIndex, at: .top, animated: true)
                }
            }
        }
    }
}

extension MailRecipientViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.performSearch()
        return true
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

        let placeHolder = UIImage(named: "characterPlaceholder64.jpg")!
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
