//
// Created by Tristan Pollard on 2017-10-03.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}