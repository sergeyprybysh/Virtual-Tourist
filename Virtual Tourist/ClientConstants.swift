//
//  ClientConstants.swift
//  Virtual Tourist
//
//  Created by Sergey Prybysh on 4/10/16.
//  Copyright © 2016 Sergey Prybysh. All rights reserved.
//

import Foundation

extension VTFlickrClient {
    
    struct FlickrConstants {
        static let baseURL = "https://api.flickr.com/services/rest/"
        static let methodSearch = "flickr.photos.search"
    }
    
    struct SearchParamKeys {
        static let lat = "lat"
        static let lon = "lon"
        static let accuracy = "accuracy"
        static let api_key = "api_key"
        static let extras = "extras"
        static let format = "format"
        static let nojsoncallback = "nojsoncallback"
    }
    
    struct SearchParamValues {
        static let apiKey = "92ab588bac79bb54332c9ef865c9c163"
        static let extras = "url_m"
        static let format = "json"
        static let nojsoncallback = 1
    }
    
}
