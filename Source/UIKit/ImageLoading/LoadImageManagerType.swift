//
//  LoadImageManagerType.swift
//  Fisticuffs
//
//  Created by Darren Clark on 2016-06-21.
//  Copyright © 2016 theScore. All rights reserved.
//

/**
 Result of an image load request
 */
public enum LoadImageResult {
    /// Image was successfully loaded
    case Success(UIImage)
    /// Image failed to load
    case Failure(NSError)
}

/// Defines the interface that LoadImageBindingHandler uses
public protocol LoadImageManagerType {
    /**
     Handle a request for an image.  Must call `completionHandler` on the main thread!

     - parameter URL:               The requested URL
     - parameter completionHandler: Callback to be called once image has loaded (or failed)
     
     - returns: Disposable to cancel the request (if disposed, shouldn't call `completionHandler` ever, though this isn't strictly enforced)
     */
    func loadImage(URL: NSURL, completionHandler: LoadImageResult -> Void) -> Disposable
}
