//
//  ImageCache.swift
//  Virtual Tourist
//
//  Created by Sergey Prybysh on 5/14/16.
//  Copyright © 2016 Sergey Prybysh. All rights reserved.
//

import Foundation
import UIKit

class ImageCache {
    
    private var memoryCache = NSCache()
    
    func storeImageWithIdentifier(image: UIImage?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)
        
        //MARK: remove image if nil
        if image == nil {
            memoryCache.removeObjectForKey(path)
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            } catch _ {}
            
            return
        }
        
        //MARK: save image in cache
        memoryCache.setObject(image!, forKey: path)
        
        //MARK: save image in derictory
        let data = UIImagePNGRepresentation(image!)!
        data.writeToFile(path, atomically: true)
    }
    
    func getImageWithIdentifier(identifier: String?) -> UIImage? {
        
        // MARK: check if identifier is not nil or empty
        if identifier == nil || identifier! == "" {
            return nil
        }
        
        let path = pathForIdentifier(identifier!)
        
        // MARK: Try to get it from cache
        if let image = memoryCache.objectForKey(path) as? UIImage {
            return image
        }
        
        // MARK: Get it from documents
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }
}