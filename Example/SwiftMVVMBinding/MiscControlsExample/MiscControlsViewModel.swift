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
    
    
    
}
