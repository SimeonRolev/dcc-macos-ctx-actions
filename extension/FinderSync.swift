//
//  FinderSync.swift
//  extension
//
//  Created by Simeon Rolev on 12/17/19.
//  Copyright © 2019 Simeon Rolev. All rights reserved.
//

import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
    let app = App()
    
    func setUp () {
        if let _ = try? app.setUp() {
            FIFinderSyncController.default().directoryURLs = Set(app.syncedDirs.map { URL(fileURLWithPath: $0) })
        } else {
            FIFinderSyncController.default().directoryURLs = []
        }
    }
    
    override init() {
        super.init()
        self.setUp()
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        if case menuKind = FIMenuKind.contextualMenuForItems {
            self.setUp()
            
            if let _selectedURLs = FIFinderSyncController.default().selectedItemURLs() {
                self.app.selectedFiles = _selectedURLs
            } else {
                return nil
            }

            let selectionType: SelectionType = app.getSelectionType()
            
            let menu = NSMenu(title: "")
            let submenu = NSMenu()
            let mainDropdown = NSMenuItem(title: "Vectorworks Cloud Services", action: nil, keyEquivalent: "")
            
            menu.addItem(mainDropdown)
            menu.setSubmenu(submenu, for: mainDropdown)
            
            switch selectionType {
            case .VectorworksFile:
                submenu.addItem(withTitle: "Export PDF", action: #selector(pdf_export(_:)), keyEquivalent: "")
                submenu.addItem(withTitle: "Export 3D model", action: #selector(distill(_:)), keyEquivalent: "")
                submenu.addItem(NSMenuItem.separator())
            case .ImageFile:
                submenu.addItem(withTitle: "Photos to 3D model", action: #selector(photogram(_:)), keyEquivalent: "")
                submenu.addItem(withTitle: "Stylize image", action: #selector(stylize(_:)), keyEquivalent: "")
                submenu.addItem(withTitle: "Upsample image", action: #selector(upsample(_:)), keyEquivalent: "")
                submenu.addItem(NSMenuItem.separator())
            case .Photogrammetry:
                submenu.addItem(withTitle: "Photos to 3D model", action: #selector(photogram(_:)), keyEquivalent: "")
                submenu.addItem(NSMenuItem.separator())
            default: break
            }

            submenu.addItem(withTitle: "Shareable link", action: #selector(link(_:)), keyEquivalent: "")
            return menu
        }

        return nil
    }
    
    @IBAction func pdf_export(_: Any) { self.app.executeAction(action: "PDF_EXPORT") }
    @IBAction func distill(_: Any) { self.app.executeAction(action: "DISTILL") }
    @IBAction func photogram(_: Any) { self.app.executeAction(action: "PHOTOGRAM") }
    @IBAction func link(_: Any) { self.app.executeAction(action: "LINK") }
    @IBAction func stylize(_: Any) { self.app.executeAction(action: "STYLIZE") }
    @IBAction func upsample(_: Any) { self.app.executeAction(action: "UPSAMPLE") }
}
