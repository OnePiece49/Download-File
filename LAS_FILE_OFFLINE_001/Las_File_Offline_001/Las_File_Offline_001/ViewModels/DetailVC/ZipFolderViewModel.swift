//
//  ZipFolderViewModel.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 07/08/2023.
//

import Foundation
import RealmSwift

class ZipFolderViewModel {

	private let realm = RealmService.shared.realmObj()
	private let downloadFolderID: String = RealmService.shared.getIdDownload()
	private let importFolderID: String = RealmService.shared.getIdImport()
	private var userCreatedFolders: [FolderModel] = []

	var zipFolder: FolderZipModel
	var zipFiles: [FileZipModel]
	var onDeleteZipFile: (() -> Void)?
	var onNoDataViewChange: (() -> Void)?


	init(zipFolder: FolderZipModel) {
		self.zipFolder = zipFolder
		self.zipFiles = zipFolder.zipFiles
			.sorted(by: \.creationDate, ascending: false)
			.toArray(ofType: FileZipModel.self)
		self.loadData()
	}


	// MARK: - Public
	var numberOfItems: Int {
		return zipFiles.count
	}

	var shouldHideNoData: Bool {
		return numberOfItems != 0
	}

	func deleteZipFile(at index: Int) -> Bool {
		guard let realm = realm else { return false }
		let zipFile = zipFiles[index]

		do {
			guard let url = zipFile.absolutePath else { return false }

			try realm.write {
				zipFolder.zipFiles.remove(at: index)
				realm.delete(zipFile)
			}

			zipFiles.remove(at: index)
			AppFileManager.shared.removeFiles(at: [url])
			onDeleteZipFile?()
			return true

		} catch {
			print("DEBUG: \(#function) - error: \(error)")
			return false
		}
	}

	func unzipFile(at index: Int) -> Bool {
		guard let realm = realm else { return false }
		let zipFile = zipFiles[index]

		guard let folderName = zipFile.absolutePath?.deletingPathExtension().lastPathComponent else { return false }

		guard let _ = userCreatedFolders.first(where: {
			$0.name != folderName
		}) else { return false }

		let folderModel = FolderModel()
		folderModel.name = "Unzip_" + folderModel.id
		folderModel.creationDate = Date().timeIntervalSince1970
		folderModel.files.append(objectsIn: zipFile.files)

		do {
			try realm.write { realm.add(folderModel) }
			return true

		} catch {
			print("DEBUG: \(#function) - error: \(error)")
			return false
		}
	}

	private func loadData() {
		guard let realm = realm else { return }

		userCreatedFolders = realm.objects(FolderModel.self)
			.where {
				$0.id.notEquals(downloadFolderID, options: .caseInsensitive) &&
				$0.id.notEquals(importFolderID, options: .caseInsensitive)
			}
			.sorted(by: \.creationDate, ascending: false)
			.toArray(ofType: FolderModel.self)
	}
}
