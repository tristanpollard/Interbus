//
// Created by Tristan Pollard on 2019-02-15.
// Copyright (c) 2019 Tristan Pollard. All rights reserved.
//

import UIKit

class ContractsViewController: UIViewController {
    var contracts: Contracts!
    @IBOutlet weak var contractsTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        contracts.fetchNextPage { newContracts, error in
            guard error == nil else {
                return
            }

            self.contractsTable.reloadData()
        }
    }
}

extension ContractsViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contracts.contracts.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContractCell", for: indexPath)

        let contract = contracts.contracts[indexPath.row]
        cell.textLabel?.text = contract.title ?? contract.issuer?.name?.name
        cell.detailTextLabel?.text = contract.type.rawValue
        cell.imageView?.image = UIImage(named: "characterPlaceholder64.jpg")
        cell.imageView?.roundImageWithBorder(color: .clear)
        if let issuer = contract.issuer {
            cell.imageView?.fetchAndSetImage(eve: issuer)
        }

        return cell
    }
}

extension ContractsViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == contracts.contracts.count - 1 {
            let oldCount = contracts.contracts.count
            contracts.fetchNextPage { newContracts, error in
                guard error == nil else {
                    return
                }

                let paths: [IndexPath] = (oldCount..<self.contracts.contracts.count).map {
                    IndexPath(row: $0, section: 0)
                }
                tableView.insertRows(at: paths, with: .automatic)
            }
        }
    }
}
