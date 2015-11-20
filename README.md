# SwiftMVVMBinding

SwiftMVVMBinding is a data binding framework for Swift, inspired by [Knockout](http://knockoutjs.com) and shares many of the same concepts:

- **Declarative Bindings**

  Simplify your view controllers by setting up all your view logic in one place.  No need to implement target-actions, delegate methods, etc.
  
- **Automatic Updates**
  
  When your data changes, your UI is automatically updated to reflect those changes.  Likewise, when your users interact with your UI, your data is automatically updated.

- **Automatic Dependency Tracking**

  Easily and implicitly setup a graph of dependencies.  When an underlying dependency changes its value, SwiftMVVMBinding will ensure those changes are propagated up.
  
---

⚠️ ***NOTE:*** *SwiftMVVMBinding is still alpha/beta. Hopefully the public interface won't change much, but no guarantees until version 1.0*

## Core Concepts

### Observable

The `Observable` class is one of the basic building blocks of SwiftMVVMBinding.  It stores a value and notifies any subscribers when it changes:

```swift
let observable = Observable<String>("")

observable.subscribe { oldValue, newValue in
  print(newValue)
}

observable.value = "Hello, world"
// prints "Hello, world"
```

### Computed

`Computed` is the read-only sibling of `Observable`.  It uses a closure to compute its value.  Additionally, it automatically updates its value when any of its `Observable` (and `Computed`) dependencies change.  For example:

```swift
let name = Observable<String>("")
let greeting: Computed<String> = Computed {
  return "Hello, " + name.value
}

greeting.subscribe { oldValue, newValue in
  print(newValue)
}

name.value = "world"
// prints "Hello, world" because the change to `name` is propagated up to `greeting`
```

### Event

Finally, the `Event` class provides support for broadcasting events to its subscribers.  It shares a similar interface to `Observable` & `Computed`:

```swift
let event = Event<String>()

event.subscribe { _, str in
  print(str)
}

event.fire("Hello, world")
// prints "Hello, world"
```

### Subscribable

As a side note, `Observable`, `Computed`, and `Event` all implement the same `Subscribable` protocol to provide a common interface to subscribing to changes/events.


