//
//  XCUIApplication+Helper.swift
//  InVoiceUITests
//
//  Created by Georg Kitz on 14.03.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

extension XCUIApplication {
    func pressKeyboardDismissButton() {
        //this was taken from the recording, not sure why this is build up like that
        toolbars.children(matching: .other).element.children(matching: .other)
            .element.children(matching: .button).allElementsBoundByIndex.last?.tap()
    }
}
