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
    let items = Observable(Array(1...100))
    let selections = Observable<[Int]>([])
    
    lazy var sum: Computed<Int> = Computed { [selections = self.selections] in
        selections.value.reduce(0) { total, value in total + value }
    }
    
    lazy var sumDisplayString: Computed<String> = Computed { [sum = self.sum] in
        sum.value > 0 ? "Sum: \(sum.value)" : "Try selecting some items!"
    }
    
    
    func clearSelection() {
        selections.value = []
    }
}


class CollectionViewSampleController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var clearButton: UIBarButtonItem!
    
    //MARK: -
    
    let viewModel = CollectionViewSampleViewModel()
    let spacing: CGFloat = 10
    let itemsPerRow = 4
    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.registerClass(CollectionViewSampleCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.allowsMultipleSelection = true
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing

        if #available(iOS 9, *) {
            let reorderGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleReorderGestureRecognizer:")
            collectionView.addGestureRecognizer(reorderGestureRecognizer)
        }
        
        
        collectionView.b_configure(viewModel.items) { config in
            config.allowsMoving = true
            config.selections = viewModel.selections
            config.deselectOnSelection = false
            
            config.useCell(reuseIdentifier: "Cell") { item, cell in
                (cell as! CollectionViewSampleCell).label.text = "\(item)"
            }
        }
        
        clearButton.b_onTap += viewModel.clearSelection
        
        viewModel.sumDisplayString += { [navigationItem = navigationItem] _, displayString in
            navigationItem.prompt = displayString
        }
    }
    
    override func viewDidLayoutSubviews() {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let itemWidth = (view.frame.size.width - spacing * CGFloat(2 + itemsPerRow - 1)) / CGFloat(itemsPerRow)
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        super.viewDidLayoutSubviews()
    }
    
    @available(iOS 9, *)
    func handleReorderGestureRecognizer(gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Began:
            let touchLocation = gestureRecognizer.locationInView(collectionView)
            if let indexPath = collectionView.indexPathForItemAtPoint(touchLocation) {
                collectionView.beginInteractiveMovementForItemAtIndexPath(indexPath)
            }
            
        case .Changed:
            let touchLocation = gestureRecognizer.locationInView(collectionView)
            collectionView.updateInteractiveMovementTargetPosition(touchLocation)
            
        case .Ended:
            collectionView.endInteractiveMovement()
            
        case .Cancelled:
            collectionView.cancelInteractiveMovement()
            
        default:
            break
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
