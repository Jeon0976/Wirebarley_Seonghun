//
//  Wirebaley_JeonSeongHunUITests.swift
//  Wirebaley_JeonSeongHunUITests
//
//  Created by 전성훈 on 2023/12/14.
//

import XCTest

final class Wirebaley_JeonSeongHunUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        sleep(1)
    }

    func test_휠_움직이고_Amout_값_입력_후_결과값_확인하기() throws {
        // given
        let textField = app.textFields["amountTextField"]
        let picker = app.pickers["Picker"]
        let result = app.staticTexts["Result"].label
        
        // when
        picker.swipeUp()
        textField.tap()
        textField.typeText("1000")
        
        // then
        XCTAssertNotEqual(result, NSLocalizedString("BeforeReceivedAmount", comment: ""))
        XCTAssertNotEqual(result,
                          String(format: NSLocalizedString("ReceivedAmount", comment: ""),"0.0 PHP")
        )
    }
    
    func test_값_초과하고_알람_확인하기() throws {
        // given
        let textField = app.textFields["amountTextField"]
        let alertButton = app.alerts.buttons["OK"]
        
        
        // when
        textField.tap()
        textField.typeText("100000")
                
        // then
        XCTAssertTrue(alertButton.exists)
    }

}
