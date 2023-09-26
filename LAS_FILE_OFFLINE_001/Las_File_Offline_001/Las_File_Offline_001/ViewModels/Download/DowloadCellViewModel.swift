//
//  DowloadCellViewModel.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 31/07/2023.
//

import UIKit
import AVFoundation
import SDWebImage

class DowloadCellViewModel {
    
    let file: FileModel
    
    var nameFile: String {
        return file.name
    }
    
    var sizeFile: String {
        return file.fileSize
    }
    
    var isPhoto: Bool {
        return .photo == FileModel.FileType(rawValue: "\(file.fileType)")
    }
    
    var fileType: FileModel.FileType? {
        return FileModel.FileType(rawValue: "\(file.fileType)")
    }
    
    var fileURL: URL? {
        return file.absolutePath 
    }
    
    var actualImage: UIImage? {
        return UIImage(contentsOfFile: file.absolutePath?.path ?? "")
    }
    
    var contentMode: UIView.ContentMode {
        switch FileModel.FileType(rawValue: "\(file.fileType)") {
        case .docx, .audio, .video, .zip:
            return .center
        case .photo:
            return (imageFile() != nil) ? .scaleAspectFill : .center
        default:
            return .center
        }
    }
    
    func imageFile(iv: UIImageView? = nil) -> UIImage? {
        switch FileModel.FileType(rawValue: "\(file.fileType)") {
        case .docx:
            return UIImage(named: AssetConstant.ic_docx_large)
        case .audio:
            return UIImage(named: AssetConstant.ic_audio_large)
        case .video:
            return UIImage(named: AssetConstant.ic_video_large)
        case .photo:
            let transformer = SDImageResizingTransformer(size: CGSize(width: 200, height: 200), scaleMode: .fill)
            iv?.sd_setImage(with: file.absolutePath, placeholderImage: nil, context: [.imageTransformer: transformer])
            return iv?.image

        default:
            return UIImage(named: AssetConstant.ic_docx_large)
        }
    }
    
    init(file: FileModel) {
        self.file = file
    }
    
    
    
}
