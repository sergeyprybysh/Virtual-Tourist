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
    
    func taskForGetMethod(url: NSURL, completionHandler handler: (data: NSData?, error: NSError?) -> Void){
        
        let request = NSURLRequest(URL: url)
        
        let task = sharedSession.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            guard error == nil else {
                print(error)
                handler(data: nil, error: error)
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                
                if let response = response as? NSHTTPURLResponse {
                    handler(data: nil, error: NSError(domain: "Networking", code: 001, userInfo: [NSLocalizedDescriptionKey: "Invalid response with status code \(response.statusCode)"]))
                }
                else if let _ = response {
                    handler(data: nil, error: NSError(domain: "Networking", code: 001, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                }
                else {
                    handler(data: nil, error: NSError(domain: "Networking", code: 001, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                }
                return
            }
            
            guard let data = data else {
                handler(data: nil, error: NSError(domain: "Networking", code: 002, userInfo: [NSLocalizedDescriptionKey: "No data was returned"]))
                return
            }
            
            handler(data: data, error: nil)
        }
        task.resume()
    }
    
    class func sharedInstance() -> VTFlickrClient {
        struct Singleton {
            static var sharedInstance = VTFlickrClient()
        }
        return Singleton.sharedInstance
    }
}
