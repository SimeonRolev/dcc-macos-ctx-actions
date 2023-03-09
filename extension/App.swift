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
    case couldNotParseProcessPath
    case rootFolderNotFound
    case portNotFound
    case UnknownError
}

enum SelectionType: String {
    case VectorworksFile
    case PhotogrametryFile
    case OtherFile
}

class App {
    var port = ""
    var selectedFiles: [URL] = []
    
    var apiURL: String {
        get { return "http://127.0.0.1:\(self.port)/context_action" }
    }
    
    static func getCachesDir(pathComponents: [String], debug: Bool = false) throws -> String {
        var name = ""
        if debug {
            // Directly give the name of the running process, because we dont know where it's running from
            name = "Vectorworks Cloud Services devel"
        } else {
            if pathComponents.isEmpty { throw AppError.couldNotParseProcessPath }
            name = pathComponents.last!
        }
        
        return "/Users/\(NSUserName())/Library/Caches/\(name)"
    }
    
    func setPort (port: String) {
        self.port = port
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
