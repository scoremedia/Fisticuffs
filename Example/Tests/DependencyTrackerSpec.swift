//
//  DependencyTrackerSpec.swift
//  Bindings
//
//  Created by Darren Clark on 2015-10-13.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import SwiftMVVMBinding


class DependencyTrackerSpec: QuickSpec {
    override func spec() {
        
        it("should collect all Observable's accessed inside the passed in block") {
            let hello = Observable("Hello")
            let world = Observable("world")
            
            let dependencies = DependencyTracker.findDependencies {
                let _ = "\(hello.value), \(world.value)"
            }
            
            expect(dependencies.count) == 2
            expect(dependencies.contains { $0 === hello }) == true
            expect(dependencies.contains { $0 === world }) == true
        }
        
        it("should not return duplicate usages of the same Observable") {
            let test = Observable("test")
            
            let dependencies = DependencyTracker.findDependencies {
                let _ = "\(test.value)ing"
                let _ = "\(test.value)er"
                let _ = "\(test.value)ed"
            }
            
            expect(dependencies.count) == 1
            expect(dependencies.contains { $0 === test }) == true
        }
        
    }
}
