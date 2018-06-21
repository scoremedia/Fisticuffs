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

    static func findDependencies(_ block: (Void) -> Void) -> [AnySubscribableBox] {
        let stack = DependenciesCollectionStack.current

        let collection = DependenciesCollection()
        stack.items.append(collection)

        block()

        stack.items.removeLast()
        return Array(collection.dependencies)
    }
    
    static func didReadObservable(_ subscribable: AnySubscribable) {
        let boxed = AnySubscribableBox(subscribable: subscribable)
        DependenciesCollectionStack.current.items.last?.dependencies.insert(boxed)
    }
    
}

private class DependenciesCollectionStack: NSObject {
    fileprivate class ThreadDictionaryKey: NSObject, NSCopying {
        @objc func copy(with zone: NSZone?) -> Any {
            return self
        }
    }
    static let threadDictionaryKey = ThreadDictionaryKey()

    static var current: DependenciesCollectionStack {
        let thread = Thread.current
        if let existing = thread.threadDictionary[threadDictionaryKey] as? DependenciesCollectionStack {
            return existing
        }
        else {
            let new = DependenciesCollectionStack()
            thread.threadDictionary[threadDictionaryKey] = new
            return new
        }
    }

    var items: [DependenciesCollection] = []
}

// Optimization - so we don't end up creating a new Set<AnySubscribableBox> every time a dependency is read
private class DependenciesCollection {
    var dependencies: Set<AnySubscribableBox> = []
}
