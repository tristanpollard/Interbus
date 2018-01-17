//
// Created by Tristan Pollard on 2017-10-11.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation

protocol Nameable {

    var id : Int64 { get }
    var name : String { get set }

}

extension Nameable {

    func imageURL(size: Int = 64) -> URL{
        return URL(string: "https://image.eveonline.com/Type/\(self.id)_\(size).png")!
    }

}
