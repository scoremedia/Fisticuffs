//
//  TestViewModel.swift
//  Bindings
//
//  Created by Darren Clark on 2015-10-13.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import Foundation
import Bindings

class TestViewModel: BridgedViewModel {
    
    let name = Observable<String>("Darren")
    
    
    func useFullName() {
        name.value = "Darren Clark"
    }
}
