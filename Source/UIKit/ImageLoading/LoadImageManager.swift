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
open class LoadImageManager: LoadImageManagerType {
    open static let errorDomain: String = "LoadImageManager"
    open static let failedToParseErrorCode: Int = 1

    /// NSURLSession used to load images. Can be replaced with a different NSURLSession
    open var URLSession: URLSession = Foundation.URLSession.shared

    /// Error message logger. Can be replaced with your own custom implementation
    open var errorLogger: (URL, NSError) -> Void = { URL, error in
        print("Failed to load image at `\(URL)`: \(error)")
    }


    fileprivate let cache: NSCache<NSURL, UIImage> = NSCache()

    // MARK: - LoadImageManagerType

    open func loadImage(URL: URL, completionHandler: @escaping (LoadImageResult) -> Void) -> Disposable {
        if let cachedImage = cache.object(forKey: URL as NSURL) {
            completionHandler(.success(cachedImage))
            return DisposableBlock {}
        }

        let task = URLSession.dataTask(with: URL, completionHandler: { data, response, error in
            let mainQueue = DispatchQueue.main
            mainQueue.async {
                //TODO: Maybe "fix" error here??
                let nsError = error as NSError?
                if nsError?.domain == NSURLErrorDomain && nsError?.code == NSURLErrorCancelled {
                    return
                }

                if let nsError = nsError {
                    self.errorLogger(URL, nsError)
                    completionHandler(.failure(nsError))
                    return
                }

                guard let data = data, let image = UIImage(data: data) else {
                    let error = NSError(
                        domain: LoadImageManager.errorDomain,
                        code: LoadImageManager.failedToParseErrorCode,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to parse image at URL: \(URL)"]
                    )
                    self.errorLogger(URL, error)
                    completionHandler(.failure(error))
                    return
                }

                self.cache.setObject(image, forKey: URL as NSURL)
                completionHandler(.success(image))
            }
        }) 
        task.resume()

        return DisposableBlock {
            task.cancel()
        }
    }
}
