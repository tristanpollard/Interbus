//
// Created by Tristan Pollard on 2018-02-17.
// Copyright (c) 2018 Sumo. All rights reserved.
//

import UIKit
import CoreData
import NVActivityIndicatorView

class FleetCompositionViewController : UICharacterViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var compositionTable: UITableView!

    var fleet : EveFleet{
        get{
            return self.character.fleet
        }
    }

    var groupings = [Group:[EveType]]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        self.tabBarController?.navigationItem.rightBarButtonItems = [refreshButton]

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
                self.refreshComposition()
                self.compositionTable.reloadData()
                self.stopAnimating()
            }
        }
    }

    func refreshComposition(){
        let ships = Set(fleet.members.flatMap{$0.ship_type_id}).flatMap{$0}
        self.groupings.removeAll()

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest : NSFetchRequest<Type> = NSFetchRequest(entityName: "Type")
        let predicate = NSPredicate(format: "type_id IN %@", ships)
        fetchRequest.predicate = predicate

        do {
            let fetch = try context.fetch(fetchRequest)

            for type in fetch{
                if let group = type.group{
                    self.groupings[group] = self.fleet.members.filter({$0.ship_type_id! == type.type_id}).map({$0.ship!})
                }
            }

        }catch{
            debugPrint("Error Fetching: \(error)")
        }
    }
}

extension FleetCompositionViewController : UITableViewDelegate, UITableViewDataSource{

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.groupings.keys.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.groupings.keys.sorted(by: {$0.name! < $1.name!})[section].name
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let key = self.groupings.keys.sorted(by: {$0.name! < $1.name!})[section]
        let types = self.groupings[key]!
        let rows = Set(types.flatMap{$0.type_id}).sorted{$0 < $1}

        return rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "compositionCell", for: indexPath)

        let key = self.groupings.keys.sorted(by: {$0.name! < $1.name!})[indexPath.section]
        let types = self.groupings[key]!
        let rows = Set(types.flatMap{$0.type_id}).sorted{$0 < $1}
        let toFind = rows[indexPath.row]

        let ships = types.filter{$0.type_id == toFind}

        cell.textLabel?.text = "\(ships[0].name) - \(ships.count)"

        return cell
    }
}
