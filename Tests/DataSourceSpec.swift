//  The MIT License (MIT)
//
//  Copyright (c) 2015 theScore Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import Quick
import Nimble
@testable import Fisticuffs


class DataSourceSpec: QuickSpec {
    override func spec() {
        var observable: Observable<[Int]>!
        var selections: Observable<[Int]>!
        var selection: Observable<Int?>!
        var dataSource: DataSource<Observable<[Int]>, FauxDataSourceView>!
        
        beforeEach {
            observable = Observable([1, 2, 3, 4, 5])
            selections = Observable([])
            selection = Observable(nil)
            dataSource = DataSource(subscribable: observable, view: FauxDataSourceView())
            dataSource.selections = selections
            dataSource.selection = selection
        }
        
        describe("DataSource") {
            it("should have one section") {
                expect(dataSource.numberOfSections()) == 1
            }
            
            it("should return the correct number of items in that section") {
                expect(dataSource.numberOfItems(section: 0)) == 5
            }
            
            it("should return items by index path") {
                expect(dataSource.itemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))) == 1
                expect(dataSource.itemAtIndexPath(NSIndexPath(forItem: 3, inSection: 0))) == 4
            }

            context("multiple selection") {
                it("should track selections") {
                    dataSource.deselectOnSelection = false
                    
                    dataSource.didSelect(indexPath: NSIndexPath(forItem: 0, inSection: 0))
                    expect(selections.value) == [1]
                    
                    dataSource.didSelect(indexPath: NSIndexPath(forItem: 3, inSection: 0))
                    expect(selections.value) == [1, 4]
                }
                
                it("should track deselections") {
                    dataSource.deselectOnSelection = false
                    
                    selections.value = [3]
                    
                    dataSource.didDeselect(indexPath: NSIndexPath(forItem: 2, inSection: 0))
                    expect(selections.value) == []
                }
            }

            context("single selection") {
                it("should track selections") {
                    dataSource.deselectOnSelection = false
                    
                    dataSource.didSelect(indexPath: NSIndexPath(forItem: 0, inSection: 0))
                    expect(selection.value) == 1

                    // simulate deselect that UITableView/UICollectionView would send
                    dataSource.didDeselect(indexPath: NSIndexPath(forItem: 0, inSection: 0))

                    dataSource.didSelect(indexPath: NSIndexPath(forItem: 3, inSection: 0))
                    expect(selection.value) == 4
                }
                
                it("should track deselections") {
                    dataSource.deselectOnSelection = false
                    
                    selection.value = 3
                    
                    dataSource.didDeselect(indexPath: NSIndexPath(forItem: 2, inSection: 0))
                    expect(selection.value).to(beNil())
                }
            }

            context("when single & multiple selection are used") {
                it("should clear all selections when selection is set to nil") {
                    selections.value = [1, 2, 3]
                    selection.value = nil
                    expect(selections.value) == []
                }

                it("should add to the selections array when selection is set") {
                    selections.value = [1, 2]
                    selection.value = 3
                    expect(selections.value) == [1, 2, 3]
                    expect(selection.value) == 3
                }

                it("should set a selection value when selections is set") {
                    selections.value = [1, 2]
                    expect(selections.value) == [1, 2]
                    expect(selection.value).toNot(beNil()) // not defined it will be 1 or 2
                }

                it("should unset selection when all selections are removed") {
                    selection.value = 5
                    selections.value = []
                    expect(selection.value).to(beNil())
                }
            }
            
            it("should support moving items") {
                dataSource.move(source: NSIndexPath(forItem: 2, inSection: 0), destination: NSIndexPath(forItem: 0, inSection: 0))
                expect(dataSource.itemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))) == 3
                expect(observable.value) == [3, 1, 2, 4, 5]
            }
            
            it("should support deleting items") {
                dataSource.delete(indexPath: NSIndexPath(forItem: 0, inSection: 0))
                expect(dataSource.itemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))) == 2
                expect(observable.value) == [2, 3, 4, 5]
            }
        }
    }
    
    private class FauxDataSourceView: DataSourceView {
        typealias CellView = Void
        
        func reloadData() { }
        func insertCells(indexPaths indexPaths: [NSIndexPath]) { }
        func deleteCells(indexPaths indexPaths: [NSIndexPath]) { }
        func batchUpdates(updates: () -> Void) { }
        
        func indexPathsForSelections() -> [NSIndexPath]? { return [] }
        func select(indexPath indexPath: NSIndexPath) { }
        func deselect(indexPath indexPath: NSIndexPath) { }
        
        func dequeueCell(reuseIdentifier reuseIdentifier: String, indexPath: NSIndexPath) -> Void { }

    }
}
