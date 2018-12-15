//
// Created by Tristan Pollard on 2018-12-13.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation

extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else {
            return nil
        }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}