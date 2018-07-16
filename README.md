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
  
  let username = Observable("")
  let password = Observable("")
  
  lazy var inputIsValid: Computed<Bool> = Computed { [weak self] in
    let user = self?.username.value
    let pass = self?.password.value
    return user?.isEmpty == false && pass?.isEmpty == false
  }
  
  override viewDidLoad() {
    super.viewDidLoad()
    
    // bind the text in our username & password fields to their 
    usernameField.b_text.bind(username)
    passwordField.b_text.bind(password)
    
    // only enable the login button if they've entered an username and password
    loginButton.b_enabled.bind(inputIsValid)
    
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

As a side note, `Observable`, `Computed`, and `Event` all inherit from `Subscribable` to provide a common interface to subscribing to changes/events.

### BindingHandlers

`BindingHandler`s describe how a raw data value (ie `Int`, `String`, `NSDate`, etc..) should be applied to a property 
(`UILabel.text`, `UIImageView.image`, etc..)

Some useful examples of what can be done with BindingHandlers:

- `BindingHandlers.loadImage()` - enables binding a `NSURL` to a `UIImage` property
- `BindingHandlers.formatSalary()` - formats a raw salary `Int` as a nice string (ie `100k`)
- `BindingHandlers.autoupdatingTimeAgo()` - enables binding a `NSDate` to a `String` property (ie. `UILabel.text`) that
  shows values like "5 minutes ago", etc.. (and automatically updates the displayed string as time passes)

Generally the raw value (ie a `Double` for fantasy points) should be bubbled up to the UI in the view model, so that it
can be formatted as need for that view.

## UI Bindings

### Property bindings

Many of the `UIKit` classes have been extended to allow binding their properties to `Subscribables`.  These properties are generally to


UIKit                | Fisticuffs       
-------------------- | -----------------------
`UILabel`.`text`     | `UILabel`.`b_text`     
`UITextField`.`text` | `UITextField`.`b_text` 
`UIButton`.`enabled` | `UIButton`.`b_enabled` 
`UISwitch`.`on`      | `UISwitch`.`b_on`      
*etc...*

To bind a `Subscribable` (ie: `Observable`, `Computed`, etc...) to these, the `bind()` method can be used.

```swift
let messageLabel: UILabel = ...
let message = Observable("")
messageLabel.b_text.bind(message)
```

### Events

UI events are exposed as `Event`'s, making it easy to attach behaviour to controls.  For example:

```swift
let button: UIButton = ...

button.b_onTap.subscribe {
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

- Xcode 9 / Swift 4.1
- iOS 8+

### CocoaPods

1. If you haven't already, [install CocoaPods](https://guides.cocoapods.org/using/getting-started.html) and [setup your project for use with CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

2. Add `Fisticuffs` to your `Podfile`:

  ```
  pod 'Fisticuffs', '0.0.7'
  ```

3. Run `pod install`


*NOTE: There may be breaking changes before 1.0, so it is suggested to pin it to a specific version*

### Carthage

1. If you haven't already, install Carthage & setup your project for use with it.  See [here](https://github.com/Carthage/Carthage).

2. Add `Fisticuffs` to your `Cartfile`:

  ```
  github "scoremedia/Fisticuffs" == 0.0.7
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
