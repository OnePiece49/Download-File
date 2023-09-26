//
//  FolderModel.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 30/07/2023.
//


import UIKit
import RealmSwift

class FolderModel: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var folderSize: Double = 0
	@objc dynamic var creationDate: TimeInterval = 0

    dynamic var files: List<FileModel> = List()

    override class func primaryKey() -> String? {
        return "id"
    }

    
}
