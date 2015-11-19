//
//  ControlsSample.swift
//  SwiftMVVMBinding
//
//  Created by Darren Clark on 2015-11-19.
//  Copyright © 2015 theScore. All rights reserved.
//

import UIKit
import SwiftMVVMBinding


class ControlsViewModel {
    
    //MARK: Colors
    
    let red = Observable<Float>(0.1)
    let green = Observable<Float>(0.8)
    let blue = Observable<Float>(0.5)
    
    lazy var color: Computed<UIColor> = Computed { [red = self.red, green = self.green, blue = self.blue] in
        return UIColor(
            red: CGFloat(red.value),
            green: CGFloat(green.value),
            blue: CGFloat(blue.value),
            alpha: 1.0
        )
    }
    
    //MARK: Visibility
    
    let alpha = Observable<Float>(1.0)
    let hidden = Observable<Bool>(false)
    
}


class ControlsSampleViewController: UITableViewController {
    
    @IBOutlet var resultsDisplay: UIView!
    
    @IBOutlet var redSlider: UISlider!
    @IBOutlet var greenSlider: UISlider!
    @IBOutlet var blueSlider: UISlider!
    
    @IBOutlet var alphaSlider: UISlider!
    @IBOutlet var hiddenSwitch: UISwitch!
    
    //MARK: -
    
    let viewModel = ControlsViewModel()
    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsDisplay.b_backgroundColor <-- viewModel.color
        resultsDisplay.b_alpha.bind(viewModel.alpha, transform: { value in CGFloat(value) })
        resultsDisplay.b_hidden <-- viewModel.hidden
        
        
        redSlider.b_value <-> viewModel.red
        greenSlider.b_value <-> viewModel.green
        blueSlider.b_value <-> viewModel.blue
        
        alphaSlider.b_value <-> viewModel.alpha
        hiddenSwitch.b_on <-> viewModel.hidden
    }
    
}
