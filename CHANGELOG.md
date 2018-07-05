# Changelog

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
