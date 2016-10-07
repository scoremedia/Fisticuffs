//
//  AssociatedObjects.swift
//  Fisticuffs
//
//  Created by Darren Clark on 2016-02-12.
//  Copyright © 2016 theScore. All rights reserved.
//

import Foundation


func associatedObjectProperty<This: AnyObject, PropertyType: AnyObject>(_ this: This, _ key: UnsafeRawPointer, factory: (This) -> PropertyType) -> PropertyType {
    if let value = objc_getAssociatedObject(this, key) as? PropertyType {
        return value
    } else {
        let new = factory(this)
        objc_setAssociatedObject(this, key, new, .OBJC_ASSOCIATION_RETAIN)
        return new
    }
}

func setAssociatedObjectProperty<This: AnyObject, PropertyType: AnyObject>(_ this: This, _ key: UnsafeRawPointer, value: PropertyType?) {
    objc_setAssociatedObject(this, key, value, .OBJC_ASSOCIATION_RETAIN)
}
