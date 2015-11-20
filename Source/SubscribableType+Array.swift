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

public enum ArrayChange<T> {
    case Set(elements: [T])
    case Insert(index: Int, newElements: [T])
    case Remove(range: Range<Int>, removedElements: [T])
    case Replace(range: Range<Int>, removedElements: [T], newElements: [T])
}


public extension Subscribable where ValueType: CollectionType, ValueType.Generator.Element : Equatable {
    
    typealias ItemType = ValueType.Generator.Element
    
    func subscribeArray(options: SubscriptionOptions = SubscriptionOptions(), callback: ([ItemType], ArrayChange<ItemType>) -> Void) -> Disposable {
        return subscribe(options) { oldValue, newValue in
            if let change = oldValue?.calculateChange(newValue) {
                callback(Array(newValue), change)
            }
            else {
                callback(Array(newValue), .Set(elements: Array(newValue)))
            }
        }
    }
    
}


extension CollectionType where Generator.Element: Equatable {
    
    func calculateChange(new: Self) -> ArrayChange<Self.Generator.Element> {
        let oldItems = Array(self)
        let newItems = Array(new)
        
        let commonAtStart = numberInCommon(Array(self), Array(new))
        let commonAtEnd = numberInCommon(self.reverse(), new.reverse())
        
        switch (oldItems.count, newItems.count, commonAtStart, commonAtEnd) {
            
        case let (oldCount, newCount, commonStart, commonEnd)
            where oldCount == newCount && // same length?
                oldCount == commonStart && oldCount == commonEnd: // all elements are same
            return ArrayChange.Set(elements: newItems)
            
        case (_, _, 0, 0): // nothing in common
            return ArrayChange.Set(elements: newItems)
            
        case let (oldCount, newCount, commonStart, commonEnd)
            where oldCount < newCount && // added items?
                commonStart + commonEnd + (newCount - oldCount) == newCount:
            return ArrayChange.Insert(index: commonStart, newElements: Array(newItems[commonStart..<(newCount - commonEnd)]))
            
        case let (oldCount, newCount, commonStart, commonEnd)
            where oldCount > newCount &&  // removed items?
                commonStart + commonEnd + (oldCount - newCount) == oldCount:
            let range = commonStart..<(oldCount - commonEnd)
            return ArrayChange.Remove(range: range, removedElements: Array(oldItems[range]))
            
        case let (oldCount, newCount, commonStart, commonEnd):
            let rangeInOld = commonStart..<(oldCount - commonEnd)
            let rangeInNew = commonStart..<(newCount - commonEnd)
            return ArrayChange.Replace(range: rangeInOld, removedElements: Array(oldItems[rangeInOld]), newElements: Array(newItems[rangeInNew]))
        }
    }
    
    private func numberInCommon(oldItems: [Self.Generator.Element], _ newItems: [Self.Generator.Element]) -> Int {
        var newGenerator = oldItems.generate()
        var oldGenerator = newItems.generate()
        var count = 0
        
        while let newItem = newGenerator.next(), oldItem = oldGenerator.next() where newItem == oldItem {
            count += 1
        }
        
        return count
    }
    
}
