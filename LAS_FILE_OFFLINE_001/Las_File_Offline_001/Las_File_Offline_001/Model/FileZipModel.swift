//
//  FileZipModel.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 07/08/2023.
//

import Foundation
import RealmSwift

class FileZipModel: Object {

	@objc dynamic var id: String = UUID().uuidString
	@objc dynamic var name: String = ""
	@objc dynamic var creationDate: TimeInterval = 0
	@objc dynamic var fileSize: String = ""
	@objc dynamic var relativePath: String?

	dynamic var files: List<FileModel> = List()

	override class func primaryKey() -> String? {
		return "id"
	}

	var absolutePath: URL? {
		if let path = relativePath {
			return URL.document().appendingPathComponent(path)
		}
		return nil
	}
	
}
