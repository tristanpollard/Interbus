//
// Created by Tristan Pollard on 2017-10-03.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import ObjectMapper

class TransformDate : TransformType{

    typealias Object = Date
    typealias JSON = String

    func transformToJSON(_ value: Date?) -> String? {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return df.string(from: value!)
    }

    func transformFromJSON(_ value: Any?) -> Date? {
        if let val = value as? String{
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            return df.date(from: val)
        }
        return nil
    }

}
