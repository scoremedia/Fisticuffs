
# 0.0.16
------

- [#33](https://github.com/scoremedia/Fisticuffs/pull/33): Fix the working directory by [tahirmt](https://github.com/tahirmt)
- [#32](https://github.com/scoremedia/Fisticuffs/pull/32): Add cocoapods publish and bump version / create release actions by [tahirmt](https://github.com/tahirmt)
# Changelog

## 0.0.11
 - Fixes Podspec swift version to 5.0

## 0.0.10
 - Adds Xcode 11 and swift 5.0 compatibility

## 0.0.9
 - Adds property wrapper support to `Observable` 

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
