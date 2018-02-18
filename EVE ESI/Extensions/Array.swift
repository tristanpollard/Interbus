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

        let group = DispatchGroup()

        self.map({
            group.enter()
            $0.implants.loadNames{
                group.leave()
            }})

        group.notify(queue: .main){
            completionHandler()
        }

    }
}

extension Array where Element : Nameable{

    func loadNames(completionHandler: @escaping() -> ()){

        let ids : [Int64] = Set(self.map({$0.id})).map({$0})

        if ids.count == 0{
            completionHandler()
            return
        }

        let group = DispatchGroup()


        stride(from: 0, to: ids.count, by: 200 ).map { sIndex in

            var eIndex = self.index(sIndex, offsetBy: 200)
                if eIndex > ids.count {
                    eIndex = ids.count
                }


                let arr = ids[sIndex ..< eIndex]
                let idArr = arr.map{$0}

                group.enter()
                idArr.loadNames{ names in

                    for name in names{
                        let toNames = self.filter{$0.id == name.key}
                        for var toName in toNames{
                            toName.name = name.value
                        }
                    }

                    group.leave()
                }

        }

        group.notify(queue: .main){
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
        var journalNames = [Int64: EvePlayerOwned]()
        //TODO write a custom loop for efficiency
        var corps: [Int64] = filter({ $0.first_party_type != nil && $0.first_party_type! == "corporation" }).map({ $0.first_party_id! })
        var chars: [Int64] = filter({ $0.first_party_type != nil && $0.first_party_type! == "character" }).map({ $0.first_party_id! })
        corps += filter({ $0.second_party_type != nil && $0.second_party_type! == "corporation" }).map({ $0.second_party_id! })
        chars += filter({ $0.second_party_type != nil && $0.second_party_type! == "character" }).map({ $0.second_party_id! })


        group.enter()
        corps.loadNames{ names in
            for name in names {
                let corp = EveCorporation(corporation_id: name.key)
                corp.name = name.value
                journalNames[name.key] = corp
            }
            group.leave()
        }

        group.enter()
        chars.loadNames{ names in
            for name in names{
                let char = EveCharacter(name.key)
                char.name = name.value
                journalNames[name.key] = char
            }
            group.leave()
        }


        group.notify(queue: .main) {
            completionHandler(journalNames)
        }

    }
}

extension Array where Element == Int64 {

    func loadNames(completionHandler: @escaping([Int64:String]) -> ()){

        let esi = ESIClient.sharedInstance
        var names = [Int64:String]()

        let ids = Set(self).map({$0})

        if ids.count == 0{
            completionHandler([:])
            return
        }

        esi.invoke(endPoint: "/universe/names/", httpMethod: .post, parameters: ids.asParameters(), parameterEncoding: ArrayEncoding()){ response in

            if let results = response.result as? [[String:Any]]{
                for result in results{
                    if let name = result["name"] as? String, let id = result["id"] as? Int64{
                        names[id] = name

                    }
                }

            }else{
                debugPrint(response.rawResponse)
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
                            let char = EveCharacter(id)
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
