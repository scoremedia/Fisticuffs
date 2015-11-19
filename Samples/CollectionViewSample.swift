//
//  CollectionViewSample.swift
//  SwiftMVVMBinding
//
//  Created by Darren Clark on 2015-11-19.
//  Copyright © 2015 theScore. All rights reserved.
//

import UIKit
import SwiftMVVMBinding

class CollectionViewSampleViewModel {
    let items = Observable([1, 2, 3, 4, 5, 6, 7, 8, 9])
    
    let editing = Observable(false)
    lazy var editingButtonTitle: Computed<String> = Computed { [editing = self.editing] in
        editing.value ? "Done" : "Edit"
    }
    
    func toggleEditing() {
        editing.value = !editing.value
    }
    
    
    func prependItem() {
        if let min = items.value.minElement() {
            items.value.insert(min - 1, atIndex: 0)
        }
        else {
            items.value.insert(1, atIndex: 0)
        }
    }
    
    func appendItem() {
        if let max = items.value.maxElement() {
            items.value.append(max + 1)
        }
        else {
            items.value.append(1)
        }
    }
}


class CollectionViewSampleController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    //MARK: -
    
    let viewModel = CollectionViewSampleViewModel()
    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.registerClass(CollectionViewSampleCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.b_configure(viewModel.items) { config in
            config.allowsMoving = true
            config.useCell(reuseIdentifier: "Cell") { item, cell in
                (cell as! CollectionViewSampleCell).label.text = "\(item)"
            }
        }
    }
    
}


class CollectionViewSampleCell: UICollectionViewCell {
    
    var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() {
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        
        backgroundView = UIView()
        backgroundView?.backgroundColor = UIColor(red: 0.565, green: 0.831, blue: 0.800, alpha: 1.0)
        
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor(red: 1.0, green: 0.867, blue: 0.0, alpha: 1.0)
        
        let centerX = NSLayoutConstraint(
            item: label, attribute: .CenterX,
            relatedBy: .Equal,
            toItem: contentView, attribute: .CenterX,
            multiplier: 1.0, constant: 0.0
        )
        
        let centerY = NSLayoutConstraint(
            item: label, attribute: .CenterY,
            relatedBy: .Equal,
            toItem: contentView, attribute: .CenterY,
            multiplier: 1.0, constant: 0.0
        )
        
        NSLayoutConstraint.activateConstraints([centerX, centerY])
    }
    
}
