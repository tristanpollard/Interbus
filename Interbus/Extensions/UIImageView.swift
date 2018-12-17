//
// Created by Tristan Pollard on 2018-12-14.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import UIKit
import SDWebImage

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
        self.layer.borderWidth = CGFloat(borderWidth)
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.masksToBounds = true
        self.layer.borderColor = color.cgColor
        self.clipsToBounds = true
    }

    func fetchAndSetImage(eve: EVEImage, completion: @escaping () -> () = {
    }) {
        let url = URL(string: eve.getImageUrl(size: self.sizeForImage()))
        self.image = nil
        self.sd_cancelCurrentImageLoad()
        self.sd_setImage(with: url, placeholderImage: eve.placeholder) { (image, error, cacheType, imageURL) in
            completion()
        }

//        if let cached = cache.object(forKey: NSString(string: url)) {
//            print("Cache:", url)
//            self.image = cached
//            completion()
//            return
//        }
//        eve.fetchImage(url) { image in
//            print("Fetched:", url)
//            DispatchQueue.main.async {
//                if let downloaded = downloadedUrl, url == downloaded {
//                    self.image = image
//                }
//                if let img = image {
//                    cache.setObject(img, forKey: NSString(string: url))
//                }
//                completion()
//            }
//        }
    }
}
