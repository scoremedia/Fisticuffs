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

public class BindableProperty<ValueType> {
    typealias Setter = (ValueType) -> Void
    
    
    let setter: Setter
    var currentBinding: Disposable?
    
    init(setter: Setter) {
        self.setter = setter
    }
    
    deinit {
        currentBinding?.dispose()
    }
}

public extension BindableProperty {
    public func bind(subscribable: Subscribable<ValueType>) {
        currentBinding?.dispose()
        
        var options = SubscriptionOptions()
        options.notifyOnSubscription = true
        
        currentBinding = subscribable.subscribe(options) { [weak self] _, value in
            self?.setter(value)
        }
    }
    
    public func bind<OtherType>(subscribable: Subscribable<OtherType>, transform: OtherType -> ValueType) {
        currentBinding?.dispose()
        
        var options = SubscriptionOptions()
        options.notifyOnSubscription = true
        
        currentBinding = subscribable.subscribe(options) { [weak self] _, value in
            self?.setter(transform(value))
        }
    }
    
    public func bind(block: () -> ValueType) {
        currentBinding?.dispose()
        
        var options = SubscriptionOptions()
        options.notifyOnSubscription = true
        
        var computed: Computed<ValueType>? = Computed<ValueType>(block: block)
        let subscription = computed!.subscribe(options) { [weak self] _, value in
            self?.setter(value)
        }
        
        currentBinding = DisposableBlock {
            computed = nil // keep a strong reference to the Computed
            subscription.dispose()
        }
    }
}
