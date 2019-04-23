//
//  ViewController.swift
//  FisticuffsPropertyDelegatesDemo
//
//  Created by Darren Clark on 2019-04-22.
//  Copyright © 2019 theScore. All rights reserved.
//

import Cocoa
import Fisticuffs


class ViewModel {
    @Observable
    var name: String = "World"

    @Computed()
    var greeting: String

    init() {
        $greeting.is(self) { "Hello, \($0.name)" }
    }
}

class ViewController: NSViewController {

    let viewModel = ViewModel()

    @IBOutlet var textField: NSTextField!
    @IBOutlet var inputTextField: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.$greeting.bindTo(textField, \.stringValue)
        viewModel.$name.bindTwoWay(inputTextField, \.stringValue)

        _ = viewModel.$greeting.subscribe { _, newValue in
            print(newValue)
        }

        viewModel.name = "Universe"
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

class Bindings {
    class Binding {
        var fisticuffs: Disposable
        var kvo: Any?

        init(_ fisticuffs: Disposable, _ kvo: Any? = nil) {
            self.fisticuffs = fisticuffs
            self.kvo = kvo
        }

        deinit {
            fisticuffs.dispose()
        }
    }

    var current: [AnyKeyPath: Binding] = [:]
}

extension NSView {
    private static var key = 0

    var bindings: Bindings {
        return associatedObjectProperty(self, &NSView.key) { _ in Bindings() }
    }
}

extension Subscribable {
    func bindTo<View: NSView>(_ view: View, _ keyPath: ReferenceWritableKeyPath<View, Value>) {
        let disposable = subscribe { [weak view] _, newValue in view?[keyPath: keyPath] = newValue }
        view.bindings.current[keyPath] = Bindings.Binding(disposable)
    }
}

extension Observable {
    func bindTwoWay<View: NSView>(_ view: View, _ keyPath: ReferenceWritableKeyPath<View, Value>) {
        var ignoreKVO = false

        let disposable = subscribe { [weak view] _, newValue in
            ignoreKVO = true
            view?[keyPath: keyPath] = newValue
            ignoreKVO = false
        }

        // TODO: Fix this
        let kvo = view.observe(keyPath, options: [.initial, .new]) { [weak self] _, change in
            if !ignoreKVO {
                self?.value = change.newValue!
            }
        }

        view.bindings.current[keyPath] = Bindings.Binding(disposable, kvo)
    }
}

//extension NSView {
//    func bind<This: NSView, T>(_ subscribable: Subscribable<T>, to keyPath: @escaping (This, T) -> Void) {
//        assert(self is This)
//
//        let opts = SubscriptionOptions(notifyOnSubscription: true, when: .afterChange)
//        _ = subscribable.subscribe(opts) { [weak self] _, newValue in
//            guard let this = self else { return }
//            keyPath(this as! This, newValue)
//        }
//    }
//}
