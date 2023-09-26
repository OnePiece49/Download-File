//
//  FolderDetailTBCellViewModel.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 04/08/2023.
//

import Foundation

struct FolderDetailTBCellViewModel {

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

	var shouldHideChecklist: Bool {
		return mode == .normal
	}

	var checklistImgName: String {
		return isSelect ? AssetConstant.ic_checklist_select : AssetConstant.ic_checklist_unselect
	}

	// MARK: - Private
	private var file: FileModel
	private var mode: FolderDetailController.Mode
	private var isSelect: Bool

	init(file: FileModel, mode: FolderDetailController.Mode, isSelect: Bool) {
		self.file = file
		self.mode = mode
		self.isSelect = isSelect
	}

}
