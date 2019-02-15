//
// Created by Tristan Pollard on 2017-09-29.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import KTVJSONWebToken
import KeychainAccess

enum TokenError: Error {
    case noAccessToken
    case noJWKSKey
    case validationError
    case tokenNotValidated
}

class SSOToken {

    var access_token: String? {
        didSet {
            if let id = character_id {
                keychain["\(id)_access"] = access_token
            }
        }
    }
    var refresh_token: String? {
        didSet {
            if let refreshToken = refresh_token, let id = character_id {
                keychain["\(id)_refresh"] = refreshToken
            }
        }
    }
    var token_type: String?
    var expires: Date?

    let esi = ESIClient.sharedInstance
    let refreshTime = 30 //30 seconds

    private let keychain = Keychain(service: "com.tristan.interbus")

    var jwt: JSONWebToken {
        get {
            return try! JSONWebToken(string: self.access_token!)
        }
    }

    fileprivate var validated: Bool = false

    var character_id: Int64? {
        get {
            if let sub = self.jwt.payload["sub"] as? String {
                let id = Int64(String(sub.split(separator: ":").last!))
                return id
            }
            return nil
        }
    }

    var scopes: [String]? {
        get {
            if let scopes = self.jwt.payload["scp"] as? [String] {
                return scopes
            }
            return nil
        }
    }

    var character_name: String? {
        get {
            if let name = self.jwt.payload["name"] as? String {
                return name
            }
            return nil
        }
    }

    init(response: ESIResponse) {
        try! updateToken(response: response) { error in

        }
    }

    init(coreData: EVESSOToken) {
//        self.access_token = coreData.access_token
//        self.refresh_token = coreData.refresh_token
        access_token = keychain["\(coreData.character_id)_access"]
        refresh_token = keychain["\(coreData.character_id)_refresh"]
        self.token_type = coreData.token_type
        self.expires = coreData.expires as! Date
    }

    func getMissingScopes() -> Set<String> {
        let checkScopes: Set<String> = Set(self.scopes!)
        var requiredScopes: Set<String> = Set(ESIClient.scopes)

        requiredScopes.subtract(checkScopes)

        return requiredScopes
    }

    func hasAllScopes() -> Bool {
        if getMissingScopes().count > 0 {
            return false
        }
        return true
    }

    func updateToken(response: ESIResponse, completion: @escaping (Error?) -> ()) throws {
        if let data = response.result as? [String: Any] {
            if let access_token = data["access_token"] as? String {
                self.access_token = access_token
            } else {
                completion(TokenError.noAccessToken)
                return
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

            self.validateToken { success in
                try! self.saveToken()
                completion(success ? nil : TokenError.validationError)
            }
        }
    }

    func validateToken(completion: @escaping (Bool) -> ()) {

        let jwt = self.jwt
        guard let kid = jwt.payload["kid"] as? String else {
            completion(false)
            return
        }

        self.esi.getRSAKey(kid: kid) { rsaKey in
            guard let key = rsaKey else {
                completion(false)
                return
            }

            let validator = RegisteredClaimValidator.expiration &
                    RegisteredClaimValidator.issuer &
                    RSAPKCS1Verifier(key: key, hashFunction: .sha256)

            let validationResult = validator.validateToken(jwt)
            guard case ValidationResult.success = validationResult else {
                //throw TokenError.validationError
                completion(false)
                return
            }

            self.validated = true
            completion(true)
        }
    }

    func refreshIfNeeded(completion: @escaping () -> ()) {
        let now = Date().addingTimeInterval(TimeInterval(self.refreshTime))
        if now > self.expires! {
            print("Refreshing token for: \(self.access_token!)")
            self.refresh() {
                completion()
            }
        } else {
            completion()
        }
    }

    func refresh(completionHandler: @escaping () -> ()) {
        self.esi.refreshToken(token: self) { response in
            try! self.updateToken(response: response) { error in
                print("Error:", error)
                completionHandler()
            }
        }
    }

    func authorizationHeader() -> String {
        return "Bearer \(self.access_token!)"
    }

    func saveToken() throws {


        guard self.validated else {
            throw TokenError.tokenNotValidated
        }

        let parentContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = parentContext

        let fetchRequest: NSFetchRequest<EVESSOToken> = NSFetchRequest.init(entityName: "EVESSOToken")
        let predicate = NSPredicate(format: "character_id = '\(self.character_id!)'")
        fetchRequest.predicate = predicate
        do {
            let fetch = try context.fetch(fetchRequest)

            if fetch.count > 0 {
                let token = fetch[0]
                token.expires = self.expires!
                token.token_type = self.token_type!
                token.character_id = self.character_id!
                do {
                    debugPrint("ATTEMPTING SAVE")
                    try context.save()
                    try parentContext.save()
                    debugPrint("SAVED")
                } catch {
                    print("Error saving: \(error)")
                }
            } else {
                debugPrint("INSERTING TOKEN")
                self.insertToken()
            }
        } catch {
            print("Error fetching: \(error)")
        }
    }

    func insertToken() {
        let parentContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = parentContext
        let token = EVESSOToken(context: context)
        token.expires = self.expires!
        token.token_type = self.token_type!
        token.character_id = self.character_id!
        do {
            try context.save()
            try parentContext.save()
        } catch {
            debugPrint("ERROR: \(error)")
        }
    }

    func deleteToken() {
        let parentContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = parentContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "EVESSOToken")
        let predicate = NSPredicate(format: "character_id = '\(self.character_id!)'")
        fetchRequest.predicate = predicate
        do {
            if let fetch = try? context.fetch(fetchRequest) as! [NSManagedObject] {
                for tok in fetch {
                    context.delete(tok)
                }
                try context.save()
                try parentContext.save()
            }
        } catch {
            print("Error fetching: \(error)")
        }
    }

    static func loadAllTokens() -> [SSOToken] {
        var ssoTokens = [SSOToken]()
        do {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let tokens = try context.fetch(EVESSOToken.fetchRequest())
            for token in tokens {
                if let token = token as? EVESSOToken {
                    ssoTokens.append(SSOToken(coreData: token))
                }
            }
        } catch {
            print("Error fetching token data from CoreData")
        }

        return ssoTokens

    }
}
