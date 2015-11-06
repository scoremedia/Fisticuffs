//
//  ArrayChange.swift
//  Pods
//
//  Created by Darren Clark on 2015-11-02.
//
//

public enum ArrayChange<T> {
    case Set(elements: [T])
    case Insert(index: Int, newElements: [T])
    case Remove(range: Range<Int>, removedElements: [T])
    case Replace(range: Range<Int>, removedElements: [T], newElements: [T])
}
