//
//  SpringboardCleanup.swift
//  StargateUITests
//
//  Created by Georg Kitz on 19/09/2017.
//  Copyright © 2017 DeliveryHero AG. All rights reserved.
//

import Foundation
import XCTest

class Springboard {
    static let springboard = XCUIApplication(privateWithPath: nil, bundleID: "com.apple.springboard")!
    
    /**
     Terminate and delete the app via springboard
     */
    
    class func deleteMyApp(resetSettings: Bool) {
        XCUIApplication().terminate()
        
        // Resolve the query for the springboard rather than launching it
        
        springboard.resolve()
        
        // Force delete the app from the springboard
        let query = springboard.icons.containing(NSPredicate(format: "identifier=%@", "InvoiceBot"))
        let icon: XCUIElement
        if query.count == 1 {
            icon = query.firstMatch
        } else {
            icon = query.element(boundBy: 1)
        }
        if icon.exists {
            springboard.swipeLeft()
            sleep(2)
            
            let iconFrame = icon.frame
            let springboardFrame = springboard.frame
            icon.press(forDuration: 5)

            
            // Tap the little "X" button at approximately where it is. The X is not exposed directly
            
            springboard.coordinate(withNormalizedOffset: CGVector(dx: (iconFrame.minX + 3) / springboardFrame.maxX, dy: (iconFrame.minY + 3) / springboardFrame.maxY)).tap()
            springboard.tap()
            springboard.tap()
            //            springboard.alerts.buttons["Delete"].tap()
            
            // Press home once make the icons stop wiggling
            
            XCUIDevice.shared.press(.home)
            
            if resetSettings {
                // Press home again to go to the first page of the springboard
                XCUIDevice.shared.press(.home)
                // Wait some time for the animation end
                Thread.sleep(forTimeInterval: 0.5)
                
                let settingsIcon = springboard.icons["Settings"]
                if settingsIcon.exists {
                    settingsIcon.tap()
                    
                    guard let settings = XCUIApplication(privateWithPath: nil, bundleID: "com.apple.Preferences") else { return }
                    settings.tables.staticTexts["General"].tap()
                    settings.tables.staticTexts["Reset"].tap()
                    settings.tables.staticTexts["Reset Location & Privacy"].tap()
                    settings.buttons["Reset Warnings"].tap()
                    settings.terminate()
                }
            }
        }
    }
}
