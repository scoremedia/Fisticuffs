//
//  Observable+Array.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-16.
//
//

import Foundation


public enum ArrayChange<T> {
    case Set(elements: [T])
    case Insert(index: Int, newElements: [T])
    case Remove(range: Range<Int>, removedElements: [T])
    case Replace(range: Range<Int>, removedElements: [T], newElements: [T])
}


public extension Observable where T: CollectionType, T.Generator.Element : Equatable {
    func subscribeArray(options: SubscriptionOptions = SubscriptionOptions(), callback: (T, ArrayChange<T.Generator.Element>) -> Void) -> Disposable {
        return subscribeDiff(options) { oldValue, newValue in
            let change = oldValue.calculateChange(newValue)
            callback(newValue, change)
        }
    }
}

private extension CollectionType where Generator.Element: Equatable {
    
    private func calculateChange(new: Self) -> ArrayChange<Self.Generator.Element> {
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
