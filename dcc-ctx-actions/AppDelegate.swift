//
//  AppDelegate.swift
//  dcc-ctx-actions
//
//  Created by Simeon Rolev on 12/13/19.
//  Copyright © 2019 Simeon Rolev. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        do {
            let app = App()
            try app.setUp()
            app.executeAction(action: "PDF_EXPORT")
        } catch {
            return
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

