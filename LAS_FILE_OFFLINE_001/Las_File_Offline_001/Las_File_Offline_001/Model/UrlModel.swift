//
//  UrlModel.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 07/08/2023.
//

import Foundation
import RealmSwift

class UrlModel: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var urlString: String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
