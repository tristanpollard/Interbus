//
// Created by Tristan Pollard on 2017-10-02.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit

class EvePlayerOwned : Nameable {

    var id: Int64 = 0
    var name: String = ""

    enum PlayerTypes : String{
        case alliance, corporation, character, unknown
    }

//    var id : Int64!
//    var name : String?
    var imageEndpoint : String?
    var imageExtension : String = "png"
    var type : PlayerTypes = .unknown

    var validImageSizes = [32,64,128,256,512]

    func imageURL(size: Int) -> URL{

        var imageSize = size
        if !self.validImageSizes.contains(size){
            imageSize = validImageSizes.max()!
        }

        return URL(string: "https://image.eveonline.com/\(self.imageEndpoint!)/\(self.id)_\(imageSize).\(self.imageExtension)")!
    }

    func getPlaceholder(size: Int) -> UIImage{

        var imageSize = size
        if !self.validImageSizes.contains(size){
            imageSize = validImageSizes.max()!
        }

        return UIImage(named: "\(self.imageEndpoint!)Placeholder\(imageSize).\(self.imageExtension)")!

    }

    func load(completionHandler: @escaping() -> ()){

    }

}
