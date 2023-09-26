//
//  FileViewModel.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 01/08/2023.
//

import Foundation
import RealmSwift

class FileViewModel {

	private let realm: Realm?
	private let importFolder: FolderModel?
	private let downloadFolder: FolderModel?
	private let downloadFolderID: String
	private let importFolderID: String
	private let zipFolderID: String

	let zipFolder: FolderZipModel?
	var userCreatedFolders: [FolderModel] = []
	var recentFiles: [FileModel] = []
	var allFiles: [FileModel] = []
	var displayMode: FileController.DisplayMode = .grid

	var onChangeDisplayMode: (() -> Void)?
	var onLoadDataSuccess: (() -> Void)?
	var onCreateFolder: (() -> Void)?
	var onDeleteFolder: (() -> Void)?
	var onRenameFolder: (() -> Void)?
	var onRecentFilesChange: (() -> Void)?

	init() {
		self.realm = RealmService.shared.realmObj()

		self.downloadFolder = RealmService.shared.downloadFolder()
		self.importFolder = RealmService.shared.importFolder()
		self.zipFolder = RealmService.shared.zipFolder()

		self.downloadFolderID = RealmService.shared.getIdDownload()
		self.importFolderID = RealmService.shared.getIdImport()
		self.zipFolderID = RealmService.shared.getIdZip()

		self.loadData()
	}

	// MARK: - Public
	func loadData() {
		loadFolders()
		loadFiles()
		onLoadDataSuccess?()
	}

	func estimateRowHeight(of type: FileController.HomeType) -> CGFloat {
		let condition = (displayMode, type)

		switch condition {
			case (.grid, .folder):
				return GridFolderCLCell.cellHeight

			case (.grid, .recentImport):
				if recentFiles.isEmpty { return 200 }

				let numberOfRows: CGFloat = ceil(CGFloat(recentFiles.count)/columns)
				return numberOfRows * GridImportCLCell.cellHeight

			case (.list, .folder):
				return CGFloat(userCreatedFolders.count + 2) * ListFolderCLCell.cellHeight

			case (.list, .recentImport):
				if recentFiles.isEmpty { return 200 }
				return CGFloat(recentFiles.count) * ListImportCLCell.cellHeight
		}
	}

	func toggleDisplayMode(_ mode: FileController.DisplayMode) {
		if self.displayMode == mode { return }
		self.displayMode = mode
		onChangeDisplayMode?()
	}

	func createFolder(name: String) -> Bool {
		guard let realm = realm else { return false }

		if !validateFolderName(name) {
			return false
		}

		let folderModel = FolderModel()
		folderModel.name = name
		folderModel.creationDate = Date().timeIntervalSince1970

		do {
			try realm.write { realm.add(folderModel) }
			self.userCreatedFolders.insert(folderModel, at: 0)
			onCreateFolder?()
			return true
		} catch {
			print("DEBUG: \(#function) - error: \(error)")
			return false
		}
	}

	func deleteFolder(at index: Int) -> Bool {
		guard let realm = realm else { return false }
		let folderModel = userCreatedFolders[index]

		do {
			userCreatedFolders.remove(at: index)
			try realm.write { realm.delete(folderModel) }
			onDeleteFolder?()
			return true
		} catch {
			print("DEBUG: \(#function) - error: \(error)")
			return false
		}
	}

	func renameFolder(at index: Int, name: String) -> Bool {
		guard let realm = realm else { return false }

		guard validateFolderName(name) else { return false }

		let folderModel = userCreatedFolders[index]

		do {
			try realm.write { folderModel.name = name }
			onRenameFolder?()
			return true

		} catch {
			print("DEBUG: \(#function) - error: \(error)")
			return false
		}
	}

	private func validateFolderName(_ name: String) -> Bool {
		if downloadFolder?.name == name || importFolder?.name == name || zipFolder?.name == name {
			return false
		}

		for folder in userCreatedFolders {
			if folder.name == name {
				return false
			}
		}

		return true
	}

	func saveFileToDB(with url: URL) -> Bool {
		guard let realm = realm, let fileModel = RealmService.shared.convertToFileModel(with: url, fileName: nil) else {
			return false
		}

		do {
			try realm.write {
				realm.add(fileModel)
				importFolder?.files.append(fileModel)
			}

			allFiles.insert(fileModel, at: 0)
			getRecentFiles()
			onRecentFilesChange?()
			return true

		} catch {
			print("DEBUG: \(#function) - error: \(error)")
			return false
		}
	}

	// MARK: - Private
	private func getRecentFiles() {
		let count = allFiles.count
		if count <= 10 {
			recentFiles = allFiles
		} else {
			recentFiles = Array(allFiles.prefix(10))
		}
	}

	private func loadFolders() {
		guard let realm = realm else { return }

		userCreatedFolders = realm.objects(FolderModel.self)
			.where {
				$0.id.notEquals(downloadFolderID, options: .caseInsensitive) &&
				$0.id.notEquals(importFolderID, options: .caseInsensitive)
			}
			.sorted(by: \.creationDate, ascending: false)
			.toArray(ofType: FolderModel.self)
	}

	private func loadFiles() {
		guard let importFolder = importFolder, let downloadFolder = downloadFolder else { return }

		var downloadFiles = downloadFolder.files.toArray(ofType: FileModel.self)
		let importFiles = importFolder.files.toArray(ofType: FileModel.self)

		importFiles.forEach { downloadFiles.append($0) }
		self.allFiles = downloadFiles.sorted(by: { $0.creationDate > $1.creationDate })

		getRecentFiles()
	}

}
