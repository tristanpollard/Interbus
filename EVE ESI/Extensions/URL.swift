//
// Created by Tristan Pollard on 2017-09-29.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation

extension URL {

    public var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true), let queryItems = components.queryItems else {
            return nil
        }

        var parameters = [String: String]()
        for item in queryItems {
            parameters[item.name] = item.value
        }

        return parameters
    }
}