//
// Created by Tristan Pollard on 2017-10-11.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

protocol Nameable: class {

    var id: Int64 { get }
    var name: EveName? { get set }

}

extension Nameable {
    func fetchName(completionHandler: @escaping (EveName) -> ()) {
        let ids = [id]
        ids.fetchNames { names in
            let name = names.first {
                $0.key == self.id
            }
            if name != nil {
                self.name = name!.value
                completionHandler(name!.value)
            }
        }
    }
}

extension Array where Element == Int64 {
    func fetchNames(completion: @escaping ([Int64: EveName]) -> ()) {
        let esi = ESIClient.sharedInstance
        let group = DispatchGroup()

        let unique = Array(Set(self))

        var results: [Int64: EveName] = [:]

        stride(from: 0, to: unique.count, by: 200).forEach { sIndex in
            let end = self.index(sIndex, offsetBy: 200)
            let endIndex = Swift.min(end, unique.count)
            let items = Array(unique[sIndex..<endIndex])
            let options: [String: Any] = [
                "parameters": items.asParameters(),
                "encoding": ArrayEncoding()
            ]
            group.enter()
            esi.invoke(endPoint: "/v2/universe/names", httpMethod: .post, options: options) { response in
                if let result = response.result as? [[String: Any]] {
                    let items = Mapper<EveName>().mapArray(JSONArray: result)
                    items.forEach { value in
                        results[value.id] = value
                    }
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(results)
        }
    }
}

extension Array where Element: Nameable {
    func fetchNames(completion: @escaping () -> ()) {
        let ids: [Int64] = Set(self.map({ $0.id })).map({ $0 })

        if ids.count == 0 {
            completion()
            return
        }

        ids.fetchNames { names in
            names.forEach { key, value in
                self.filter {
                    $0.id == key
                }.forEach { item in
                    item.name = value
                }
            }
            completion()
        }
    }

}

private let arrayParametersKey = "arrayParametersKey"

/// Extenstion that allows an array be sent as a request parameters
extension Array {
    /// Convert the receiver array to a `Parameters` object.
    func asParameters() -> Parameters {
        return [arrayParametersKey: self]
    }
}

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