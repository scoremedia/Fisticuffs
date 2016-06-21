//
//  LoadImageManager.swift
//  Fisticuffs
//
//  Created by Darren Clark on 2016-06-21.
//  Copyright © 2016 theScore. All rights reserved.
//

import Foundation

/// Default implementation of LoadImageManagerType
/// Allows for some basic customization via the `URLSession` and `errorLogger` properties.
public class LoadImageManager: LoadImageManagerType {
    public static let errorDomain: String = "LoadImageManager"
    public static let failedToParseErrorCode: Int = 1

    /// NSURLSession used to load images. Can be replaced with a different NSURLSession
    public var URLSession: NSURLSession = NSURLSession.sharedSession()

    /// Error message logger. Can be replaced with your own custom implementation
    public var errorLogger: (NSURL, NSError) -> Void = { URL, error in
        print("Failed to load image at `\(URL)`: \(error)")
    }


    private let cache: NSCache = NSCache()

    // MARK: - LoadImageManagerType

    public func loadImage(URL: NSURL, completionHandler: LoadImageResult -> Void) -> Disposable {
        if let cachedImage = cache.objectForKey(URL) as? UIImage {
            completionHandler(.Success(cachedImage))
            return DisposableBlock {}
        }

        let task = URLSession.dataTaskWithURL(URL) { data, response, error in
            let mainQueue = dispatch_get_main_queue()
            dispatch_async(mainQueue) {
                if error?.domain == NSURLErrorDomain && error?.code == NSURLErrorCancelled {
                    return
                }

                if let error = error {
                    self.errorLogger(URL, error)
                    completionHandler(.Failure(error))
                    return
                }

                guard let data = data, image = UIImage(data: data) else {
                    let error = NSError(
                        domain: LoadImageManager.errorDomain,
                        code: LoadImageManager.failedToParseErrorCode,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to parse image at URL: \(URL)"]
                    )
                    self.errorLogger(URL, error)
                    completionHandler(.Failure(error))
                    return
                }

                self.cache.setObject(image, forKey: URL)
                completionHandler(.Success(image))
            }
        }
        task.resume()

        return DisposableBlock {
            task.cancel()
        }
    }
}
