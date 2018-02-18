//
// Created by Tristan Pollard on 2017-10-11.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class GroupLoader {

    let esi = ESIClient.sharedInstance

    func loadAllGroupIds(page: Int = 1, gIds: [Int64] = [], completionHandler: @escaping([Int64]) -> ()){

        let params : Parameters = ["page" : page]
        esi.invoke(endPoint: "/universe/groups", parameters: params){ response in
            if let ids = response.result as? [Int64]{
                if ids.count > 0{
                    let combined = gIds + ids
                    self.loadAllGroupIds(page: page+1, gIds: combined, completionHandler: completionHandler)
                }else{
                    completionHandler(gIds)
                }
            }
        }

    }

    func loadAllGroupsFromIds(ids: [Int64]){
        for id in ids{
            esi.invoke(endPoint: "/universe/groups/\(id)/"){ response in
                if let group = response.result as? [String:Any]{
                    self.saveGroup(group: group)
                }
            }
        }
    }

    func loadAllGroupIdsFromCoreData() -> [Int64]{

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest:NSFetchRequest<Group> = NSFetchRequest.init(entityName: "Group")
        do {
            let fetch = try context.fetch(fetchRequest)

            let ids = fetch.map({$0.group_id})
            return ids

        }catch{
            debugPrint("Error fetching group ids: \(error)")
        }

        return []

    }

    func saveGroup(group: [String:Any]){
        let parentContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = parentContext
        if let category = group["category_id"] as? Int64, let gId = group["group_id"] as? Int64,
           let name = group["name"] as? String, let pub = group["published"] as? Bool, let types = group["types"] as? [Int64]{

            let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Group")
            let predicate = NSPredicate(format: "group_id = %i AND category_id = %i", argumentArray: [gId, category])
            fetchRequest.predicate = predicate
            do {
                let fetch = try context.fetch(fetchRequest)

                var group : Group
                if fetch.count > 0{
                    group = fetch[0] as! Group
                }else{
                    group = Group(context: context)
                }

                group.category_id = category
                group.group_id = gId
                group.name = name
                group.published = pub

                var typeArr = [Type]()
                if let ta = group.types?.allObjects as? [Type]{
                    typeArr = ta
                }

                for typeid in types {

                    var type : Type?

                    type = typeArr.first{$0.type_id == typeid}

                    if type == nil{
                        type = Type(context: context)
                        type!.type_id = typeid
                        group.addToTypes(type!)
                    }

                }

                try context.save()
                try parentContext.save()
            } catch {
                print("ERROR SAVING \(error)")
            }
        }
    }

}
