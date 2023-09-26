//
//  ZipFolderTBCellViewModel.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 07/08/2023.
//

import Foundation

struct ZipFolderTBCellViewModel {

	var zipFile: FileZipModel

	init(zipFile: FileZipModel) {
		self.zipFile = zipFile
	}

	var filename: String {
		return zipFile.name
	}

	var filesize: String {
		return zipFile.fileSize
	}

	var zipfileURL: URL? {
		return zipFile.absolutePath
	}

}
