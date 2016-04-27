//
//  PinObject.swift
//  Virtual Tourist
//
//  Created by Sergey Prybysh on 4/23/16.
//  Copyright © 2016 Sergey Prybysh. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class PinObject: NSManagedObject {
    
    struct Keys {
        static let lat = "lat"
        static let long = "long"
    }
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var images: [ImageObject]
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("PinObject", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        self.latitude = dictionary[Keys.lat] as! Double
        self.longitude = dictionary[Keys.long] as! Double
    }
}
