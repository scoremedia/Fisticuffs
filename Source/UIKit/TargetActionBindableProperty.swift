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

    fileprivate let disposables = DisposableBag()

    init(control: Control, getter: @escaping Getter, setter: @escaping Setter, events: UIControlEvents) {
        super.init(control: control, getter: getter, setter: setter, extraCleanup: disposables)
        control.addTarget(self, action: #selector(TargetActionBindableProperty.controlEventFired), for: events)
        disposables.add(DisposableBlock { [weak self, weak control] in
            control?.removeTarget(self, action: "controlEventFired", for: events)
        })
    }

    @objc func controlEventFired() {
        self.pushChangeToObservable()
    }

}
