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
    
    struct Keys {
        static let imageURLString = "imageURLString"
    }
    
    @NSManaged var imageURLString: String
    @NSManaged var pin: PinObject?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("ImageObject", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        self.imageURLString = dictionary[Keys.imageURLString] as! String
    }
}