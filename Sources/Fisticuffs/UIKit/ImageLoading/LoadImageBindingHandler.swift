//
//  LoadImageBindingHandler.swift
//  Fisticuffs
//
//  Created by Darren Clark on 2016-02-17.
//  Copyright © 2016 theScore. All rights reserved.
//

import Foundation
import UIKit

open class LoadImageBindingHandlerConfig {
    /// Default LoadImageManager to use for future BindingHandlers.loadImage()'s
    public static var manager: LoadImageManagerType = LoadImageManager()
}

class LoadImageBindingHandler<Control: AnyObject> : BindingHandler<Control, URL?, UIImage?> {

    fileprivate var manager: LoadImageManagerType = LoadImageBindingHandlerConfig.manager

    fileprivate var currentTask: Disposable?
    fileprivate var disposed: Bool = false

    fileprivate var currentURL: URL?
    fileprivate let placeholder: UIImage?

    init(placeholder: UIImage? = nil) {
        self.placeholder = placeholder
    }

    override func set(control: Control, oldValue: URL??, value: URL?, propertySetter: @escaping PropertySetter) {
        propertySetter(control, placeholder)
        currentTask?.dispose()
        currentTask = nil

        currentURL = value

        guard let value = value else {
            return
        }

        currentTask = manager.loadImage(URL: value) { result in
            if self.disposed || (self.currentURL == value) == false {
                return
            }

            if case .success(let image) = result {
                propertySetter(control, image)
            }
        }
    }

    override func dispose() {
        currentTask?.dispose()
        currentTask = nil

        disposed = true

        super.dispose()
    }
}

public extension BindingHandlers {
    static func loadImage<Control: AnyObject>(placeholder: UIImage? = nil) -> BindingHandler<Control, URL?, UIImage?> {
        LoadImageBindingHandler(placeholder: placeholder)
    }

    static func loadImage<Control: AnyObject>(placeholder: UIImage? = nil) -> BindingHandler<Control, URL, UIImage?> {
        transform({ .some($0) }, reverse: nil, bindingHandler: LoadImageBindingHandler(placeholder: placeholder))
    }
}
