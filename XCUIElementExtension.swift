//
//  XCUIElementExtension.swift
//  InVoiceUITests
//
//  Created by Georg Kitz on 5/21/18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import XCTest

extension XCUIElement {
    func tap(at index: UInt) {
        guard buttons.count > 0 else { return }
        var segments = (0..<buttons.count).map { buttons.element(boundBy: $0) }
        segments.sort { (el1, el2) -> Bool in
            return el1.frame.origin.x < el2.frame.origin.x
        }
        segments[Int(index)].tap()
    }
}
