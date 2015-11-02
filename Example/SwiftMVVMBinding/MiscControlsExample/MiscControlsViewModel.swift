//
//  MiscControlsViewModel.swift
//  SwiftMVVMBinding
//
//  Created by Darren Clark on 2015-10-16.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import Foundation
import SwiftMVVMBinding

class MiscControlsViewModel {
    
    let toggleValue = Observable(true)
    lazy var toggleValueString: Computed<String> = Computed {
        return self.toggleValue.value ? "Value:  ON" : "Value:  OFF"
    }
    
    let sliderValue = Observable(Float(0.0))
    lazy var sliderValueString: Computed<String> = Computed {
        let formatted = String(format: "%.1f", self.sliderValue.value)
        return "Value: \(formatted)"
    }
    
    let segments = Observable(["One", "Two", "Three"])
    let selectedSegment = Observable("")
    lazy var segmentValueString: Computed<String> = Computed {
        return "Value: \(self.selectedSegment.value)"
    }
    
    
}
