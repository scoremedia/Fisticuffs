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

import UIKit

public extension UITableView {
        
    func b_configure<S: Subscribable where
        S.ValueType: CollectionType,
        S.ValueType.Index == Int,
        S.ValueType.Generator.Element: Equatable>(items: S, @noescape block: (TableViewDataSource<S>) -> Void) {
            
            let dataSource = TableViewDataSource(subscribable: items, view: self)
            block(dataSource)
            
            set("dataSource", value: dataSource as AnyObject)
            
            self.delegate = dataSource
            self.dataSource = dataSource
            
    }
    
    var b_editing: Binding<Bool> {
        get {
            return get("b_editing", orSet: {
                return Binding<Bool>(setter: { [weak self] value -> Void in
                    self?.editing = value
                })
            })
        }
    }

    
}
