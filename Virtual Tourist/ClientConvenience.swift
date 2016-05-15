//
//  ClientConvenience.swift
//  Virtual Tourist
//
//  Created by Sergey Prybysh on 4/10/16.
//  Copyright © 2016 Sergey Prybysh. All rights reserved.
//

import Foundation

extension VTFlickrClient {
    
    func getPhotosForPin(lat: String, long: String, completionHandler: (result: [[String: AnyObject]]?, error: NSError?) -> Void) {
        
        let components = NSURLComponents()
        components.scheme = FlickrSearchConstants.scheme
        components.host = FlickrSearchConstants.host
        components.path = FlickrSearchConstants.path
        components.queryItems = [NSURLQueryItem]()
        components.queryItems!.append(NSURLQueryItem(name: SearchParamKeys.api_key, value: SearchParamValues.apiKey))
        components.queryItems!.append(NSURLQueryItem(name: SearchParamKeys.extras, value: SearchParamValues.extras))
        components.queryItems!.append(NSURLQueryItem(name: SearchParamKeys.format, value: SearchParamValues.format))
        components.queryItems!.append(NSURLQueryItem(name: SearchParamKeys.lat, value: lat))
        components.queryItems!.append(NSURLQueryItem(name: SearchParamKeys.lon, value: long))
        components.queryItems!.append(NSURLQueryItem(name: SearchParamKeys.method, value: FlickrSearchConstants.methodSearch))
        components.queryItems!.append(NSURLQueryItem(name: SearchParamKeys.page, value: "1"))
        components.queryItems!.append(NSURLQueryItem(name: SearchParamKeys.per_page, value: "21"))
        components.queryItems!.append(NSURLQueryItem(name: SearchParamKeys.nojsoncallback, value: SearchParamValues.nojsoncallback))

        taskForGetMethod(components.URL!) { (data, error) -> Void in
            guard error == nil else {
                completionHandler(result: nil, error: error)
                return
            }
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            }
            catch {
                completionHandler(result: nil, error: NSError(domain: "Serialization", code: 003, userInfo: [NSLocalizedDescriptionKey: "Unable deserialize data"]))
                return
            }
            print(parsedResult) //Remove later!!!!!!!!!!!!!!!!!!!!
            
            guard let photoDictionary = parsedResult[FlickrResponseKeys.photos] as? [String: AnyObject] else {
                completionHandler(result: nil, error: NSError(domain: "Parsing", code: 003, userInfo: [NSLocalizedDescriptionKey: "Unable to parse JSON with key" + FlickrResponseKeys.photos]))
                return
            }
            
            guard let photoArray = photoDictionary[FlickrResponseKeys.photo] as? [[String: AnyObject]] else {
                completionHandler(result: nil, error: NSError(domain: "Parsing", code: 003, userInfo: [NSLocalizedDescriptionKey: "Unable to parse JSON with key" + FlickrResponseKeys.photo]))
                return
            }
            
            if photoArray.count == 0 {
                completionHandler(result: nil, error: NSError(domain: "No Results", code: 004, userInfo: [NSLocalizedDescriptionKey: "No result found. Try again"]))
            }
            
            completionHandler(result: photoArray, error: nil)
            
        }
    }
    
    func getImageWithURL(urlString: String, completionHandler: (imageData: NSData?, error: NSError?) -> Void) {
        
        let url = NSURL(string: urlString)!
        
        taskForGetMethod(url) { (data, error) -> Void in
            guard error == nil else {
                completionHandler(imageData: nil, error: error)
                return
            }
            //TODO: remove it
            print("Returning downloaded images")
            completionHandler(imageData: data, error: nil)
            
        }
        
    }
}
