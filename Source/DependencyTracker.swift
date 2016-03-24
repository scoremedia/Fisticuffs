//  The MIT License (MIT)
//
//  Copyright (c) 2016 theScore Inc.
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


struct DependencyTracker {
    
    private static var stack: [DependenciesCollection] = []
    
    static func findDependencies(@noescape block: Void -> Void) -> [AnySubscribableBox] {
        let collection = DependenciesCollection()
        stack.append(collection)

        block()

        stack.removeLast()
        return Array(collection.dependencies)
    }
    
    static func didReadObservable(subscribable: AnySubscribable) {
        let boxed = AnySubscribableBox(subscribable: subscribable)
        stack.last?.dependencies.insert(boxed)
    }
    
}

// Optimization - so we don't end up creating a new Set<AnySubscribableBox> every time a dependency is read
private class DependenciesCollection {
    var dependencies: Set<AnySubscribableBox> = []
}
