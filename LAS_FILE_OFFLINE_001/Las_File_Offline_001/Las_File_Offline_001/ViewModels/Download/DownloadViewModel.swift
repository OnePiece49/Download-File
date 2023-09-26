//
//  DownloadViewModel.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 31/07/2023.
//

import UIKit
import RealmSwift

class DownloadViewModel {
    
    private let realm = RealmService.shared.realmObj()
    private var nameFiles: [String] = []
    private var files: [FileModel] = []
    var filterOption: OptionDownload = .all
    var downloadFolder: FolderModel?
    
    var bindingViewModel: (() -> Void)?
    var bindingDowmload: (() -> Void)?
    var bindingDeleteFile: ((IndexPath) -> Void)?
    var bindingRenameFile: ((IndexPath) -> Void)?
    
    var numberCells: Int {
        return files.count
    }
    
    func fileAtIndexPath(at indexPath: IndexPath) -> FileModel {
        return files[indexPath.row]
    }
    
    var download: FolderModel? {
        return downloadFolder
    }
    
    func deleteFile(at indexPath: IndexPath) {
        guard let file = realm?.object(ofType: FileModel.self, forPrimaryKey: files[indexPath.row].id) else {return}
        guard let url = files[indexPath.row].absolutePath else {return}
        
        print("DEBUG: \(url.absoluteURL.path)")
        
        try? FileManager.default.removeItem(at: url)
        files.remove(at: indexPath.row)
        
        do {
            try realm?.write({
                realm?.delete(file)
            })
            self.bindingDeleteFile?(indexPath)
        } catch {
            print("DEBUG: \(error.localizedDescription)")
            return
        }

    }
    
    func loadData() {
        self.files = []
        guard let downloadFolder = RealmService.shared.downloadFolder() else {return}
        self.downloadFolder = downloadFolder
        
        switch filterOption {
        case .all:
            downloadFolder.files.forEach { file in
                self.files.append(file)
            }
            
        case .photos:
            downloadFolder.files.filter { file in
                return .photo == FileModel.FileType(rawValue: "\(file.fileType)")
            }.forEach { file in
                self.files.append(file)
            }
            
        case .videos:
            downloadFolder.files.filter { file in
                return .video == FileModel.FileType(rawValue: "\(file.fileType)")
            }.forEach { file in
                self.files.append(file)
            }
            
        case .audios:
            downloadFolder.files.filter { file in
                return .audio == FileModel.FileType(rawValue: "\(file.fileType)")
            }.forEach { file in
                self.files.append(file)
            }
            
        case .docx:
            downloadFolder.files.filter { file in
                return .docx == FileModel.FileType(rawValue: "\(file.fileType)")
            }.forEach { file in
                self.files.append(file)
            }
        }

        self.files = self.files.sorted { return $0.creationDate > $1.creationDate }
        bindingViewModel?()
		print(files)
    }
    
    func saveDataToRealm(output: URL, name: String?) {
        
        guard let file = RealmService.shared.convertToFileModel(with: output, fileName: name) else {return}
        guard let downloadFolder = RealmService.shared.downloadFolder() else {return}
        
        try? realm?.write({
            downloadFolder.files.append(file)
        })
        
        if FileModel.FileType(rawValue: file.fileType)?.description == self.filterOption.title {
            files.insert(file, at: 0)
            bindingDowmload?()
        } else {
            self.filterOption = .all
            loadData()
        }

    }
    
    func renameFile(name: String?, at indexPath: IndexPath) {
        guard let name = name, let pathExtension = files[indexPath.row].absolutePath?.pathExtension else {return}
        
        try? realm?.write({
            self.files[indexPath.row].name = name.appending(".\(pathExtension)")
        })
       
        self.bindingRenameFile?(indexPath)
    }
    
    
}
