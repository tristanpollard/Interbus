//
// Created by Tristan Pollard on 2017-09-29.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation

extension String {
//: ### Base64 encoding a string
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }

//: ### Base64 decoding a string
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    func lowerToUpper() -> String{
        var temp = NSString(string: self)
        temp = NSString(string: temp.replacingOccurrences(of: "_", with: " "))
        return temp.capitalized
    }
}
