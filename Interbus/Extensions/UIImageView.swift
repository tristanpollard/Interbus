//
// Created by Tristan Pollard on 2018-12-14.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import UIKit

extension UIImageView {
    func sizeForImage(maxImageSize: Int = 256) -> Int {
        let imageSizes = [32, 64, 128, 256, 512]
        let maxSize = Int(max(self.bounds.size.width, self.bounds.size.height))

        if maxSize > maxImageSize {
            return maxImageSize
        }

        if maxSize > imageSizes.max()! {
            return imageSizes.max()!
        }

        let size = imageSizes.filter({ $0 >= maxSize }).min()
        return size!

    }

    func roundImageWithBorder(color: UIColor, borderWidth: Float = 2.0) {
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.masksToBounds = true
        self.layer.borderColor = color.cgColor
        self.clipsToBounds = true
    }

    func fetchAndSetImage(eve: EVEImage, completion: @escaping () -> ()) {
        eve.fetchImage(size: self.sizeForImage()) { image in
            DispatchQueue.main.async {
                self.image = image
                completion()
            }
        }
    }
}
