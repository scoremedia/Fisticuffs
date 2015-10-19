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
    
    private func calculateChange(other: Self) -> ArrayChange<Self.Generator.Element> {
        let selfItems = Array(self)
        let otherItems = Array(other)
        
        let commonAtStart = numberInCommon(Array(self), otherItems: Array(other))
        let commonAtEnd = numberInCommon(self.reverse(), otherItems: other.reverse())
        
        switch (selfItems.count, otherItems.count, commonAtStart, commonAtEnd) {
            // sc = selfItems.count, oc = otherItems.count, cs = commonAtStart, ce = commonAtEnd
            
        case let (sc, oc, cs, ce)
            where sc == oc && // same length
                sc == cs && sc == ce: // all elements are same
            return ArrayChange.Set(elements: otherItems)
            
        case (_, _, 0, 0): // nothing in common
            return ArrayChange.Set(elements: otherItems)
            
        case let (sc, oc, cs, ce)
            where sc < oc && // added items
                cs + ce + (oc - sc) == oc:
            return ArrayChange.Insert(index: cs, newElements: Array(otherItems[cs..<(oc - ce)]))
            
        case let (sc, oc, cs, ce)
            where sc > oc &&  // removed items
                cs + ce + (sc - oc) == sc:
            let range = cs..<(sc - ce)
            return ArrayChange.Remove(range: range, removedElements: Array(selfItems[range]))
            
        case let (sc, oc, cs, ce):
            let rangeInSelf = cs..<(sc - ce)
            let rangeInOther = cs..<(oc - ce)
            return ArrayChange.Replace(range: rangeInSelf, removedElements: Array(selfItems[rangeInSelf]), newElements: Array(otherItems[rangeInOther]))
        }
    }
    
    private func numberInCommon(selfItems: [Self.Generator.Element], otherItems: [Self.Generator.Element]) -> Int {
        var selfGenerator = selfItems.generate()
        var otherGenerator = otherItems.generate()
        var count = 0
        
        while let selfItem = selfGenerator.next(), otherItem = otherGenerator.next() where selfItem == otherItem {
            count += 1
        }
        
        return count
    }
    
}
