# Fisticuffs

Fisticuffs is a data binding framework for Swift, inspired by [Knockout](http://knockoutjs.com) and shares many of the same concepts:

- **Declarative Bindings**

  Simplify your view controllers by setting up all your view logic in one place.  No need to implement target-actions, delegate methods, etc.
  
- **Automatic Updates**
  
  When your data changes, your UI is automatically updated to reflect those changes.  Likewise, when your users interact with your UI, your data is automatically updated.

- **Automatic Dependency Tracking**

  Easily and implicitly setup a graph of dependencies.  When an underlying dependency changes its value, Fisticuffs will ensure those changes are propagated up.
  
---

⚠️ ***NOTE:*** *Fisticuffs is still alpha/beta. Hopefully the public interface won't change much, but no guarantees until version 1.0*

## Quick Example

Since a code snippet can be worth a thousand words...

```swift
class LoginViewController: UIViewController {
  @IBOutlet var usernameField: UITextField!
  @IBOutlet var passwordField: UITextField!
  @IBOutlet var loginButton: UIButton!
  
  let username: Observable("")
  let password: Observable("")
  
  lazy var inputIsValid: Computed<Bool> = Computed { [weak self] in
    let user = self?.username.value
    let pass = self?.password.value
    return user?.isEmpty == false && pass?.isEmpty == false
  }
  
  override viewDidLoad() {
    super.viewDidLoad()
    
    // bind the text in our username & password fields to their 
    usernameField.b_text <-> username
    passwordField.b_text <-> password
    
    // only enable the login button if they've entered an username and password
    loginButton.b_enabled <-- inputIsValid
    
    // do the login when the user taps the login button 
    loginButton.b_onTap.subscribe { [weak self] in
      LoginManager.doLogin(self?.username.value, self?.password.value)
    }
  }
}
```

## Core Concepts

### Observable

The `Observable` class is one of the basic building blocks of Fisticuffs.  It stores a value and notifies any subscribers when it changes:

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


## UI Bindings

### Binding Setup

UI binding are setup using the following operators:

- `<--` / `-->`
  
  One-way binding.  Data flows in the direction of the arrow.  For example:
  ```swift
  let messageLabel: UILabel = ...
  let message = Observable("")
  messageLabel.b_text <-- message
  
  message.value = "Uh oh, an error has occurred"
  // updates messageField's text automatically
  ```

- `<->`
  
  Two-way binding.  Data flows both directions.  For example, a `UITextField`'s `text` property can be changed by the user or in code by the programmer.
  ```swift
  let nameField: UITextField = ...
  let name = Observable("")
  nameField.b_text <-> name
  
  // `name` will stay in sync with `nameField`'s `text` property, whether we change the value of `name` or the user enters text into the text field
  ```

Or, if you prefer to avoid custom operators, you can use the provided `bind` method:

```swift
let messageLabel: UILabel = ...
let message = Observable("")
messageLabel.b_text.bind(message)
```


### Properties

Generally, bindings for UIKit classes are the original property name prefixed with `b_`.  For example:


UIKit                | Fisticuffs       
-------------------- | -----------------------
`UILabel`.`text`     | `UILabel`.`b_text`     
`UITextField`.`text` | `UITextField`.`b_text` 
`UIButton`.`enabled` | `UIButton`.`b_enabled` 
`UISwitch`.`on`      | `UISwitch`.`b_on`      
*etc...*


### Events

UI events are exposed as `Event`'s, making it easy to attach behaviour to controls.  For example:

```swift
let button: UIButton = ...

button.b_onTap.subscribe {
  print("Pressed button!")
}
```

Additionally, as syntactic sugar, a `+=` operator is provided for subscribing to events:

```swift
let button: UIButton = ...

button.b_onTap += {
  print("Pressed button!")
}
```

### UITableViews / UICollectionViews

Fisticuffs provides support for easily binding data to UITableViews / UICollectionViews.  See example below:

```swift
let tableView: UITableView = ...
let days = Observable(["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"])

tableView.registerClass(UITableViewCell.self forCellReuseIdentifier: "Cell")
tableView.b_configure(days) { config in
  config.useCell(reuseIdentifier: "Cell") { day, cell in
    cell.textLabel?.text = day
  }

  config.allowsMoving = true   // let user reorder the days
  config.allowsDeletion = true   // let user delete days (good-bye Monday! :)
}
```

Some interesting things to note:

- Since we set `allowsMoving` & `allowsDeletion`, users can move & delete rows.  The underlying data (`days`) will be updated automatically
- Any updates we make to `days` in code will be propagated up to the table view (including animating insertions, removals, etc..)

Similar bindings exist for `UICollectionView`

## Installation

Requirements:

- Xcode 7.1 / Swift 2.1
- iOS 8+

### CocoaPods

1. If you haven't already, [install CocoaPods](https://guides.cocoapods.org/using/getting-started.html) and [setup your project for use with CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

2. Add `Fisticuffs` to your `Podfile`:

  ```
  pod 'Fisticuffs', '0.0.2'
  ```

3. Run `pod install`


*NOTE: There may be breaking changes before 1.0, so it is suggested to pin it to a specific version*

### Carthage

1. If you haven't already, install Carthage & setup your project for use with it.  See [here](https://github.com/Carthage/Carthage).

2. Add `Fisticuffs` to your `Cartfile`:

  ```
  github "scoremedia/Fisticuffs" == 0.0.2
  ```

3. Run `carthage update`

*May be breaking changes before 1.0, so it is suggested to pin it to a specific version*

### Manual Installation

1. Download this repository (if using Git, you can add it as a [submodule](https://git-scm.com/docs/git-submodule))

2. Drag `Fisticuffs.xcodeproj` into your Xcode project or workspace

3. Add `Fisticuffs.framework` to your app's **Embedded Binaries** and **Linked Frameworks and Libraries**


## Examples / Tests

Tests and some examples are provided in the `Fisticuffs.xcworkspace`

### Running the Tests

1. Clone this repo

2. To fetch [Quick](https://github.com/Quick/Quick) and [Nimble](https://github.com/Quick/Nimble), run:
  ```
  git submodule update --init --recursive
  ```
  
3. Open `Fisticuffs.xcworkspace`, select the `Fisticuffs` scheme

4. *Product* → *Test*

## License

Fisticuffs is released under the MIT license.
