//
//  ClientConstants.swift
//  Virtual Tourist
//
//  Created by Sergey Prybysh on 4/10/16.
//  Copyright © 2016 Sergey Prybysh. All rights reserved.
//

import Foundation

extension VTFlickrClient {
    
    struct FlickrSearchConstants {
        static let host = "api.flickr.com"
        static let scheme = "https"
        static let methodSearch = "flickr.photos.search"
        static let path = "/services/rest"
    }
    
    struct SearchParamKeys {
        static let lat = "lat"
        static let lon = "lon"
        static let accuracy = "accuracy"
        static let api_key = "api_key"
        static let extras = "extras"
        static let format = "format"
        static let nojsoncallback = "nojsoncallback"
        static let method = "method"
        static let page = "page"
        static let per_page = "per_page"
    }
    
    struct SearchParamValues {
        static let apiKey = "92ab588bac79bb54332c9ef865c9c163"
        static let extras = "url_m"
        static let format = "json"
        static let nojsoncallback = "1"
    }
    
}
