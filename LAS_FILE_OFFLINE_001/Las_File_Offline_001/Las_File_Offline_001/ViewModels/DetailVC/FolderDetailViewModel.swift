//
//  RecentFileDetailViewModel.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 03/08/2023.
//

import Foundation
import RealmSwift

class FolderDetailViewModel {

	var folder: FolderModel
	var files: [FileModel]
	var selectedFiles: [FileModel] = []
	var mode: FolderDetailController.Mode = .normal

	var onSelectFile: ((_ index: Int) -> Void)?
	var onSelectAllFiles: (() -> Void)?
	var onModeChange: (() -> Void)?
	var onNoDataViewChange: (() -> Void)?
	var onZipFileComplete: ((_ zipFile: FileZipModel?) -> Void)?
	var onFinishModifyFolder: ((_ type: FileActionSheetController.ActionType) -> Void)?

	private let zipFolder = RealmService.shared.zipFolder()

	init(folder: FolderModel) {
		self.folder = folder
		self.files = folder.files
			.sorted(by: \.creationDate, ascending: false)
			.toArray(ofType: FileModel.self)
	}

	// MARK: - Helper
	var didSelectAll: Bool {
		return files.count == selectedFiles.count
	}

	var didDeselectAll: Bool {
		return selectedFiles.isEmpty
	}

	var numberOfItems: Int {
		return files.count
	}

	var numberOfSelectedFiles: Int {
		return selectedFiles.count
	}

	var highlightText: String {
		return "Selected \(numberOfSelectedFiles) of \(numberOfItems) (\(totalSelectedFileSize))"
	}

	var hasNoFiles: Bool {
		return numberOfItems == 0
	}

	func getCellVM(at index: Int) -> FolderDetailTBCellViewModel {
		let file = files[index]
		let select = selectedFiles.contains(file)
		return FolderDetailTBCellViewModel(file: file, mode: mode, isSelect: select)
	}

	private var totalSelectedFileSize: String {
		var urls: [URL] = []
		selectedFiles.forEach {
			if let url = $0.absolutePath { urls.append(url) }
		}
		return urls.isEmpty ? "0 KB" : URL.getFolderSize(urls: urls)
	}

	// MARK: - Files
	func selectFile(at index: Int) -> Bool {
		let selectedFile = files[index]

		if selectedFiles.contains(selectedFile) {
			guard let removeIndex = selectedFiles.firstIndex(where: {
				$0.id == selectedFile.id
			}) else { return false }

			selectedFiles.remove(at: removeIndex)

			onSelectFile?(index)
			return false

		} else {
			selectedFiles.append(selectedFile)
			onSelectFile?(index)
			return true
		}
	}

	func selectAllFiles() {
		let count = files.count
		let sltCount = selectedFiles.count

		if sltCount == count {
			selectedFiles.removeAll()

		} else {
			selectedFiles.removeAll()
			selectedFiles = files
		}

		onSelectAllFiles?()
	}

	// MARK: - Mode
	func toggleMode() {
		mode = (mode == .normal) ? .select : .normal
		selectedFiles.removeAll()
		onModeChange?()
	}

	func resetAfterModify(type: FileActionSheetController.ActionType) {
		switch type {
			case .copy:
				selectedFiles.removeAll()
				
			case .move:
				selectedFiles.removeAll()
				files = folder.files
					.sorted(by: \.creationDate, ascending: false)
					.toArray(ofType: FileModel.self)
		}
		toggleMode()
		checkDataStatus()
	}

	func checkDataStatus() {
		onNoDataViewChange?()
	}

	// MARK: - Realm

	private let realm = RealmService.shared.realmObj()

	func deleteFiles() -> Bool {
		guard let realm = realm else { return false }

		do {
			try realm.write {
				selectedFiles.forEach { file in
					guard let removeIndex = folder.files.firstIndex(where: {
						$0.id == file.id
					}) else { return }

					folder.files.remove(at: removeIndex)
				}
			}

			files = folder.files
				.sorted(by: \.creationDate, ascending: false)
				.toArray(ofType: FileModel.self)

			toggleMode()
			onNoDataViewChange?()
			return true

		} catch {
			print("DEBUG: \(#function) - error: \(error)")
			return false
		}
	}

	func zipFiles() {
		guard let realm = realm, !selectedFiles.isEmpty else {
			onZipFileComplete?(nil)
			return
		}

		let urls = selectedFiles.compactMap { $0.absolutePath }
		let dstURL = URL.zipItemFolder()!.appendingPathComponent("Archive_\(UUID().uuidString).zip")

		AppFileManager.shared.zipFiles(from: urls, dstURL: dstURL) { [weak self] success in
			guard let self = self, success == true else {
				self?.onZipFileComplete?(nil)
				return
			}

			guard let zipFolder = self.zipFolder else {
				self.onZipFileComplete?(nil)
				return
			}

			let zipFile = FileZipModel()
			zipFile.name = dstURL.lastPathComponent
			zipFile.creationDate = Date().timeIntervalSince1970
			zipFile.fileSize = URL.getFolderSize(urls: urls)
			zipFile.relativePath = dstURL.path.replacingOccurrences(of: "\(URL.document().path)/", with: "")
			zipFile.files = self.selectedFiles.toList()

			do {
				try realm.write {
					realm.add(zipFile)
					zipFolder.zipFiles.append(zipFile)
				}
				self.onZipFileComplete?(zipFile)

			} catch {
				print("DEBUG: \(#function) - error: \(error)")
				AppFileManager.shared.removeFiles(at: [dstURL])
				self.onZipFileComplete?(nil)
			}
		}
	}

}
