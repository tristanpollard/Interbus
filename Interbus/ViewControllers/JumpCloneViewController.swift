import UIKit

class JumpCloneViewController: UIViewController {

    @IBOutlet weak var cloneTable: UITableView!
    var clones: EveClones!
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.cloneTable.refreshControl = refreshControl
        self.refreshControl.addTarget(self, action: #selector(refreshClones), for: .valueChanged)
        self.refreshClones()
    }

    @objc
    func refreshClones() {
        let group = DispatchGroup()
        self.refreshControl.beginRefreshing()
        // Fetch all the clones
        self.clones.fetchClones {
            // Reload table to show activity indicator
            self.cloneTable.reloadData()
            // Go through each clone pulling the data, and updating the section as its loaded.
            for (idx, clone) in self.clones.jump_clones.enumerated() {
                let indexSet = IndexSet(integer: idx)
                group.enter()
                clone.implantTypes.fetchNames {
                    clone.implantTypes.sort {
                        $0.name!.name < $1.name!.name
                    }
                    self.cloneTable.reloadSections(indexSet, with: .automatic)
                    group.leave()
                }
                group.enter()
                clone.station?.fetchStation {
                    self.cloneTable.reloadSections(indexSet, with: .automatic)
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.refreshControl.endRefreshing()
            }
        }
    }
}

extension JumpCloneViewController: UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.clones.jump_clones.count
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        let clone = self.clones.jump_clones[section]
        var name: String?
        if let stationName = clone.station?.name?.name {
            name = stationName
        }

        return name
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.clones.jump_clones[section].implantTypes.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cloneCell", for: indexPath)

        let clone = self.clones.jump_clones[indexPath.section]
        let implant = clone.implantTypes[indexPath.row]

        cell.textLabel?.text = implant.name?.name
        cell.imageView?.image = nil
        cell.imageView?.fetchAndSetImage(eve: implant)

        cell.accessoryView = nil
        if clone.station?.name == nil || implant.name == nil {
            let activityIndicator = UIActivityIndicatorView(style: .gray)
            cell.accessoryView = activityIndicator
            activityIndicator.startAnimating()
        }

        return cell
    }
}

extension JumpCloneViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
