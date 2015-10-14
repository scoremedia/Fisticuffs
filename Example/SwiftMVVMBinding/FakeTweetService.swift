//
//  FakeTweetService.swift
//  Bindings
//
//  Created by Darren Clark on 2015-10-13.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import Foundation


class FakeTweetService {
    enum Errors : ErrorType {
        case FakeError
    }
    
    static func post(tweet: String, completionHandler: String? -> Void) {
        let encodedTweet = tweet.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        let body = "tweet=\(encodedTweet)"
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://httpbin.org/post")!)
        request.HTTPMethod = "POST"
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data: NSData?, _, _) in
            dispatch_async(dispatch_get_main_queue()) {
                guard let data = data else {
                    completionHandler(nil)
                    return
                }
                
                do {
                    guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject] else {
                        throw Errors.FakeError
                    }
                    
                    guard let form = json["form"] as? [String: AnyObject] else {
                        throw Errors.FakeError
                    }
                    
                    guard let tweet = form["tweet"] as? String else {
                        throw Errors.FakeError
                    }
                    
                    completionHandler(tweet)
                }
                catch {
                    completionHandler(nil)
                }
            }
        }
        task.resume()
    }
}
