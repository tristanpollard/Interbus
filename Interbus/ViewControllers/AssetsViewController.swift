import UIKit

class AssetsViewController: UIViewController {
    @IBOutlet weak var assetTable: UITableView!
    let refreshControl = UIRefreshControl()

    var assets: EveAssets!
    var fetchOnLoad = true

    override func viewDidLoad() {
        super.viewDidLoad()

        if fetchOnLoad {
            self.assetTable.refreshControl = self.refreshControl
            self.refreshControl.beginRefreshing()
            self.assets.fetchAllAssets {
                self.assetTable.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
}

extension AssetsViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = self.assets.assets[indexPath.section].assets[indexPath.row]
        guard item.childrenAssets.count > 0 else {
            return
        }

        let assets = EveAssets(character: self.assets.character)
        assets.assets = [AssetGroup(location: -1, assets: item.childrenAssets, type: .hangar)]
        let vc = UIStoryboard(name: "Assets", bundle: nil)
                .instantiateViewController(withIdentifier: "assetsView") as! AssetsViewController
        vc.assets = assets
        vc.fetchOnLoad = false
        vc.title = item.assetName?.name ?? item.name?.name
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension AssetsViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.assets.assets[section].assets.count
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.assets.assets.count
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        let section = self.assets.assets[section]
        if section.location_id == -1 {
            return nil
        }

        return section.name?.name ?? "Unknown Location"
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "assetCell", for: indexPath)

        let asset = self.assets.assets[indexPath.section].assets[indexPath.row]

        cell.textLabel?.text = asset.name?.name
        if let assetName = asset.assetName {
            cell.textLabel?.text = assetName.name
        }
        cell.imageView?.image = nil
        cell.imageView?.fetchAndSetImage(eve: asset)

        cell.accessoryType = .none
        if asset.childrenAssets.count > 0 {
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }
}
