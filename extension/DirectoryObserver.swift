//
//  DirectoryObserver.swift
//  extension
//
//  Created by Simeon Rolev on 1/10/20.
//  Copyright © 2020 Simeon Rolev. All rights reserved.
//

import Foundation
import FinderSync

class DirectoryObserver {
    private let fileDescriptor: CInt
    private let source: DispatchSourceProtocol
    private let cachesDir: String
    private var syncedDirs: [String] = []
    private var isFound: Bool = false
    
    var app = App()

    init(cachesDir: String) {
        self.cachesDir = cachesDir
        
        // Listen
        self.fileDescriptor = open(cachesDir, O_EVTONLY)
        self.source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: self.fileDescriptor, eventMask: .all, queue: DispatchQueue.main)
        self.source.setEventHandler {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.checkkDir()
            }
        }
        source.resume()
        
//        // Initial
        self.checkkDir()
    }
    
    func checkkDir() {
        try? self.getSyncedDirs()
    }
    
    func clear() {
        source.cancel()
        close(fileDescriptor)
        FIFinderSyncController.default().directoryURLs = []
    }
    
    deinit {
        self.clear()
    }
    
    func getSyncedDirs () throws {
        defer {
            if !self.isFound {
                FIFinderSyncController.default().directoryURLs = []
            }
        }
        self.isFound = false
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
        
        // Port
        guard let port = json["port"] as? Int else {
            throw AppError.portNotFound
        }
        self.app.setPort(port: String(port))
        
        // Root dir - required
        self.syncedDirs.removeAll()
        guard let rootFolder = json["rootFolder"] as? String, let _ = Utils.fileExists(path: rootFolder, isDirectory: nil) as Bool? else {
            throw AppError.rootFolderNotFound
        }
        self.syncedDirs.append(rootFolder)
        
        // Dropbox dir - optional
        if let dropboxFolder = json["dropboxFolder"] as? String, let _ = Utils.fileExists(path: dropboxFolder, isDirectory: nil) as Bool? {
            self.syncedDirs.append(dropboxFolder)
        }
        
        self.isFound = true
        FIFinderSyncController.default().directoryURLs =
            Set(self.syncedDirs.map { URL(fileURLWithPath: $0) })
    }
}
