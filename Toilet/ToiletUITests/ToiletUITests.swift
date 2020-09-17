//
//  ToiletUITests.swift
//  ToiletUITests
//
//  Created by Nick Nguyen on 3/21/20.
//  Copyright © 2020 Nick Nguyen. All rights reserved.
//

import XCTest

class ToiletUITests: XCTestCase {

    let app = XCUIApplication()
    
    private var favoriteTabBarItem: XCUIElement {
        return app.tabBars.buttons["Favorites"]
    }
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        app.launch()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    func testTabBar() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Favorites"].tap()
        XCTAssert(app.navigationBars.staticTexts["Favorite Restrooms"].exists)
        
    }
}
