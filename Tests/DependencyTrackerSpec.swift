//  The MIT License (MIT)
//
//  Copyright (c) 2015 theScore Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import Quick
import Nimble
@testable import Fisticuffs


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
