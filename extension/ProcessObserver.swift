//
//  ProcessObserver.swift
//  process-listener
//
//  Created by Simeon Rolev on 1/9/20.
//  Copyright © 2020 Simeon Rolev. All rights reserved.
//

import Foundation
import AppKit

class ProcessObserver {
    let debug = false
    
    var processObservers = [NSKeyValueObservation]()
    var directoryObservers = [DirectoryObserver]()
    
    var isRunning: Bool = false
    
    static func isDCC (_ app: NSRunningApplication) -> Bool {
        return (app.executableURL?.path ?? "").contains("Vectorworks Cloud Services")
    }
    
    func setPathComponents (app: NSRunningApplication, kind: NSKeyValueObservedChange<Any>.Kind) {
        if !ProcessObserver.isDCC (app) { return }
        if kind == NSKeyValueObservedChange.Kind.removal {
            self.clear()
        }
        if kind == NSKeyValueObservedChange.Kind.insertion {
            do {
                let cachesDir = try App.getCachesDir(pathComponents: app.executableURL?.pathComponents ?? [])
                self.directoryObservers = [DirectoryObserver(cachesDir: cachesDir)]
                self.isRunning = true
            } catch {
                self.clear()
            }
        }
    }
    
    func clear () {
        self.isRunning = false
        self.directoryObservers.forEach{ $0.clear() }
        self.directoryObservers = []
    }
    
    func listen () {
        // Debug
        if debug {
            let cachesDir = try! App.getCachesDir(pathComponents: [], debug: true)
            self.directoryObservers = [DirectoryObserver(cachesDir: cachesDir)]
            self.isRunning = true
            return
        }
        
        // Init
        for app in NSWorkspace.shared.runningApplications {
            self.setPathComponents(app: app, kind: NSKeyValueObservedChange.Kind.insertion)
        }

        // Observe changes
        self.processObservers = [
            NSWorkspace.shared.observe(\.runningApplications, options: [.new, .old]) {(model, change) in
                if let newVal = change.newValue {
                    self.setPathComponents(app: newVal[0], kind: change.kind)
                }
                if let oldVal = change.oldValue {
                    self.setPathComponents(app: oldVal[0], kind: change.kind)
                }
            }
        ]
    }
}
