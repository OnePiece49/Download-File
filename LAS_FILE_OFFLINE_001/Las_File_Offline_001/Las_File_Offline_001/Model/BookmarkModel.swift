//
//  BookmarkModel.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 07/08/2023.
//

import UIKit
import RealmSwift

class BookmarkModel: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    dynamic var urls: List<UrlModel> = List()
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
