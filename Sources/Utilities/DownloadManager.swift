//
//  DownloadManager.swift
//  MessageKit
//
//  Created by Phanuwat Yoksiri on 7/5/2561 BE.
//  Copyright © 2561 MessageKit. All rights reserved.
//

import UIKit
public let kLibraryPath = NSHomeDirectory() + "/Library/Caches"

class DownloadManager: NSObject {
    static let shared = DownloadManager()
    var token: String!
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        var request = URLRequest.init(url: url)
        if let token = token {
            request.setValue(token, forHTTPHeaderField: "Access-Token")
        }
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            completion(data, response, error)
        }.resume()
    }
    
    func cancel() {
        URLSession.shared.invalidateAndCancel()
    }
}
