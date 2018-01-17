//
// Created by Tristan Pollard on 2017-10-11.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import Alamofire

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

    func saveGroup(group: [String:Any]){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let groupContext = Group(context: context)
        if let category = group["category_id"] as? Int64, let gId = group["group_id"] as? Int64,
           let name = group["name"] as? String, let pub = group["published"] as? Bool, let types = group["types"] as? [Int64]{

            print("Saving: \(name)")
            groupContext.category_id = category
            groupContext.group_id = gId
            groupContext.name = name
            groupContext.published = pub

            for typeid in types{
                let type = Type(context: context)
                type.type_id = typeid
                groupContext.addToTypes(type)
            }

            do{
                try context.save()
            }catch{
                print("ERROR SAVING")
            }
        }
    }

}
