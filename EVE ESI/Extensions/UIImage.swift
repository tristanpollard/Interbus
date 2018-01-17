//
// Created by Tristan Pollard on 2017-09-27.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit

extension UIImageView {

    func sizeForImage(maxImageSize : Int = 256) -> Int{
        let imageSizes = [ 32, 64, 128, 256, 512]
        let maxSize = Int(max(self.bounds.size.width, self.bounds.size.height))

        if maxSize > maxImageSize{
            return maxImageSize
        }

        if maxSize > imageSizes.max()!{
            return imageSizes.max()!
        }

        let size = imageSizes.filter({ $0 >= maxSize}).min()
        return size!

    }


    func borderCircle(color: UIColor){
        self.layer.borderWidth = 3.0
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
        self.layer.borderColor = color.cgColor
    }

}
