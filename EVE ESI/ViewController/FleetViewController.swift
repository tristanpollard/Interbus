//
// Created by Tristan Pollard on 2018-02-16.
// Copyright (c) 2018 Sumo. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import AlamofireImage

class FleetViewController : UICharacterViewController, NVActivityIndicatorViewable{
    @IBOutlet weak var fleetBarButton: UITabBarItem!
    
    @IBOutlet weak var fleetTable: UITableView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!

    
    var fleet : EveFleet{
        get{
            return self.character.fleet
        }
    }

    @objc func refreshTapped(_ sender: Any) {
        self.refresh()
    }

    @objc func editTapped(_ sender: Any){
        self.fleetTable.setEditing(!self.fleetTable.isEditing, animated: true)
        let i = 0..<self.totalSquadsAndWings()
        let set = IndexSet(integersIn: i)
        self.fleetTable.reloadSections(set, with: .fade)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fleetTable.register(UINib(nibName: "FleetHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "fleetHeader")
        self.fleetTable.sectionHeaderHeight = CGFloat(30)

        self.view.layoutIfNeeded()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let item = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshTapped(_:)))
        let edit = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped(_:)))

        self.navigationItem.rightBarButtonItems = [edit, item]
        self.tabBarController?.navigationItem.rightBarButtonItems = [edit, item]

        self.refresh()
    }

    @objc func refresh(){

        self.startAnimating()
        self.fleet.refreshFleet{ valid in

            let group = DispatchGroup()

            group.enter()
            self.fleet.loadAllShipNames{
                group.leave()
            }

            group.enter()
            self.fleet.loadAllSystemNames{
                group.leave()
            }


            group.notify(queue: .main) {
                self.stopAnimating()
                self.fleetTable.reloadData()
            }
        }
    }

}



extension FleetViewController : UITableViewDelegate, UITableViewDataSource{

    func compositionToSection(_ comp : EveFleet.FleetComposition) -> Int{

        var count = 0

        if let fc = self.fleet.composition{

            if fc === comp{
                return count
            }

            if let wings = fc.children{
                for wing in wings{

                    count += 1
                    if wing === comp{
                        return count
                    }

                    if let squads = wing.children{
                        for squad in squads{

                            count += 1
                            if squad === comp{
                                return count
                            }
                        }
                    }

                }
            }

        }

        return -1

    }

    func sectionToComposition(section : Int) -> EveFleet.FleetComposition?{

        var count = 0

        if let fc = self.fleet.composition {

            if section == count{
                return fc
            }

            if let wings = fc.children {
                for wing in wings{

                    count += 1

                    if section == count {
                        return wing
                    }

                    if let squads = wing.children {
                        for squad in squads {
                            count += 1
                            if count == section {
                                return squad
                            }
                        }

                    }
                }
            }

        }

        return nil
    }

    func totalSquadsAndWings() -> Int{

        var count = 0
        if let fc = self.fleet.composition {
            count += 1
            if let wings = fc.children {
                for wing in wings {
                    count += 1
                    if let squads = wing.children {
                        count += squads.count
                    }
                }
            }
        }

        return count

    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return totalSquadsAndWings()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let comp = sectionToComposition(section: section){
            return comp.members.count
        }

        return 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "fleetHeader") as? FleetHeaderView{

            header.hideAdd()
            header.hideDelete()

            header.backgroundView = UIView(frame: header.bounds)
            header.backgroundView!.backgroundColor = .white

            if let comp = sectionToComposition(section: section){

                header.composition = comp
                header.delegate = self

                header.compositionLabel.text = comp.name

                if comp.position == .Wing{
                    header.compositionLabel.text = "- \(comp.name)"
                }else if comp.position == .Squad{
                    header.compositionLabel.text = "-- \(comp.name)"
                }

                if comp.position == .Wing || comp.position == .Fleet{
                    header.compositionLabel.font = UIFont.boldSystemFont(ofSize: header.compositionLabel.font.pointSize)
                }else{
                    header.compositionLabel.font = UIFont.systemFont(ofSize: header.compositionLabel.font.pointSize)
                }

                if self.fleetTable.isEditing {


                    if !comp.hasMembers() {
                        header.showDelete()
                    }

                    if comp.position == .Wing || comp.position == .Fleet {
                        header.showAdd()
                    }

                    if comp.position == .Fleet {
                        header.hideDelete()
                    }

                }


            }


            return header

        }

        return nil



    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fleetCell", for: indexPath)

        cell.textLabel?.text = nil
        cell.imageView?.af_cancelImageRequest()
        cell.imageView?.image = nil

        if let comp = sectionToComposition(section: indexPath.section) {

            let member = comp.members[indexPath.row]

            cell.textLabel?.text = member.name

            let placeholder = UIImage(named: "characterPlaceholder64.jpg")!.af_imageScaled(to: CGSize(width: 43, height: 43)).af_imageRoundedIntoCircle()

            let char = EveCharacter(member.character_id!)
            char.name = member.name

            let filter = ScaledToSizeCircleFilter(size: CGSize(width: 43, height: 43))
            cell.imageView?.af_setImage(withURL: char.imageURL(size: cell.imageView!.sizeForImage()), placeholderImage: placeholder, filter: filter)

            //cell.detailTextLabel?.text = "\(member.ship_type_id!) - \(member.solar_system_id)"

            if let ship = member.ship, let system = member.system {
                cell.detailTextLabel?.text = "\(ship.name) - \(system.name)"
            }

        }

        return cell
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {

        if let comp = self.sectionToComposition(section: indexPath.section) {
            let member = comp.members[indexPath.row]

            if member.role_name!.range(of: "(Boss)") != nil || member.character_id == self.character.id{
                return .none
            }
        }

        return .delete

    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        guard
                var from = self.sectionToComposition(section: sourceIndexPath.section),
                var destination = self.sectionToComposition(section: destinationIndexPath.section)
                else{
                    return
        }

        let moved = from.members[sourceIndexPath.row]

        self.startAnimating()

        self.fleet.moveMember(member: moved, from: from, to: destination) {
            self.fleetTable.reloadData()
            self.stopAnimating()

        }

    }


    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let member = self.sectionToComposition(section: indexPath.section)?.members[indexPath.row] {
                self.startAnimating()
                self.fleet.removeMember(member: member) {
                    self.fleetTable.reloadRows(at: [indexPath], with: .fade)
                    self.stopAnimating()
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension FleetViewController : UITabBarDelegate{

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        debugPrint(item)
    }

}

extension FleetViewController : FleetHeaderDelegate{

    func addToComposition(_ composition: EveFleet.FleetComposition) {

        debugPrint("Add \(composition.name)")

        self.startAnimating()

        switch composition.position{

            case .Fleet:
                self.fleet.addWing(fc: composition){ wingId in

                    if wingId > 0 {
                        self.fleetTable.reloadData()
                    }

                    self.stopAnimating()
                }
            break
            case .Wing:
                self.fleet.addSquad(wing: composition){ squadId in
                    if squadId > 0 {
                        self.fleetTable.reloadData()
                    }
                    self.stopAnimating()
                }
            break
            default:
            break

        }

    }

    func removeComposition(_ composition: EveFleet.FleetComposition) {

        let pos = self.compositionToSection(composition)

        debugPrint("Deleting: \(composition.id)")

        guard pos >= 0 else{
            return
        }

        let set = IndexSet(integer: pos)

        self.startAnimating()

        switch composition.position{
            case .Wing:
                self.fleet.removeWing(wing: composition){ removed in

                    if removed {
                        self.fleetTable.reloadData()
                    }

                    self.stopAnimating()

                }
                break
            case .Squad:
                self.fleet.removeSquad(squad: composition){ removed in

                    if removed {
                        self.fleetTable.reloadData()
                    }

                    self.stopAnimating()

                }
                break
            default:
                break
        }

    }

}
