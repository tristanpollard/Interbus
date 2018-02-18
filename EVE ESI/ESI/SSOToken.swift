//
// Created by Tristan Pollard on 2017-09-29.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class SSOToken {

    var access_token : String?
    var refresh_token : String?
    var token_type : String?
    var expires : Date?
    var character_id : Int64?
    var character_name : String?
    var scopes : [String]?

    var characterDidUpdate:(()->Void)?

    let esi = ESIClient.sharedInstance
    let refreshTime = 30 //30 seconds
    var inRefresh = false

    init(response: ESIResponse){
        updateToken(response: response){

        }
    }

    init(coreData: EVESSOToken){
        self.access_token = coreData.access_token
        self.refresh_token = coreData.refresh_token
        self.token_type = coreData.token_type
        self.expires = coreData.expires as! Date
        self.character_id = coreData.character_id
        self.character_name = coreData.character_name
        self.scopes = coreData.scopes!.components(separatedBy: " ")
    }

    func getMissingScopes() -> Set<String>{
        let checkScopes : Set<String> = Set(self.scopes!)
        var requiredScopes : Set<String> = Set(ESIClient.scopes)

        requiredScopes.subtract(checkScopes)

        return requiredScopes
    }

    func hasAllScopes() -> Bool{

        if getMissingScopes().count > 0{
            return false
        }

        return true
    }

    func updateToken(response: ESIResponse, completionHandler: @escaping() -> ()){

        if let data = response.result as? [String:Any] {
            if let access_token = data["access_token"] as? String {
                self.access_token = access_token
            }
            if let refresh_token = data["refresh_token"] as? String {
                self.refresh_token = refresh_token
            }
            if let token_type = data["token_type"] as? String {
                self.token_type = token_type
            }
            if let expires_in = data["expires_in"] as? Int {
                self.expires = Date().addingTimeInterval(TimeInterval(expires_in))
            }
            self.updateCharacter(){
                self.saveToken()
                completionHandler()
            }
        }
    }

    func updateCharacter(completionHandler: @escaping() -> ()){

        self.esi.invoke(url: ESIClient.loginURI, endPoint: "/oauth/verify", token: self){ response in
            if let response = response.result as? [String:AnyObject]{
                if let character_id = response["CharacterID"] as? Int64{
                    self.character_id = character_id
                }
                if let name = response["CharacterName"] as? String{
                    self.character_name = name
                }
                if let scopes = response["Scopes"] as? String{
                    self.scopes = scopes.components(separatedBy: " ")
                }
            }
            self.characterDidUpdate?()
            completionHandler()
        }
    }

    //TODO if multiple requests fire at same time, it can lock up.
    func refreshIfNeeded(completionHandler: @escaping() -> ()){
        let now = Date().addingTimeInterval(TimeInterval(self.refreshTime))
        if now > self.expires!{
            print("Refreshing token for: \(self.character_name!)")
            self.refresh(){
                completionHandler()
            }
        }else{
            completionHandler()
        }
    }

    func refresh(completionHandler: @escaping() -> ()){
        self.esi.refreshToken(token: self){
            completionHandler()
        }
    }

    func authorizationHeader() -> String{
        return "Bearer \(self.access_token!)"
    }

    func saveToken(){

        debugPrint("SAVING TOKEN")

        let parentContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = parentContext

        let fetchRequest:NSFetchRequest<EVESSOToken> = NSFetchRequest.init(entityName: "EVESSOToken")
        let predicate = NSPredicate(format: "character_id = '\(self.character_id!)'")
        fetchRequest.predicate = predicate
        do {
            let fetch = try context.fetch(fetchRequest)

            if fetch.count > 0 {
                let token = fetch[0]
                token.access_token = self.access_token!
                token.refresh_token = self.refresh_token!
                token.character_id = self.character_id!
                token.character_name = self.character_name!
                token.expires = self.expires! as NSDate
                token.token_type = self.token_type!
                token.scopes = self.scopes!.joined(separator: " ")
                do{
                    debugPrint("ATTEMPTING SAVE")
                        try context.save()
                        try parentContext.save()
                    debugPrint("SAVED")
                }
                catch
                {
                    print("Error saving: \(error)")
                }
            }else{
                debugPrint("INSERTING TOKEN")
                self.insertToken()
            }
        }
        catch
        {
            print("Error fetching: \(error)")
        }
    }

    func insertToken(){
        let parentContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = parentContext
        let token = EVESSOToken(context: context)
        token.access_token = self.access_token!
        token.refresh_token = self.refresh_token!
        token.character_id = self.character_id!
        token.character_name = self.character_name!
        token.expires = self.expires! as NSDate
        token.token_type = self.token_type!
        token.scopes = self.scopes!.joined(separator: " ")
        do{
            try context.save()
            try parentContext.save()
        } catch {
            debugPrint("ERROR: \(error)")
        }
    }

    func deleteToken(){
        let parentContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = parentContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "EVESSOToken")
        let predicate = NSPredicate(format: "character_id = '\(self.character_id!)'")
        fetchRequest.predicate = predicate
        do {
            if let fetch = try? context.fetch(fetchRequest) as! [NSManagedObject]{
                for tok in fetch{
                    context.delete(tok)
                }
                try context.save()
                try parentContext.save()
             }
        }
        catch
        {
            print("Error fetching: \(error)")
        }
    }

    static func loadAllTokens() -> [SSOToken]{
        var ssoTokens = [SSOToken]()
        do {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let tokens = try context.fetch(EVESSOToken.fetchRequest())
            for token in tokens{
                if let token = token as? EVESSOToken {
                    ssoTokens.append(SSOToken(coreData: token))
                }
            }
        }catch {
            print("Error fetching token data from CoreData")
        }

        return ssoTokens

    }

}
