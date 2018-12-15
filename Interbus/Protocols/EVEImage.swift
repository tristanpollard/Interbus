//
// Created by Tristan Pollard on 2018-12-14.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import Alamofire

protocol EVEImage {
    var imageEndpoint: String { get }
    var imageID: Int64 { get }
    var imageExtension: String { get }
}

extension EVEImage {
    func fetchImage(size: Int, completion: @escaping (UIImage?) -> ()) {
        let url = URL(string: "\(ESIClient.baseURI.image.rawValue)/\(self.imageEndpoint)/\(self.imageID)_\(size).\(self.imageExtension)")!
        print(url.absoluteURL)
        DispatchQueue.global(qos: .background).async {
            if let data = NSData(contentsOf: url) {
                let image = UIImage(data: data as Data)
                completion(image)
            }
        }
    }
}