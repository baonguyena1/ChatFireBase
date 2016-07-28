//
//  Extentions.swift
//  ChatFireBase
//
//  Created by Bao Nguyen on 7/28/16.
//  Copyright © 2016 baon. All rights reserved.
//

import UIKit

let imageCache = NSCache()

extension UIImageView {
    func loadImageUsingCacheWithUrlString(urlString: String) {
        self.image = nil
        let url = NSURL(string: urlString)
        
        if let cacheImage = imageCache.objectForKey(urlString) as? UIImage {
            self.image = cacheImage
            return
        }
        
        NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
            if (error != nil) {
                print(error)
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString)
                    self.image = downloadedImage
                }
            })
        }).resume()
    }
}
