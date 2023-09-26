//
//  FolderCLCellViewModel.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 02/08/2023.
//

import Foundation

struct FolderCLCellViewModel {

	private var zipFolder: FolderZipModel?
	private var folder: FolderModel?
	private var files: [FileModel]

	private var isCreateFolder: Bool {
		return folder == nil && zipFolder == nil
	}

	private var isZipFolder: Bool {
		return folder == nil && zipFolder != nil
	}

	var shouldHideOption: Bool {
		return isCreateFolder
	}

	var shouldEnableOption: Bool {
		return !isCreateFolder && !isZipFolder
	}

	var posterName: String {
		return isCreateFolder ? AssetConstant.ic_create_folder : AssetConstant.ic_folder_large
	}

	var optionImgName: String {
		return isZipFolder ? AssetConstant.ic_pin : AssetConstant.ic_option
	}

	var folderName: String {
		if isCreateFolder {
			return "Create Folder"

		} else if isZipFolder {
			return "Zip Folder"

		} else {
			return folder!.name
		}
	}

	var folderSize: String? {
		if isCreateFolder || isZipFolder {
			return nil
		}

		var urls: [URL] = []
		files.forEach {
			if let url = $0.absolutePath {
				urls.append(URL(fileURLWithPath: url.path))
			}
		}
		return urls.isEmpty ? "0 KB" : URL.getFolderSize(urls: urls)
	}

	init(folder: FolderModel?, zipFolder: FolderZipModel?) {
		self.folder = folder
		self.zipFolder = zipFolder
		self.files = folder?.files.toArray(ofType: FileModel.self) ?? []
	}
}
