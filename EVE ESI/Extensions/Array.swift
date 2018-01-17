//
// Created by Tristan Pollard on 2017-09-28.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import Alamofire

import Foundation
import Alamofire
import Charts

private let arrayParametersKey = "arrayParametersKey"

/// Extenstion that allows an array be sent as a request parameters
extension Array {
    /// Convert the receiver array to a `Parameters` object.
    func asParameters() -> Parameters {
        return [arrayParametersKey: self]
    }
}


/// Convert the parameters into a json array, and it is added as the request body.
/// The array must be sent as parameters using its `asParameters` method.
public struct ArrayEncoding: ParameterEncoding {

    /// The options for writing the parameters as JSON data.
    public let options: JSONSerialization.WritingOptions

    /// Creates a new instance of the encoding using the given options
    ///
    /// - parameter options: The options used to encode the json. Default is `[]`
    ///
    /// - returns: The new instance
    public init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }

    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()

        guard let parameters = parameters,
              let array = parameters[arrayParametersKey] else {
            return urlRequest
        }


        do {
            let data = try JSONSerialization.data(withJSONObject: array, options: options)

            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }

            urlRequest.httpBody = data

        } catch {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }

        return urlRequest
    }
}


extension Array where Element == EveClone{

    func loadImplantNames(completionHandler: @escaping() -> ()){

        let ids : [Int64] = self.map({$0.implant_ids!}).flatMap({$0})
        ids.loadNames(){ names in
            for name in names{

            }
        }

        completionHandler()
    }
}

extension Array where Element : Nameable{

    func loadNames(completionHandler: @escaping() -> ()){

        let ids : [Int64] = Set(self.map({$0.id})).map({$0})
        let esi = ESIClient.sharedInstance

        if ids.count == 0{
            completionHandler()
            return
        }

        esi.invoke(endPoint: "/universe/names/", httpMethod: .post, parameters: ids.asParameters(), parameterEncoding: ArrayEncoding()){ response in
            if let types = response.result as? [[String:Any]]{
                for type in types{
                    if let type_name = type["name"] as? String, let type_id = type["id"] as? Int64{
                        var nameables = self.filter({$0.id == type_id})
                        for i in 0..<nameables.count{
                            nameables[i].name = type_name
                        }
                    }
                }
            }
            completionHandler()
        }
    }
}


extension Array where Element == EveMail{

    func loadAllSenders(completionHandler: @escaping() -> ()){

        let ids : [Int64] = self.map({$0.from_id!})
        ids.loadCharacterNames(){ names in
            for mail in self{
                if let found = names[mail.from_id!] {
                    mail.from?.name = found.name
                }
            }
            completionHandler()
        }
    }

}

extension Array where Element == EveJournalEntry {

    func loadNames(completionHandler: @escaping([Int64: EvePlayerOwned]) -> ()) {

        let esi = ESIClient.sharedInstance
        let group = DispatchGroup()
        var names = [Int64: EvePlayerOwned]()
        var corps: [Int64] = filter({ $0.first_party_type != nil && $0.first_party_type! == "corporation" }).map({ $0.first_party_id! })
        var chars: [Int64] = filter({ $0.first_party_type != nil && $0.first_party_type! == "character" }).map({ $0.first_party_id! })
        corps += filter({ $0.second_party_type != nil && $0.second_party_type! == "corporation" }).map({ $0.second_party_id! })
        chars += filter({ $0.second_party_type != nil && $0.second_party_type! == "character" }).map({ $0.second_party_id! })

        group.enter()
        corps.loadCorporationNames() { corpNames in
            names.merge(dict: corpNames)
            group.leave()
        }

        group.enter()
        chars.loadCharacterNames() { charNames in
            names.merge(dict: charNames)
            group.leave()
        }

        group.notify(queue: .main) {
            completionHandler(names)
        }

    }
}

extension Array where Element == Int64 {

    func loadNames(completionHandler: @escaping([Int64:String]) -> ()){

        let esi = ESIClient.sharedInstance
        var names = [Int64:String]()

        let ids = Set(self).map({$0})

        esi.invoke(endPoint: "/universe/names/", httpMethod: .post, parameters: ids.asParameters(), parameterEncoding: ArrayEncoding()){ response in
            debugPrint(response.rawResponse)
            if let results = response.result as? [[String:Any]]{
                for result in results{
                    if let name = result["name"] as? String, let id = result["id"] as? Int64{
                        names[id] = name
                    }
                }
            }
            completionHandler(names)
        }

    }

    func loadCharacterNames(completionHandler: @escaping([Int64:EveCharacter]) -> ()){
        let esi = ESIClient.sharedInstance
        var names = [Int64:EveCharacter]()

        let parameters : Parameters = ["character_ids" : map({String($0)}).joined(separator: ",")]
        esi.invoke(endPoint: "/characters/names", parameters: parameters){ response in

            if let characters = response.result as? [[String:AnyObject]]{
                for char in characters {
                    if let name = char["character_name"] as? String{
                        if let id = char["character_id"] as? Int64{
                            let char = EveCharacter(character_id: id)
                            char.name = name
                            names[id] = char
                        }
                    }
                }

                completionHandler(names)

            }
        }
    }

    func loadCorporationNames(completionHandler: @escaping([Int64:EveCorporation]) -> ()){

        let esi = ESIClient.sharedInstance
        var names = [Int64:EveCorporation]()

        let parameters : Parameters = ["corporation_ids" : map({String($0)}).joined(separator: ",")]
        esi.invoke(endPoint: "/corporations/names", parameters: parameters){ response in

            if let corporations = response.result as? [[String:AnyObject]]{
                for corp in corporations{
                    if let name = corp["corporation_name"] as? String{
                        if let id = corp["corporation_id"] as? Int64{
                            let corp = EveCorporation(corporation_id: id)
                            corp.name = name
                            names[id] = corp
                        }
                    }
                }

                completionHandler(names)

            }
        }
    }
}
