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
    public static var imageLoadErrorLogger: (NSURL, NSError?) -> Void = { url, error in
        print("Failed to load image at \(url): \(error)")
    }

    private static let imageCache = NSCache()
}


class LoadImageBindingHandler<Control: AnyObject> : BindingHandler<Control, NSURL?, UIImage?> {

    private var currentTask: NSURLSessionDataTask?
    private let placeholder: UIImage?

    init(placeholder: UIImage? = nil) {
        self.placeholder = placeholder
    }

    override func set(control control: Control, oldValue: NSURL??, value: NSURL?, propertySetter: PropertySetter) {
        propertySetter(control, placeholder)
        currentTask?.cancel()

        guard let value = value else {
            return
        }

        if let cached = LoadImageBindingHandlerConfig.imageCache.objectForKey(value) as? UIImage {
            propertySetter(control, cached)
        }

        currentTask = LoadImageBindingHandlerConfig.URLSession.dataTaskWithURL(value) { [weak control] data, response, error in
            if error != nil {
                return
            }

            guard let data = data, image = UIImage(data: data) else {
                return
            }

            dispatch_async(dispatch_get_main_queue()) { [weak control] in
                LoadImageBindingHandlerConfig.imageCache.setObject(image, forKey: value)
                if let control = control {
                    propertySetter(control, image)
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
