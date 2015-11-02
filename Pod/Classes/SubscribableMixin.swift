//
//  SubscribableMixin.swift
//  Pods
//
//  Created by Darren Clark on 2015-11-02.
//
//

protocol SubscribableMixin: class {
    typealias ValueType
    
    var currentValue: ValueType? { get }
    var subscriptions: [Subscription<ValueType>] { get set }
}

extension SubscribableMixin {
    
    @warn_unused_result(message="Returned Disposable must be used to cancel the subscription")
    func addSubscription(options: SubscriptionOptions = SubscriptionOptions(), callback: (ValueType?, ValueType) -> Void) -> Disposable {
        var subscription: Subscription<ValueType>? = nil
        subscription = Subscription(callback: callback, when: options.when, disposeBlock: {
            self.subscriptions = self.subscriptions.filter { s in s !== subscription }
            subscription = nil
        })
        subscriptions.append(subscription!)
        if let value = currentValue where options.notifyOnSubscription {
            callback(value, value)
        }
        return subscription!
    }
    
    
    func postChangeNotification(when: NotifyWhen, oldValue: ValueType?, newValue: ValueType) {
        for subscription in subscriptions where subscription.when == when {
            subscription.callback(oldValue, newValue)
        }
    }

}
