//
//  WebImageManager.swift
//  StarWarsDirectory
//
//  Created by Toby Youngberg on 3/11/17.
//  Copyright © 2017 Toby Youngberg. All rights reserved.
//

import UIKit

class WebImageManager {
    static let shared = WebImageManager()
    
    let imageCache = NSCache<AnyObject, AnyObject>()
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    func getImage(url: URL, completion: ((_ image : UIImage?, _ url: URL, _ wasCached: Bool)->())?) {
        if let image = imageCache.object(forKey: url as AnyObject) as? UIImage {
            completion?(image, url, true)
            return
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion?(nil, url, false)
                return
            }
            if let image = UIImage(data: data) {
                self.imageCache.setObject(image, forKey: url as AnyObject)
                completion?(image, url, false)
            }
        }
        task.resume()
    }
}
