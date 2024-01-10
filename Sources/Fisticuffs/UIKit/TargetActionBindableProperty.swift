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

    init(control: Control, getter: @escaping Getter, setter: @escaping Setter, events: UIControl.Event) {
        super.init(control: control, getter: getter, setter: setter, extraCleanup: disposables)
        let actionId = UIAction.Identifier(UUID().uuidString)
        control.addAction(.init(identifier: actionId,handler: { [weak self] _ in
            guard let self else { return }
            self.pushChangeToCurrentValueSubscribable()
        }), for: events)
        disposables.add(DisposableBlock { [weak control] in
            control?.removeAction(identifiedBy: actionId, for: events)
        })
    }
}
