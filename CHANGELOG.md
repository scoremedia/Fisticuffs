

# 0.0.17
------

- [#43](https://github.com/scoremedia/Fisticuffs/pull/43): Change the bump version action permissions by [tahirmt](https://github.com/tahirmt)
- [#42](https://github.com/scoremedia/Fisticuffs/pull/42): Make any subscribable type conform to hashable by [tahirmt](https://github.com/tahirmt)
- [#41](https://github.com/scoremedia/Fisticuffs/pull/41): IPFM-427: Update action repository permission by [tahirmt](https://github.com/tahirmt)
- [#40](https://github.com/scoremedia/Fisticuffs/pull/40): IPFM-534: Update create pull request by [tahirmt](https://github.com/tahirmt)
- [#39](https://github.com/scoremedia/Fisticuffs/pull/39): Github Action deprecations; minimum iOS deployment update by [rayray](https://github.com/rayray)
- [#38](https://github.com/scoremedia/Fisticuffs/pull/38): Bump jmespath from 1.4.0 to 1.6.1 by [dependabot[bot]](https://github.com/apps/dependabot)
- [#37](https://github.com/scoremedia/Fisticuffs/pull/37): Add pods token by [tahirmt](https://github.com/tahirmt)

# 0.0.16
------

- [#34](https://github.com/scoremedia/Fisticuffs/pull/34): Use macOS for bump version by [tahirmt](https://github.com/tahirmt)
- [#33](https://github.com/scoremedia/Fisticuffs/pull/33): Fix the working directory by [tahirmt](https://github.com/tahirmt)
- [#32](https://github.com/scoremedia/Fisticuffs/pull/32): Add cocoapods publish and bump version / create release actions by [tahirmt](https://github.com/tahirmt)
# Changelog

## 0.0.11
 - Fixes Podspec swift version to 5.0

## 0.0.10
 - Adds Xcode 11 and swift 5.0 compatibility

## 0.0.9
 - Adds property wrapper support to `CurrentValueSubscribable` 

## 0.0.8
 - Adds Xcode 10 and Swift 4.2 compatibility

## 0.0.7
 - Scopes `Event<>` explicitly to `Fisticuffs.Event<>` in UIKit extensions. Fisticuffs declares `Event<>` which seems to conflict with some swiftification of `UIEvent` -> `UIControl.Event`

## 0.0.6
 - Fixes an issue in the podspec that would prevent Fisticuffs from building under the new xcode build system.

## 0.0.5
 - Adds Swift 4.1 Compatibility

## 0.0.2

`UITableView` & `UICollectionView` binding improvements, including:
  - Fix bug with `UITableView` selection handling where tapping the same row 
    multiple times would add it to the list of selections multiple times
  - Added support for disabling selection of specific items in (see 
  	`DataSource.disableSectionFor(...)`)
  - Added `DataSource.selection` - for working with single selection

## 0.0.1

Initial release
