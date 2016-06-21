//
//  LoadImageBindingHandler.swift
//  Fisticuffs
//
//  Created by Darren Clark on 2016-02-17.
//  Copyright © 2016 theScore. All rights reserved.
//

import Foundation
import UIKit

public class LoadImageBindingHandlerConfig {
    /// Default LoadImageManager to use for future BindingHandlers.loadImage()'s
    public static var manager: LoadImageManagerType = LoadImageManager()
}

class LoadImageBindingHandler<Control: AnyObject> : BindingHandler<Control, NSURL?, UIImage?> {

    private var manager: LoadImageManagerType = LoadImageBindingHandlerConfig.manager

    private var currentTask: Disposable?
    private var disposed: Bool = false

    private var currentURL: NSURL?
    private let placeholder: UIImage?

    init(placeholder: UIImage? = nil) {
        self.placeholder = placeholder
    }

    override func set(control control: Control, oldValue: NSURL??, value: NSURL?, propertySetter: PropertySetter) {
        propertySetter(control, placeholder)
        currentTask?.dispose()
        currentTask = nil

        currentURL = value

        guard let value = value else {
            return
        }

        currentTask = manager.loadImage(value) { result in
            if self.disposed || self.currentURL?.isEqual(value) == false {
                return
            }

            if case .Success(let image) = result {
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
    static func loadImage<Control: AnyObject>(placeholder placeholder: UIImage? = nil) -> BindingHandler<Control, NSURL?, UIImage?> {
        return LoadImageBindingHandler(placeholder: placeholder)
    }

    static func loadImage<Control: AnyObject>(placeholder placeholder: UIImage? = nil) -> BindingHandler<Control, NSURL, UIImage?> {
        return transform({ .Some($0) }, reverse: nil, bindingHandler: LoadImageBindingHandler(placeholder: placeholder))
    }
}
