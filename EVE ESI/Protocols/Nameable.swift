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

    func loadName(completionHandler: @escaping(String) -> ()){

        let ids = [id]
        ids.loadNames{ names in
            let name = names.first{$0.key == self.id}
            if name != nil{
                completionHandler(name!.value)
                return
            }
            completionHandler("")
        }

    }

}
