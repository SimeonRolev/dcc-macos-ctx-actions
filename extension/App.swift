//
//  App.swift
//  dcc-ctx-actions
//
//  Created by Simeon Rolev on 12/13/19.
//  Copyright © 2019 Simeon Rolev. All rights reserved.
//

import Foundation
import FinderSync

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
    var debug: Bool = false
    
    var apiURL: String = ""
    var cachesDir: String = ""
    var syncedDirs: [String] = []
    var selectedFiles: [URL] = []
    
    func setUp(pathComponents: [String]) throws {
        var name = ""
        if debug {
            // Directly give the name of the running process, because wo dont know where it's running from
            name = "Vectorworks Cloud Services devel"
        } else {
            if pathComponents.isEmpty { throw AppError.appNotRunning }
            name = pathComponents.last!
        }
        
        self.cachesDir = "/Users/\(NSUserName())/Library/Caches/\(name)"
        
        // Api
        let portFilePath = "\(self.cachesDir)/port.txt"
        guard let port = Utils.readFile(path: portFilePath) else {
            throw AppError.fileReadFailed(fn: portFilePath)
        }
        
        self.apiURL = "http://127.0.0.1:\(String(port))/context_action"
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
        let local_paths = self.selectedFiles.map {
            Utils.isFolder(url: $0) && $0.path.last != "/"
                ? "\($0.path)/"
                : $0.path
        }
        let data: [String: Any] = [
            "action": action,
            "local_paths": local_paths
        ]
        Utils.post(url: self.apiURL, data: data)
    }
}
