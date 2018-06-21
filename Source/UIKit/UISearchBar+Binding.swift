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

private var b_text_key = 0
private var b_delegate_key = 0


public extension UISearchBar {
    
    var b_text: BidirectionalBindableProperty<UISearchBar, String?> {
        return associatedObjectProperty(self, &b_text_key) { _ in
            let delegate: SearchBarDelegate = associatedObjectProperty(self, &b_delegate_key) { _ in SearchBarDelegate() }
            self.delegate = delegate

            let bindableProperty = BidirectionalBindableProperty<UISearchBar, String?>(
                control: self,
                getter: { searchBar in searchBar.text },
                setter: { searchBar, newValue in searchBar.text = newValue }
            )
            
            delegate.bindableProperty = bindableProperty

            return bindableProperty
        }
    }
}

private class SearchBarDelegate: NSObject, UISearchBarDelegate {

    weak var bindableProperty: BidirectionalBindableProperty<UISearchBar, String?>?
    
    @objc func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        bindableProperty?.uiChangeEvent.fire(())
    }
    
}
