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


private var b_currentPage_key = 0
private var b_numberOfPages_key = 0


public extension UIPageControl {
    
    var b_currentPage: BidirectionalBindableProperty<Int> {
        return associatedObjectProperty(self, &b_currentPage_key) { _ in
            addTarget(self, action: "b_valueChanged:", forControlEvents: .ValueChanged)
            let cleanup = DisposableBlock { [weak self] in
                self?.removeTarget(self, action: "b_valueChanged:", forControlEvents: .ValueChanged)
            }

            return BidirectionalBindableProperty<Int>(
                getter: { [weak self] in self?.currentPage ?? 0 },
                setter: { [weak self] value in self?.currentPage = value },
                extraCleanup: cleanup
            )
        }
    }

    @objc private func b_valueChanged(sender: UITextField) {
        b_currentPage.pushChangeToObservable()
    }


    var b_numberOfPages: BindableProperty<Int> {
        return associatedObjectProperty(self, &b_numberOfPages_key) { _ in
            return BindableProperty<Int>(setter: { [weak self] value in
                self?.numberOfPages = value
            })
        }
    }

    
}

