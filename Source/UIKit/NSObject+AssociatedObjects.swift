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

private var keys = [String:NSObject]()

extension NSObject {
    
    func findKey(name: String, type: Any) -> UnsafePointer<Void> {
        let keyString = "\(name)__\(type)"
        if let keyObj = keys[keyString] {
            return UnsafePointer(Unmanaged.passUnretained(keyObj).toOpaque())
        }
        else {
            let keyObj = NSObject()
            keys[keyString] = keyObj
            return UnsafePointer(Unmanaged.passUnretained(keyObj).toOpaque())
        }
    }
    
    func get<T: AnyObject>(name: String) -> T? {
        let key = findKey(name, type: T.self)
        return objc_getAssociatedObject(self, key) as? T
    }
    
    func get<T: AnyObject>(name: String, @noescape orSet block: (Void) -> T) -> T {
        if let existing: T = get(name) {
            return existing
        }
        else {
            let new = block()
            set(name, value: new)
            return new
        }
    }
    
    func set<T: AnyObject>(name: String, value: T?) {
        let key = findKey(name, type: T.self)
        objc_setAssociatedObject(self, key, value, .OBJC_ASSOCIATION_RETAIN)
    }
    
}
