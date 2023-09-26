//
//  FolderZipModel.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 07/08/2023.
//

import Foundation
import RealmSwift

class FolderZipModel: Object {

	@objc dynamic var id: String = UUID().uuidString
	@objc dynamic var name: String = ""

	dynamic var zipFiles: List<FileZipModel> = List()

	override class func primaryKey() -> String? {
		return "id"
	}

}
