//
//  App.swift
//  dcc-ctx-actions
//
//  Created by Simeon Rolev on 12/13/19.
//  Copyright © 2019 Simeon Rolev. All rights reserved.
//

import Foundation

enum AppError: Error {
    case appNotRunning
    case fileReadFailed(fn: String)
    case fileContentsNotParsed(fn: String)
    case rootFolderNotFound
    case UnknownError
}

enum SelectionType: String {
    case VectorworksFile
    case PhotogrametryFile
    case OtherFile
}

class App {
    var debug: Bool = true
    
    var name: String = ""
    var apiURL: String = ""
    var cachesDir: String = ""

    var syncedDirs: [String] = []
    var selectedFiles: [URL] = []
    
    func setUp() throws {
        if debug {
            self.name = "Vectorworks Cloud Services devel"
        } else {
            guard let pathComponents = Utils.getDCCProcessPathComponents() else {
                throw AppError.appNotRunning
            }
            self.name = pathComponents.last!
        }
        
        self.cachesDir = "/Users/\(NSUserName())/Library/Caches/\(self.name)"
        
        // Api
        let portFilePath = "\(self.cachesDir)/port.txt"
        guard let port = Utils.readFile(path: portFilePath) else {
            throw AppError.fileReadFailed(fn: portFilePath)
        }
        
        self.apiURL = "http://127.0.0.1:\(String(port))/context_action"
        
        // Synced folders
        let activeSessionFilePath = "\(self.cachesDir)/active_session.json"
        guard let jsonString = Utils.readFile(path: activeSessionFilePath) else {
            throw AppError.fileReadFailed(fn: activeSessionFilePath)
        }
        
        guard let data: Data = jsonString.data(using: .utf8) else {
            throw AppError.fileContentsNotParsed(fn: activeSessionFilePath)
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] else {
            throw AppError.fileContentsNotParsed(fn: activeSessionFilePath)
        }
        
        // Root dir - required
        guard let rootFolder = json["rootFolder"] as? String, let _ = Utils.fileExists(path: rootFolder, isDirectory: nil) as Bool? else {
            throw AppError.rootFolderNotFound
        }
        self.syncedDirs.append(rootFolder)
        
        // Dropbox dir - optional
        if let dropboxFolder = json["dropboxFolder"] as? String, let _ = Utils.fileExists(path: dropboxFolder, isDirectory: nil) as Bool? {
            self.syncedDirs.append(dropboxFolder)
        }
    }
    
    func getSelectionType () -> SelectionType {
        if self.selectedFiles.allSatisfy({ Utils.getExtension(url: $0) == SelectionType.VectorworksFile }) {
            return SelectionType.VectorworksFile
        }
        if self.selectedFiles.allSatisfy({ Utils.isPhotogramType(url: $0) }) {
            return SelectionType.PhotogrametryFile
        }
        
        return SelectionType.OtherFile
    }

    func executeAction (action: String) {
        let data: [String: Any] = ["action": action, "local_paths": self.selectedFiles.map{ $0.absoluteString }]
        Utils.post(url: self.apiURL, data: data)
    }
}
