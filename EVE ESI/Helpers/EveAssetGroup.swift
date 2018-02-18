//
// Created by Tristan Pollard on 2018-02-14.
// Copyright (c) 2018 Sumo. All rights reserved.
//

import Foundation

class EveAssetGroup : Location{

    var location_name: String = ""
    var location_id : Int64
    var location_type : String

    var assets : [EveAsset]

    init( _ location_id : Int64, type : String){
        self.location_id = location_id
        self.location_type = type
        assets = [EveAsset]()
    }

    func addAsset(asset : EveAsset){
        self.assets.append(asset)
    }

}
