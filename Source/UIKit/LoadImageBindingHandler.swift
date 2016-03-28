//
//  LoadImageBindingHandler.swift
//  Fisticuffs
//
//  Created by Darren Clark on 2016-02-17.
//  Copyright © 2016 theScore. All rights reserved.
//

import Foundation
import UIKit

public struct LoadImageBindingHandlerConfig {
    /// The NSURLSession to load images.  May optionally be replaced.
    public static var URLSession = NSURLSession.sharedSession()

    /// Can be replaced (for example, if you are using a logging framework, or you wish to silence errors)
    /// Handler is passed the NSURL for the image that was loaded, and the NSError (or nil if `UIImage.init(data:)` failed)
    public static var logImageLoadError: (NSURL, NSError?) -> Void = { url, error in
        let errorMessage = error.map { error in "\(error)" } ?? "Failed to parse image data"
        print("Failed to load image at \(url): \(errorMessage)")
    }

    /// Can be replaced to customize the image caching behaviour
    public static let imageCache: LoadImageBindingHandlerCache = LoadImageBindingHandlerCacheImpl()
}

public protocol LoadImageBindingHandlerCache {
    func setImage(image: UIImage, forURL URL: NSURL)
    func imageForURL(URL: NSURL) -> UIImage?
}

class LoadImageBindingHandlerCacheImpl: LoadImageBindingHandlerCache {
    let cache = NSCache()

    func setImage(image: UIImage, forURL URL: NSURL) {
        cache.setObject(image, forKey: URL)
    }
    func imageForURL(URL: NSURL) -> UIImage? {
        return cache.objectForKey(URL) as? UIImage
    }
}


class LoadImageBindingHandler<Control: AnyObject> : BindingHandler<Control, NSURL?, UIImage?> {

    private var currentTask: NSURLSessionDataTask?
    private var currentURL: NSURL?
    private let placeholder: UIImage?

    init(placeholder: UIImage? = nil) {
        self.placeholder = placeholder
    }

    override func set(control control: Control, oldValue: NSURL??, value: NSURL?, propertySetter: PropertySetter) {
        propertySetter(control, placeholder)
        currentTask?.cancel()

        currentURL = value

        guard let value = value else {
            return
        }

        if let cached = LoadImageBindingHandlerConfig.imageCache.imageForURL(value) {
            propertySetter(control, cached)
            return
        }

        currentTask = LoadImageBindingHandlerConfig.URLSession.dataTaskWithURL(value) { [weak self, weak control] data, response, error in
            if let error = error {
                LoadImageBindingHandlerConfig.logImageLoadError(value, error)
                return
            }

            guard let data = data, image = UIImage(data: data) else {
                LoadImageBindingHandlerConfig.logImageLoadError(value, nil)
                return
            }

            dispatch_async(dispatch_get_main_queue()) { [weak control] in
                LoadImageBindingHandlerConfig.imageCache.setImage(image, forURL: value)

                if self?.currentURL == value {
                    if let control = control {
                        propertySetter(control, image)
                    }
                }
            }
        }
        currentTask?.resume()
    }

    override func dispose() {
        currentTask?.cancel()
        super.dispose()
    }
}

public extension BindingHandlers {
    static func loadImage<Control: AnyObject>(placeholder placeholder: UIImage? = nil) -> BindingHandler<Control, NSURL?, UIImage?> {
        return LoadImageBindingHandler(placeholder: placeholder)
    }

    static func loadImage<Control: AnyObject>(placeholder placeholder: UIImage? = nil) -> BindingHandler<Control, NSURL, UIImage?> {
        return transform({ .Some($0) }, reverse: nil, bindingHandler: LoadImageBindingHandler(placeholder: placeholder))
    }
}
