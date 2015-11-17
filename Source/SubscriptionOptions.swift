//
//  SubscriptionOptions.swift
//  Pods
//
//  Created by Darren Clark on 2015-10-14.
//
//

import Foundation

public enum NotifyWhen {
    case BeforeChange
    case AfterChange
}

public struct SubscriptionOptions {
    public var notifyOnSubscription = true
    public var when = NotifyWhen.AfterChange
    
    public init() {
    }
    
    public init(notifyOnSubscription: Bool, when: NotifyWhen) {
        self.notifyOnSubscription = notifyOnSubscription
        self.when = when
    }
}
