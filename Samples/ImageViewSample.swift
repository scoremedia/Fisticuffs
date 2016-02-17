//
//  ImageViewSample.swift
//  Fisticuffs
//
//  Created by Darren Clark on 2016-02-17.
//  Copyright © 2016 theScore. All rights reserved.
//

import Foundation
import UIKit
import Fisticuffs


class ImageViewSampleViewModel {

    let textInput: Observable<String> = Observable("http://placehold.it/350x150/ff0000/ffffff")
    let imageUrl: Observable<NSURL?> = Observable(nil)

    func loadImage() {
        imageUrl.value = NSURL(string: textInput.value)
    }

}


class ImageViewSampleViewController: UITableViewController {

    let viewModel = ImageViewSampleViewModel()

    let placeholderImage: UIImage = {
        let imageRect = CGRect(x: 0, y: 0, width: 500, height: 500)
        UIGraphicsBeginImageContext(imageRect.size)

        // grey background
        UIColor.lightGrayColor().setFill()
        UIBezierPath(rect: imageRect).fill()

        let centered = NSMutableParagraphStyle()
        centered.alignment = .Center
        ("?" as NSString).drawAtPoint(CGPoint(x: imageRect.midX - 5, y: imageRect.midY - 5), withAttributes: [NSParagraphStyleAttributeName: centered, NSFontAttributeName: UIFont.boldSystemFontOfSize(24)])

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsGetCurrentContext()

        return image
    }()

    @IBOutlet var imageView: UIImageView? {
        didSet {
            guard let imageView = imageView else { return }
            imageView.b_image.bind(viewModel.imageUrl, BindingHandlers.loadImage(placeholder: self.placeholderImage))
        }
    }

    @IBOutlet var textInput: UITextField? {
        didSet {
            guard let textInput = textInput else { return }
            textInput.b_text.bind(viewModel.textInput)
        }
    }

    @IBOutlet var loadButton: UIButton? {
        didSet {
            guard let loadButton = loadButton else { return }
            loadButton.b_onTap.subscribe(viewModel.loadImage)
        }
    }

}

