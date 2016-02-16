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


public class DisposableBag: Disposable {
    var disposables = [Disposable]()
    
    deinit {
        for disposable in disposables {
            disposable.dispose()
        }
    }
    
    public func add(disposable: Disposable) {
        disposables.append(disposable)
    }

    public func dispose() {
        disposables.forEach { $0.dispose() }
        disposables = []
    }
}


public extension Disposable {
    
    // Convenience method to allow for patterns like:
    //
    //  observable.subscribe { value in
    //      // ... do something here ...
    //  }
    //  .addTo(disposableBag)
    //
    public func addTo(bag: DisposableBag) {
        bag.add(self)
    }
    
}
