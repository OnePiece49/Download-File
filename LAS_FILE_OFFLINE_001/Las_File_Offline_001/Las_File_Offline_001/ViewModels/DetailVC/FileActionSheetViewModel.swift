//
//  FileActionSheetViewModel.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 04/08/2023.
//

import Foundation
import RealmSwift

class FileActionSheetViewModel {

	private let realm: Realm?
	private let importFolder: FolderModel?
	private let downloadFolder: FolderModel?
	private let downloadFolderID: String
	private let importFolderID: String
	private let zipFolderID: String

	var type: FileActionSheetController.ActionType
	var files: [FileModel]
	var currentFolder: FolderModel?
	var folders: [FolderModel] = []
	var selectedFolders: [FolderModel] = []
	var onCreateFolder: (() -> Void)?


	init(type: FileActionSheetController.ActionType, files: [FileModel], currentFolder: FolderModel?) {
		self.type = type
		self.files = files
		self.currentFolder = currentFolder
		self.realm = RealmService.shared.realmObj()
		self.downloadFolder = RealmService.shared.downloadFolder()
		self.importFolder = RealmService.shared.importFolder()
		self.downloadFolderID = RealmService.shared.getIdDownload()
		self.importFolderID = RealmService.shared.getIdImport()
		self.zipFolderID = RealmService.shared.getIdZip()
		self.loadData()
	}

	// MARK: - Helper
	var title: String {
		return "\(type.title) to"
	}

	var btnTitle: String {
		return type.title
	}

	var imgName: String {
		return type.imgName
	}

	var numberOfItems: Int {
		return folders.count
	}

	// MARK: - File & Folder
	func createFolder(name: String) -> Bool {
		guard let realm = realm else { return false }

		let folderModel = FolderModel()
		folderModel.name = name
		folderModel.creationDate = Date().timeIntervalSince1970

		do {
			try realm.write { realm.add(folderModel) }
			self.folders.insert(folderModel, at: 0)
			onCreateFolder?()
			return true

		} catch {
			print("DEBUG: \(#function) - error: \(error)")
			return false
		}
	}

	func didSelectFolder(at index: Int) -> Bool {
		let folder = folders[index]
		switch type {
			case .copy:
				return copyFileToFolder(folder)
			case .move:
				return moveFileToFolder(folder)
		}
	}

	private func copyFileToFolder(_ toFolder: FolderModel) -> Bool {
		guard let realm = realm else { return false }
		let filesID: [String] = files.map { $0.id }

		let duplicateFiles = toFolder.files.where {
			$0.id.in(filesID)
		}.toArray(ofType: FileModel.self)

		let uniqueFiles = files.filter { !duplicateFiles.contains($0) }

		do {
			try realm.write { toFolder.files.append(objectsIn: uniqueFiles) }
			return true

		} catch {
			print("DEBUG: \(#function) - error: \(error)")
			return false
		}
	}

	private func moveFileToFolder(_ toFolder: FolderModel) -> Bool {
		guard let realm = realm, let currentFolder = currentFolder else { return false }
		let filesID: [String] = files.map { $0.id }

		let duplicateFiles = toFolder.files.where {
			$0.id.in(filesID)
		}.toArray(ofType: FileModel.self)

		let uniqueFiles = files.filter { !duplicateFiles.contains($0) }

		do {
			try realm.write {
				toFolder.files.append(objectsIn: uniqueFiles)

				files.forEach { file in
					guard let removeIndex = currentFolder.files.firstIndex(where: {
						$0.id == file.id
					}) else { return }

					currentFolder.files.remove(at: removeIndex)
				}
			}
			return true

		} catch {
			print("DEBUG: \(#function) - error: \(error)")
			return false
		}
	}

	// MARK: - Private
	private func loadData() {
		guard let realm = realm else { return }

		folders = realm.objects(FolderModel.self)
			.where {
				$0.id.notEquals(downloadFolderID, options: .caseInsensitive) &&
				$0.id.notEquals(importFolderID, options: .caseInsensitive) &&
				$0.id.notEquals(currentFolder?.id ?? "", options: .caseInsensitive)
			}
			.sorted(by: \.creationDate, ascending: false)
			.toArray(ofType: FolderModel.self)
	}
}
