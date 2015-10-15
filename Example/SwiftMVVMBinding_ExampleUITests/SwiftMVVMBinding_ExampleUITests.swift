//
//  SwiftMVVMBinding_ExampleUITests.swift
//  SwiftMVVMBinding_ExampleUITests
//
//  Created by Darren Clark on 2015-10-15.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import XCTest
import Nimble

class SwiftMVVMBinding_ExampleUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        
        let app = XCUIApplication()
        app.tables.staticTexts["To Do List Example"].tap()
        
        do {
            app.navigationBars["To Do Example"].buttons["Add"].tap()
            
            let collectionViewsQuery = app.alerts["To Do"].collectionViews
            collectionViewsQuery.textFields["Title"].typeText("Clean out the garage")
            collectionViewsQuery.buttons["Done"].tap()
        }
        
        do {
            app.navigationBars["To Do Example"].buttons["Add"].tap()
            
            let collectionViewsQuery = app.alerts["To Do"].collectionViews
            collectionViewsQuery.textFields["Title"].typeText("Gotta fix that step")
            collectionViewsQuery.buttons["Done"].tap()
        }
        
        do {
            app.navigationBars["To Do Example"].buttons["Add"].tap()
            
            let collectionViewsQuery = app.alerts["To Do"].collectionViews
            collectionViewsQuery.textFields["Title"].typeText("Go Golfing")
            collectionViewsQuery.buttons["Done"].tap()
        }
        
        // Gotta add a dummy one to fix (broken?) Xcode testing stuff... It seems it fails to find
        // the .staticTexts["Go Golfing"], even if waiting a few seconds to let things "settle" down
        do {
            app.navigationBars["To Do Example"].buttons["Add"].tap()
            
            let collectionViewsQuery = app.alerts["To Do"].collectionViews
            collectionViewsQuery.textFields["Title"].typeText("(extra one to work around Xcode bug)")
            collectionViewsQuery.buttons["Done"].tap()
        }
        
        expect(app.tables.staticTexts["Clean out the garage"].exists) == true
        expect(app.tables.staticTexts["Gotta fix that step"].exists) == true
        expect(app.tables.staticTexts["Go Golfing"].exists) == true
        
        
        do {
            // Enter edit mode
            app.navigationBars["To Do Example"].buttons["Edit"].tap()
            expect(app.navigationBars["To Do Example"].buttons["Done"].exists) == true
        }
        
        do {
            // Test delete
            
            app.tables.buttons["Delete Clean out the garage"].tap()
            app.tables.buttons["Delete"].tap()
            
            expect(app.tables.staticTexts["Clean out the garage"].exists) == false
        }
        
        do {
            // Test reordering
            let golfing = app.tables.buttons["Reorder Go Golfing"]
            let fixStep = app.tables.buttons["Reorder Gotta fix that step"]
            golfing.pressForDuration(0.3, thenDragToElement: fixStep)
            
            let golfingFrame = app.tables.staticTexts["Go Golfing"].frame
            let fixStepFrame = app.tables.staticTexts["Gotta fix that step"].frame
            
            // if move worked, Go Golfing will be above Gotta fix that step
            expect(golfingFrame.minY) < fixStepFrame.minY
        }
        
        do {
            // Exit edit mode
            app.navigationBars["To Do Example"].buttons["Done"].tap()
            expect(app.navigationBars["To Do Example"].buttons["Edit"].exists) == true
        }
        
        do {
            app.tables.staticTexts["Go Golfing"].tap()
            // no way to really test that the checkmark was shown unfortunately...
        }
    }
    
    func testDummy() {
        
        let app = XCUIApplication()
        app.tables.staticTexts["To Do List Example"].tap()
        
        let toDoExampleNavigationBar = app.navigationBars["To Do Example"]
        toDoExampleNavigationBar.buttons["Add"].tap()
        
        let collectionViewsQuery = app.alerts["To Do"].collectionViews
        let titleTextField = collectionViewsQuery.textFields["Title"]
        titleTextField.typeText("hdsaf")
        
        let doneButton = collectionViewsQuery.buttons["Done"]
        doneButton.tap()
        titleTextField.typeText("dsfa")
        doneButton.tap()
        toDoExampleNavigationBar.buttons["Edit"].tap()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Table).element.pressForDuration(1.1);
        toDoExampleNavigationBar.buttons["Done"].tap()
        
        
    }
}
