//
// Created by Tristan Pollard on 2018-02-15.
// Copyright (c) 2018 Sumo. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class EveStructure {

    var structure_id : Int64
    var name = ""
    var valid = false

    init(_ structure_id : Int64){
        self.structure_id = structure_id
        assert(self.structure_id > 0, "Structure ID <= 0")
    }

    func loadStructure(token: SSOToken, completionHandler: @escaping() -> ()){

        let esi = ESIClient.sharedInstance

        if let structure = loadStructureFromCoreData(){

            assert(structure.structure_id > 0, "NIL Structure ID")

            var found: StructureAttempts?
            if let attempts = structure.attempts {
                for attempt in attempts {
                    if let a = attempt as? StructureAttempts {
                        if a.character_id == token.character_id {
                            found = a
                            break
                        }
                    }
                }
            }

            if let f = found{
                if !f.valid{ //if the character is not on ACL
                    //TODO maybe update with a valid char
                    self.name = structure.name!
                    self.valid = structure.valid
                    completionHandler()
                    return
                }
            }


        }

        esi.invoke(endPoint: "/universe/structures/\(self.structure_id)", token: token, showErrors: false){ response in

            if response.statusCode == 403{ //we are forbidden from accessing (not on acl)

                if !self.valid {
                    self.name = "Unknown - \(self.structure_id)"
                }
                self.saveStructure(token: token, valid: false)

            } else if response.statusCode == 200, let structure = response.result as? [String:Any]{

                if let name = structure["name"] as? String{
                    self.name = name
                    self.valid = true
                    self.saveStructure(token: token, valid: true)
                }

            }

            completionHandler()

        }

    }

    func saveStructure(token : SSOToken, valid : Bool){
        let parentContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = parentContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Structure")
        let predicate = NSPredicate(format: "structure_id = '\(self.structure_id)'")
        fetchRequest.predicate = predicate
        do {
            let fetch = try context.fetch(fetchRequest)

            if fetch.count > 0 {

                let structure = fetch[0] as! Structure
                structure.name = self.name
                structure.valid = self.valid

                var found : StructureAttempts?
                if let attempts = structure.attempts {
                    for attempt in attempts {
                        if let a = attempt as? StructureAttempts {
                            if a.character_id == token.character_id {
                                found = a
                                break
                            }
                        }

                    }
                }

                if found == nil{
                    debugPrint("NOT FOUND")
                    let newAttempt = StructureAttempts(context: context)
                    newAttempt.character_id = token.character_id!
                    newAttempt.valid = valid
                    newAttempt.last_attempt = NSDate()
                    structure.addToAttempts(newAttempt)
                }else{
                    debugPrint("FOUND")
                    found!.last_attempt = NSDate()
                }

                do{
                    try context.save()
                    try parentContext.save()
                } catch {
                    debugPrint("ERROR: \(error)")
                }
            }else{
                insertStructure(token: token, valid: valid)
            }
        }
        catch
        {
            print("Error fetching: \(error)")
        }
    }

    func insertStructure(token: SSOToken, valid : Bool = false){

        debugPrint("Inserting structure...")
        let parentContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = parentContext

        let structure = Structure(context: context)

        structure.structure_id = self.structure_id
        structure.name = self.name
        structure.valid = self.valid

        let attempt = StructureAttempts(context: context)
        attempt.character_id = token.character_id!
        attempt.valid = valid
        attempt.last_attempt = NSDate()

        structure.addToAttempts(attempt)

        do{
            try context.save()
            try parentContext.save()
        } catch {
            debugPrint("ERROR: \(error)")
        }
    }

    func loadStructureFromCoreData() -> Structure?{
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Structure")
        let predicate = NSPredicate(format: "structure_id = '\(self.structure_id)'")

        fetchRequest.predicate = predicate
        do {
            let fetch = try context.fetch(fetchRequest)

            if fetch.count > 0{
                let structure = fetch[0] as! Structure
                return structure
            }

        } catch {
            print("Error fetching: \(error)")
        }

        return nil
    }

}
