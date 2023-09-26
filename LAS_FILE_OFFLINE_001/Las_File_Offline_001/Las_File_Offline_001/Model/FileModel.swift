//
//  FileModel.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 30/07/2023.
//

import Foundation
import RealmSwift

class FileModel: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var creationDate: TimeInterval = 0
	@objc dynamic var fileType: String = ""
    @objc dynamic var fileSize: String = ""
    @objc dynamic var relativePath: String?
    
    override class func primaryKey() -> String? {
        return "id"
    }

    
    var absolutePath: URL? {
        if let path = relativePath {
            return URL.document().appendingPathComponent(path)
        }
        return nil
    }
    
}

extension FileModel {
	enum FileType: String {
        case photo
		case video
		case audio
		case docx
		case zip
        
        var description: String {
            switch self {
            case .zip: return AppConstant.zip
            case .docx: return AppConstant.docx
            case .audio: return AppConstant.audio
            case .video: return AppConstant.video
            case .photo: return AppConstant.photo
            }
        }
	}
}

extension FileType {
	func getLocalType() -> FileModel.FileType? {
		switch self {
			case .bmp, .cr2, .flif, .gif, .ico, .jpg, .jxr, .png, .tif, .webp, .heic:
				return .photo

			case .avi, .flv, .m4v, .mkv, .mov, .mp4, .mpg, .mxf, .webm:
				return .video

			case .aac, .amr, .flac, .m4a, .mid, .mp3, .opus, .wav:
				return .audio

			case .zip:
				return .zip

			default:
				return .docx
		}
	}
}
