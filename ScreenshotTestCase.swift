// 9327
//  ScreenshotTestCase.swift
//  InVoiceUITests
//
//  Created by Georg Kitz on 5/21/18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import XCTest

typealias LanguageLocalePair = (language: String, locale: String, output: String)
typealias ExecuteForPairs = () -> Void

class ScreenshotTestCase: XCTestCase {
    
    /*
     to generate all screenshots for all devices you want execute a command like that from the terminal, that will generate them in parallel
     xcodebuild -workspace InVoice.xcworkspace -scheme InVoice -destination 'platform=iOS Simulator,name=iPhone 8 Plus,OS=11.2' -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch),OS=11.2' test | xcpretty
     */
    var supportedLanguagLocalePairs: [LanguageLocalePair] = []
    var externalOutputDir: String? = nil
    
    private var screenshotDirectory: String = ""
    private var deviceName: String = ""
    private(set) var currentLanguage: String?
    private(set) var currentLocale: String?
    private var currentStorageDirectory: String?
    
    override func setUp() {
        super.setUp()
        guard let screenshotDirectory = ProcessInfo.processInfo.environment["IB_SCREENSHOT_DIR"] else {
            fatalError("no screenshot directory was provided as environment variable \'IB_SCREENSHOT_DIR\'")
        }
        
        guard let deviceName = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] else {
            fatalError("couldn't retrieve device name from \'SIMULATOR_DEVICE_NAME\'")
        }
        self.screenshotDirectory = screenshotDirectory
        self.deviceName = deviceName
        self.externalOutputDir = ProcessInfo.processInfo.environment["IB_OUTPUT"]
        continueAfterFailure = false
    }
    
    func executeForPairs(forVideo: Bool = false, _ executor: ExecuteForPairs) {
        
        let monitor = setupNotificationHandlers()
        
        if let externalOutputDir = externalOutputDir, supportedLanguagLocalePairs.count == 0 {
            let app = XCUIApplication()
            app.launchArguments += ["-isuitesting", "-ui_testing"]
            if forVideo {
                app.launchArguments += ["-uitestVideo"]
            }
            app.launch()
            
            currentStorageDirectory = checkPathExistsOtherwiseCreate(for: ("", "", externalOutputDir))
            executor()
        } else {
            
            supportedLanguagLocalePairs.forEach { (pair) in
                deleteApp()
                
                let app = XCUIApplication()
                app.launchArguments += ["-isuitesting", "-ui_testing"]
                app.launchArguments += ["-AppleLanguages", "(\(pair.language))"]
                app.launchArguments += ["-AppleLocale", "\"\(pair.locale)\""]
                if forVideo {
                    app.launchArguments += ["-uitestVideo"]
                }
                app.launch()
                
                currentLocale = pair.locale
                currentLanguage = pair.language
                currentStorageDirectory = checkPathExistsOtherwiseCreate(for: pair)
                executor()
                
                app.terminate()
            }
        }
        removeUIInterruptionMonitor(monitor)
    }
    
    func screenshot(name: String) {
        guard let currentStorageDirectory = currentStorageDirectory else {
            print("no current storage directory for screenshots is setup")
            return
        }
        let fileURL = URL(fileURLWithPath: currentStorageDirectory).appendingPathComponent(deviceName + "-" + name + ".png")
        let screenshot = XCUIScreen.main.screenshot()
        do {
            try screenshot.pngRepresentation.write(to: fileURL)
        } catch let error {
            print("Creating screenshot failed with: \(error)")
        }
    }
    
    func deleteApp() {
        let token = addUIInterruptionMonitor(withDescription: #function) { (alert) -> Bool in
            alert.buttons.element(boundBy: 1).tap()
//            alert.buttons["Delete"].tap()
            return true
        }
        
        Springboard.deleteMyApp(resetSettings: false)
        
        removeUIInterruptionMonitor(token)
    }
    
    private func checkPathExistsOtherwiseCreate(for language: LanguageLocalePair) -> String {
        let directory = screenshotDirectory + "/" + language.output + "/"
        let fileManager = FileManager()
        if !fileManager.fileExists(atPath: directory) {
            do {
                try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print("Creating screenshot directory failed with: \(error)")
            }
        }
        return directory
    }
    
    private func setupNotificationHandlers() -> NSObjectProtocol {
        return addUIInterruptionMonitor(withDescription: #function) { (alert) -> Bool in
            print("ALERT! ALERT!")
            
            let t1 = alert.buttons.element(boundBy: 0).label
            let t2 = alert.buttons.element(boundBy: 1).label
            
            if t1.count > t2.count {
                print("Tap: \(t2)")
                alert.buttons.element(boundBy: 1).tap()
            } else {
                print("Tap: \(t1)")
                alert.buttons.element(boundBy: 0).tap()
            }
            return true
        }
    }
    
    func delay(_ interval: TimeInterval) {
        let e = expectation(description: UUID().uuidString)
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            e.fulfill()
        }
        waitForExpectations(timeout: interval + 1)
    }
}
