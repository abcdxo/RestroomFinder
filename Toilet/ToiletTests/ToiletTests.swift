//
//  ToiletTests.swift
//  ToiletTests
//
//  Created by Nick Nguyen on 3/21/20.
//  Copyright © 2020 Nick Nguyen. All rights reserved.
//

import XCTest
@testable import Toilet
class ToiletTests: XCTestCase {

    let restRoomController = RestroomController()
    
    func testFetchRestroomNearby() {
        restRoomController.fetchRestRoom(lat: 0.00, long: 20.0) { (restroom, _) in
            XCTAssertTrue(self.restRoomController.restrooms.count != 0)
        }
    }
}
