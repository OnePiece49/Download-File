//
//  RealmService.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 28/07/2023.
//

import UIKit
import RealmSwift


class RealmService: NSObject {

	static let shared = RealmService()

	// MARK: - Private
    private let idDownloadFolder = "43AD7742-8B66-4F20-817F-805CFA60954C"
    private let idZipFolder = "8145561B-D78A-4C67-934C-0A40730AB000"
	private let idImportFolder = "2EF357E1-8AE6-4EC5-99DA-5B06DCD4D1E7"
    private let idBookmark = "1233561B-8B66-934C-99DA-0A40730A1234"
    
    private let config = Realm.Configuration(schemaVersion: 1)

    override init() { }

	// MARK: - Public
    func configuration() {
        do {
            let realm = try Realm(configuration: config)
            
            if realm.objects(FolderModel.self).first(where: { $0.id == idDownloadFolder }) == nil {
                let obj = FolderModel()
                obj.id = idDownloadFolder
                obj.name = "Downloads"

                try? realm.write({
                    realm.add(obj)
                })
            }
            
            if realm.objects(FolderZipModel.self).first(where: { $0.id == idZipFolder }) == nil {
                let obj = FolderZipModel()
                obj.id = idZipFolder
                obj.name = "Zips"

                try? realm.write({
                    realm.add(obj)
                })
            }
            
            if realm.objects(FolderModel.self).first(where: { $0.id == idImportFolder }) == nil {
                let obj = FolderModel()
                obj.id = idImportFolder
                obj.name = "Imports"

                try? realm.write({
                    realm.add(obj)
                })
            }
            
            if realm.objects(BookmarkModel.self).first(where: { $0.id == idBookmark }) == nil {
                let obj = BookmarkModel()
                obj.id = idBookmark
                obj.name = "Bookmarks"

                try? realm.write({
                    realm.add(obj)
                })
            }

        } catch (let error) {
            print("Realm error: \(error.localizedDescription)")
        }
    }

    func realmObj() -> Realm? {
		do {
			let realm = try Realm(configuration: config)
			return realm
		} catch {
			print("DEBUG: \(#function) - error: \(error)")
			return nil
		}
    }

	func convertToFileModel(with url: URL, fileName: String?) -> FileModel? {
		guard let realm = realmObj() else { return nil }

        print("DEBUG: \(url.path) aaaa")
		let path = url.path
		let relativePath = path.replacingOccurrences(of: "\(URL.document().path)/", with: "")

		if let _ = realm.objects(FileModel.self).first(where: {
			$0.relativePath == relativePath
		}) {
			return nil
		}

		let fileModel = FileModel()
		fileModel.name = fileName ?? url.lastPathComponent
		fileModel.creationDate = Date().timeIntervalSince1970
		fileModel.fileSize = url.fileSizeString
		fileModel.relativePath = relativePath
		
		if let data = try? Data(contentsOf: url) {
			let mimeType = Swime.mimeType(data: data)
			let localType = mimeType?.type.getLocalType()
			fileModel.fileType = localType?.rawValue ?? FileModel.FileType.docx.rawValue
		}

		return fileModel
	}

	func saveObject(_ object: Object?) -> Bool {
		guard let realm = realmObj(), let object = object else { return false }
		do {
			try realm.write { realm.add(object) }
			return true
		} catch {
			print("DEBUG: \(#function) - error: \(error)")
			return false
		}
	}
    
    func downloadFolder() -> FolderModel? {
        guard let realm = self.realmObj() else { return nil }
        return realm.objects(FolderModel.self).first(where: { $0.id == idDownloadFolder })
    }

	func zipFolder() -> FolderZipModel? {
		guard let realm = self.realmObj() else { return nil }
		return realm.objects(FolderZipModel.self).first(where: { $0.id == idZipFolder })
	}

	func importFolder() -> FolderModel? {
		guard let realm = self.realmObj() else { return nil }
		return realm.objects(FolderModel.self).first(where: { $0.id == idImportFolder })
	}

    func bookmarkFolder() -> BookmarkModel? {
        guard let realm = self.realmObj() else { return nil }
        return realm.objects(BookmarkModel.self).first(where: { $0.id == idBookmark })
    }

    
    func getIdDownload() -> String {
        return idDownloadFolder
    }

    func getIdZip() -> String {
        return idZipFolder
    }

    func getIdImport() -> String {
        return idImportFolder
    }
    
    func dontAllowDeleteFolder(_ id: String) -> Bool {
        return id == idDownloadFolder || id == idImportFolder || id == idZipFolder
    }
}


