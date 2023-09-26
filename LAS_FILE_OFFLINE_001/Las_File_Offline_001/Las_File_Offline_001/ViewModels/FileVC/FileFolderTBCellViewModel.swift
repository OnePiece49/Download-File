//
//  FileFolderTBCellViewModel.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 07/08/2023.
//

import Foundation

struct FileFolderTBCellViewModel {

	var folders: [FolderModel]
	var zipFolder: FolderZipModel?
	var displayMode: FileController.DisplayMode

	func numberOfItems() -> Int {
		return folders.count + 2
	}

	func getFolderModel(at indexPath: IndexPath) -> FolderModel? {
		return indexPath.item == 0 || indexPath.item == 1 ? nil : folders[indexPath.item - 2]
	}

	func getFolderZipModel() -> FolderZipModel? {
		return zipFolder
	}

	func getCellViewModel(index: Int) -> FolderCLCellViewModel {
		if index == 0 {
			return FolderCLCellViewModel(folder: nil, zipFolder: nil)
		} else if index == 1 {
			return FolderCLCellViewModel(folder: nil, zipFolder: zipFolder)
		} else {
			return FolderCLCellViewModel(folder: folders[index - 2], zipFolder: zipFolder)
		}
	}

	init(folders: [FolderModel], zipFolder: FolderZipModel?, displayMode: FileController.DisplayMode) {
		self.folders = folders
		self.zipFolder = zipFolder
		self.displayMode = displayMode
	}

}
