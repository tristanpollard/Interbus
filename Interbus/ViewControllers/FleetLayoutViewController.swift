import UIKit

class FleetLayoutViewController: UIFleetController {
    @IBOutlet weak var fleetLayoutTable: UITableView! {
        didSet {
            fleetLayoutTable.delegate = self
            fleetLayoutTable.dataSource = self
            fleetLayoutTable.refreshControl = refreshControl
        }
    }

    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshFleet), for: .valueChanged)
        return control
    }()

    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(toggleEditing))
        ]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(refreshFleet), userInfo: nil, repeats: true)
        refreshFleet()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }

    @objc
    func toggleEditing() {
        fleetLayoutTable.isEditing = !fleetLayoutTable.isEditing
    }

    @objc
    func refreshFleet() {
        let group = DispatchGroup()
        refreshControl.beginRefreshing()

        group.enter()
        fleet.fetchComposition {
            group.leave()
        }

        group.enter()
        fleet.fetchMembers {
            self.fleet.members.fetchNames {
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.fleet.mapMembers()
            self.fleetLayoutTable.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
}

extension FleetLayoutViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return fleet.compositionMap.count + 1
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section > 0 else {
            return "Fleet"
        }

        let composition = fleet.compositionMap[section - 1]
        if let squads = composition.squads {
            return composition.name
        }

        return "- \(composition.name)"

        return "Unknown Squad/Wing: \(section)"
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return fleet.commander != nil ? 1 : 0 // fleet commander
        }

        return fleet.compositionMap[section - 1].members.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section > 0 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FleetCommanderCell", for: indexPath)

            if let commander = fleet.commander {
                cell.textLabel?.text = commander.name?.name
            }

            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "FleetCompositionCell", for: indexPath)

        let section = fleet.compositionMap[indexPath.section - 1]
        let member = section.members[indexPath.row]

        if member.role.contains("commander") {
            cell.accessoryType = .checkmark
        }

        cell.textLabel?.text = member.name?.name

        return cell
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let member = fleet.compositionMap[indexPath.section].members[indexPath.row]
        switch editingStyle {
        case .delete:
            fleet.removeMember(member: member) { success in
                if !success {
                    self.refreshFleet()
                }
            }
            fleet.compositionMap[indexPath.section].members.remove(at: indexPath.row)
            break
        default:
            break
        }
    }

    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        var sourceMember: FleetMember?
        if sourceIndexPath.section == 0 {
            sourceMember = fleet.commander
            fleet.commander = nil
        } else {
            sourceMember = fleet.compositionMap[sourceIndexPath.section - 1].members[sourceIndexPath.row]
            fleet.compositionMap[sourceIndexPath.section - 1].members.remove(at: sourceIndexPath.row)
        }

        if let sourceMember = sourceMember {
            if destinationIndexPath.section == 0 {
                fleet.commander = sourceMember
                fleet.moveMember(member: sourceMember, destination: nil) { success in
                    if !success {
                        self.refreshFleet()
                    }
                }
            } else {
                fleet.compositionMap[destinationIndexPath.section - 1].members.append(sourceMember)
                fleet.moveMember(member: sourceMember, destination: fleet.compositionMap[destinationIndexPath.section - 1]) { success in
                    if !success {
                        self.refreshFleet()
                    }
                }
            }
        } else {
            tableView.reloadData()
        }
    }
}

extension FleetLayoutViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        // Disable moving in same section
        if sourceIndexPath.section == proposedDestinationIndexPath.section {
            return sourceIndexPath
        }

        return proposedDestinationIndexPath
    }
}