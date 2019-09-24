//
//  AppStoreUpdateCheckerTests.swift
//  AppStoreUpdateCheckerTests
//
//  Created by MTIshiwata on 2019/09/18.
//  Copyright © 2019 Mates Inc. All rights reserved.
//

import XCTest
@testable import AppStoreUpdateChecker

class AppStoreUpdateCheckerTests: XCTestCase {

    func testCheck() {
        AppStoreUpdateChecker.check(setBundleID: "com.apple.itunesu", setAppVersion: "1.0") { appURL in
            XCTAssertEqual(appURL != nil, true)
        }
        AppStoreUpdateChecker.check(setBundleID: "hoge.hoge.hoge", setAppVersion: "1.0") { appURL in
            XCTAssertEqual(appURL != nil, false)
        }
    }

}
