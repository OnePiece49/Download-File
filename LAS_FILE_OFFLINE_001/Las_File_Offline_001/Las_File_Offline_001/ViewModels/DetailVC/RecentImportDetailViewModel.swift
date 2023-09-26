//
//  RecentImportDetailViewModel.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 04/08/2023.
//

import Foundation

class RecentImportDetailViewModel {

	var files: [FileModel]
	var selectedFiles: [FileModel] = []
	var mode: FolderDetailController.Mode = .normal
	var onSelectFile: ((Int) -> Void)?
	var onSelectAllFiles: (() -> Void)?
	var onModeChange: (() -> Void)?
	var onNoDataViewChange: (() -> Void)?

	init(files: [FileModel]) {
		self.files = files
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

	var hasNoFiles: Bool {
		return numberOfItems == 0
	}

	private var totalSelectedFileSize: String {
		var urls: [URL] = []
		selectedFiles.forEach {
			if let url = $0.absolutePath { urls.append(url) }
		}
		return urls.isEmpty ? "0 KB" : URL.getFolderSize(urls: urls)
	}

	var highlightText: String {
		return "Selected \(numberOfSelectedFiles) of \(numberOfItems) (\(totalSelectedFileSize))"
	}

	func getCellVM(at index: Int) -> FolderDetailTBCellViewModel {
		let file = files[index]
		let select = selectedFiles.contains(file)
		return FolderDetailTBCellViewModel(file: file, mode: mode, isSelect: select)
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
				toggleMode()
			case .move:
				break
		}
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
					guard let removeIndex = files.firstIndex(where: {
						$0.id == file.id
					}) else { return }

					files.remove(at: removeIndex)

					if let url = file.absolutePath {
						try? FileManager.default.removeItem(at: url)
					}
					realm.delete(file)
				}
			}
			toggleMode()
			onNoDataViewChange?()
			return true

		} catch {
			print("DEBUG: \(#function) - error: \(error)")
			return false
		}
	}

}
