//
//  TargetActionBindableProperty.swift
//  Fisticuffs
//
//  Created by Darren Clark on 2016-02-16.
//  Copyright © 2016 theScore. All rights reserved.
//

import Foundation
import UIKit

class TargetActionBindableProperty<Control: UIControl, ValueType>: BidirectionalBindableProperty<Control, ValueType> {

    private let disposables = DisposableBag()

    init(control: Control, getter: Getter, setter: Setter, events: UIControlEvents) {
        super.init(control: control, getter: getter, setter: setter, extraCleanup: disposables)
        control.addTarget(self, action: "controlEventFired", forControlEvents: events)
        disposables.add(DisposableBlock { [weak self, weak control] in
            control?.removeTarget(self, action: "controlEventFired", forControlEvents: events)
        })
    }

    @objc func controlEventFired() {
        self.pushChangeToObservable()
    }

}
