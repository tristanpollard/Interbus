import UIKit

class KillsViewController: UIViewController {
    @IBOutlet weak var killsTable: UITableView!

    let refreshControl = UIRefreshControl()
    var kills: EveKills!

    var hasKills: Bool {
        return self.kills.kills.count > 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.killsTable.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: #selector(fetchFresh), for: .valueChanged)
        if !self.hasKills {
            self.fetchFresh()
        }
    }

    @objc
    func fetchFresh() {
        self.fetchNext(fresh: true)
    }

    func fetchNext(fresh: Bool = false) {
        self.refreshControl.beginRefreshing()
        self.kills.fetchNextPage(fresh: fresh) { _ in
            self.killsTable.reloadData()
            self.refreshControl.endRefreshing()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let dest = segue.destination as? KillAttackersViewController, let indexPath = sender as? IndexPath {
            let kill = self.kills.kills[indexPath.row]
            dest.attackers = kill.attackers
        }
    }
}

extension KillsViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.kills.kills.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "killCell", for: indexPath) as! KillMailCell

        let kill = self.kills.kills[indexPath.row]
        cell.victimShipImage.image = nil
        cell.victimShipImage.fetchAndSetImage(eve: kill.victim.ship)

        cell.victimLabel.text = kill.victim.name?.name
        cell.shipLabel.text = kill.victim.ship.name?.name

        cell.dateLabel.text = kill.system?.name?.name

        return cell
    }
}

extension KillsViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "killsToAttackers", sender: indexPath);
    }
}


extension KillsViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let baseCount = self.kills.kills.count - 1
        for path in indexPaths {
            if path.row >= baseCount {
                self.kills.fetchNextPage { success in
                    if success {
                        self.killsTable.reloadData()
                    }
                }
                return
            }
        }
    }
}