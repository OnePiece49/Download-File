//
//  DownloadManager.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 29/07/2023.
//

import UIKit

class DownloadManager {
    
    static let shared: DownloadManager = DownloadManager()
    
    func downloadFile(inputURL: URL?,
                      outputURL directory: URL?,
                      completion: @escaping((_ success: Bool, _ output: URL?, _ fileExisted: Bool) -> Void)) {
        
        guard let inputURL = inputURL, let outputURL = directory else {
            completion(false, nil, false)
            return
        }
        
        let urlRequest = URLRequest(url: inputURL)
        
        URLSession.shared.downloadTask(with: urlRequest) { dataUrl, response, error in
            if let _ = error { completion(false, nil, false); return}
            guard let dataUrl = dataUrl else {completion(false, nil, false); return}
            
            guard let data = try? Data(contentsOf: dataUrl) else {completion(false, nil, false); return}
            guard let mimeType = Swime.mimeType(data: data), mimeType.type != .txt else {completion(false, nil, false); return}
            
            let output = outputURL.appendingPathExtension("\(mimeType.type)")
            let isExisted = FileManager.default.fileExists(atPath: output.path)
            
            if isExisted {
                completion(false, output, true)
                return
                
            } else {
                do {
                    try data.write(to: output)
                    completion(true, output, false)
                } catch {
                    completion(false, nil, false)
                }
            }
            
        }.resume()
        
    }
    

    
}
