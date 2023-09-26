//
//  ListImportCLCellViewModel.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 02/08/2023.
//

import UIKit

struct ImportCLCellViewModel {

	var isPhoto: Bool {
		return fileType == .photo
	}

	var absoluteURL: URL? {
		return file.absolutePath
	}

	var fileName: String {
		return file.name
	}

	var fileSize: String {
		return file.fileSize
	}

	var fileType: FileModel.FileType? {
		return FileModel.FileType(rawValue: file.fileType)
	}

	func getDefaultImage() -> String {
		switch fileType {
			case .docx: return AssetConstant.ic_docx_large
			case .audio: return AssetConstant.ic_audio_large
			case .video: return AssetConstant.ic_video_large
			case .photo: return ""
			default: return AssetConstant.ic_docx_large
		}
	}

	// MARK: - Private
	private var file: FileModel

	init(file: FileModel) {
		self.file = file
	}

}
