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
    let observer = ProcessObserver()
    var app: App {
        get { return self.observer.app }
    }
    
    override init() {
        super.init()
        self.observer.listen()
    }
    
    deinit {
        print("deinit")
    }

    func loadIcons () -> [String: NSImage] {
        let theme = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        let color: NSColor = theme == "Dark" ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        return [
            "pdf": NSImage(named: "pdf")!.tinting(with: color),
            "distill": NSImage(named: "distill")!.tinting(with: color),
            "photo": NSImage(named: "photo")!.tinting(with: color),
            "link": NSImage(named: "link")!.tinting(with: color),
            "dcc": NSImage(named: "dcc")!.tinting(with: color)
        ]
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        if case menuKind = FIMenuKind.contextualMenuForItems {
            if !self.observer.isRunning {
                return nil
            }
            
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
            
            let PDFItem = NSMenuItem(title: "Export PDF", action: #selector(pdf_export(_:)), keyEquivalent: "")
            let DISTILLItem = NSMenuItem(title: "Export 3D model", action: #selector(distill(_:)), keyEquivalent: "")
            let PHOTOGRAMItem = NSMenuItem(title: "Photos to 3D model", action: #selector(photogram(_:)), keyEquivalent: "")
            let LINKItem = NSMenuItem(title: "Shareable link", action: #selector(link(_:)), keyEquivalent: "")
            
            let icons = self.loadIcons()
            mainDropdown.image = icons["dcc"]
            PDFItem.image = icons["pdf"]
            DISTILLItem.image = icons["distill"]
            PHOTOGRAMItem.image = icons["photo"]
            LINKItem.image = icons["link"]
            
            switch selectionType {
                case .VectorworksFile:
                    submenu.addItem(PDFItem)
                    submenu.addItem(DISTILLItem)
                    submenu.addItem(NSMenuItem.separator())
                case .PhotogrametryFile:
                    submenu.addItem(PHOTOGRAMItem)
                    submenu.addItem(NSMenuItem.separator())
                default: break
            }

            submenu.addItem(LINKItem)
            return menu
        }

        return nil
    }
    
    @IBAction func pdf_export(_: Any) { self.app.executeAction(action: "PDF_EXPORT") }
    @IBAction func distill(_: Any) { self.app.executeAction(action: "DISTILL") }
    @IBAction func photogram(_: Any) { self.app.executeAction(action: "PHOTOGRAM") }
    @IBAction func link(_: Any) { self.app.executeAction(action: "LINK") }
}

extension NSImage {
    func tinting(with tintColor: NSColor) -> NSImage {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return self }
        
        return NSImage(size: size, flipped: false) { bounds in
            guard let context = NSGraphicsContext.current?.cgContext else { return false }
            tintColor.set()
            context.clip(to: bounds, mask: cgImage)
            context.fill(bounds)
            return true
        }
    }
}
