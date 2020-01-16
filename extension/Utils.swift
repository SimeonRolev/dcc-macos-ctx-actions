//
//  Utils.swift
//  dcc-ctx-actions
//
//  Created by Simeon Rolev on 12/13/19.
//  Copyright © 2019 Simeon Rolev. All rights reserved.
//

import Foundation
import AppKit

class Utils {    
    static func fileExists(path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: path, isDirectory: isDirectory)
    }
    
    static func readFile(path: String) -> String? {
        if Utils.fileExists(path: path, isDirectory: nil) {
            let contents = try? NSString(contentsOfFile: path, encoding: String.Encoding.ascii.rawValue)
            return contents as String?
        }
        return nil
    }
    
    static func post(url: String, data: [String: Any]) {
        let jsonData = try? JSONSerialization.data(withJSONObject: data)

        // create post request
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // insert json data to the request
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
        }

        task.resume()
    }
    
    static func isFolder(url: URL) -> Bool {
        return (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
    }
    
    static func getExtension (url: URL) -> SelectionType {
        switch url.pathExtension.lowercased() {
            case "vwx":
                return SelectionType.VectorworksFile
            case "tiff", "tif", "svg", "png", "jpg", "jpeg", "ico", "gif", "bmp":
                return SelectionType.PhotogrametryFile
            default:
                return SelectionType.OtherFile
        }
    }

    static func isPhotogramType (url: URL) -> Bool {
        return (
            Utils.isFolder(url: url) ||
            Utils.getExtension(url: url) == SelectionType.PhotogrametryFile
        ) ? true : false
    }
}
