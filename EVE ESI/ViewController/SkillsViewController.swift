//
// Created by Tristan Pollard on 2017-10-10.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import CoreData

class SkillsViewController : UICharacterViewController, NVActivityIndicatorViewable{

    @IBOutlet weak var tableView: UITableView!
    var groupedSkills = [String:[EveSkill]]()
    var sortedKeys = [String]()

    override func viewDidLoad() {

        self.startAnimating()

        self.character.loadSkills(){
            self.groupSkills()
            self.tableView.reloadData()
            self.stopAnimating()
        }

    }

    func groupSkills(){

        groupedSkills = self.groupsForSkills()
        for (key, value) in self.groupedSkills {
            self.groupedSkills[key] = value.sorted(by: {$0.name < $1.name})
        }
        self.sortedKeys = self.groupedSkills.keys.sorted(by: {$0 < $1})
    }

    func keyForSection(section: Int) -> String{
        let keys = Array(groupedSkills.keys)
        let key = keys[section]
        return key
    }

    func groupsForSkills() -> [String:[EveSkill]]{

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Type")
        let predicate = NSPredicate(format: "type_id IN %@", self.character.skills.map({$0.id}))

        fetchRequest.predicate = predicate
        do {
            let fetched = try context.fetch(fetchRequest)

            for fetch in fetched{
                if let type = fetch as? Type {
                    let group = type.group!
                    if groupedSkills[group.name!] == nil {
                        groupedSkills[group.name!] = [EveSkill]()
                    }
                    groupedSkills[group.name!]! += self.character.skills.filter({$0.id == type.type_id})
                }
            }


        }catch{
            print("no type found")
        }

        return groupedSkills
    }

}

extension SkillsViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedKeys[section]
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sortedKeys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groupedSkills[sortedKeys[section]]!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "skillCell", for: indexPath)

        let skill = groupedSkills[sortedKeys[indexPath.section]]![indexPath.row]
        cell.textLabel?.text = skill.name
        cell.detailTextLabel?.text = String(skill.current_skill_level!)


        return cell
    }
}
