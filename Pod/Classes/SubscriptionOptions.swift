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
    var notifyOnSubscription = true
    var when = NotifyWhen.AfterChange
}
