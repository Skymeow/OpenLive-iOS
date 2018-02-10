//
//  UIImage&Cache.swift
//  Streaming
//
//  Created by Sky Xu on 1/22/18.
//  Copyright © 2018 Sky Xu. All rights reserved.
//

import Foundation
import UIKit

var imageCache = NSCache<AnyObject, AnyObject>()


// call this when you want to set img: ImgView.loadImageFromUrlString(urlString: self.Url!)


// custom class to convert url to img and cache them
class CustomImageView: UIImageView {
    
    var imageUrlString: String?
    
    func loadImageFromUrlString(urlString: String) {
        let url = URL(string: urlString)!
        imageUrlString = urlString
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = imageFromCache
            return
        }
        
        //   networking request to convert url to img
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let err = error {
                print(err)
                return
            }
            
            guard let imageData = data else {return}
            
            // update imgView
            DispatchQueue.main.async {
                guard let imageToCache = UIImage(data: imageData) else {return}
                
                if self.imageUrlString == urlString {
                    self.image = imageToCache
                }
                imageCache.setObject(imageToCache, forKey: urlString as AnyObject)
                
            }
            }.resume()
    }
}

