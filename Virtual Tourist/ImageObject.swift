//
//  ImageObject.swift
//  Virtual Tourist
//
//  Created by Sergey Prybysh on 4/23/16.
//  Copyright © 2016 Sergey Prybysh. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ImageObject: NSManagedObject {
    
    @NSManaged var imageURL: String
    @NSManaged var id: String
    @NSManaged var pin: PinObject?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(imageURL: String, imageId: String, context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("ImageObject", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        self.imageURL = imageURL
        self.id = imageId
    }
    
    var imageForPin: UIImage? {
        
        get {
            return ImageCache.sharedCache().getImageWithIdentifier(id)
        }
        
        set {
            return ImageCache.sharedCache().storeImageWithIdentifier(newValue, withIdentifier: id)
        }
    }
}