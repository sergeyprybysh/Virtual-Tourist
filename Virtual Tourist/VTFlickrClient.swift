//
//  VTFlickrClient.swift
//  Virtual Tourist
//
//  Created by Sergey Prybysh on 4/10/16.
//  Copyright © 2016 Sergey Prybysh. All rights reserved.
//

import Foundation

class VTFlickrClient: NSObject {
    
    var sharedSession: NSURLSession
    
    override init() {
        sharedSession = NSURLSession.sharedSession()
        super.init()
    }
    
    func taskForGetMethod(baseURL: String, parameters: [String: AnyObject],completionHandler handler: (data: NSData?, error: NSError?) -> Void){
        let urlString = baseURL + escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = sharedSession.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            guard error == nil else {
                print(error)
                handler(data: nil, error: error)
                return
            }
        }
    }
 
    private func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    class func sharedInstance() -> VTFlickrClient {
        struct Singleton {
            static var sharedInstance = VTFlickrClient()
        }
        return Singleton.sharedInstance
    }
}
