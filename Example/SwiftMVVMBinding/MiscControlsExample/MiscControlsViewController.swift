//
//  MiscControlsViewController.swift
//  SwiftMVVMBinding
//
//  Created by Darren Clark on 2015-10-16.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import UIKit

class MiscControlsViewController: UIViewController {
    
    let viewModel = MiscControlsViewModel()
    
    @IBOutlet var toggle: UISwitch!
    @IBOutlet var toggleLabel: UILabel!
    
    @IBOutlet var slider: UISlider!
    @IBOutlet var sliderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toggle.b_on = viewModel.toggleValue
        toggleLabel.b_text = viewModel.toggleValueString
        
        slider.b_value = viewModel.sliderValue
        sliderLabel.b_text = viewModel.sliderValueString
    }
    
}
