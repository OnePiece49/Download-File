//
//  BaseController.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 28/07/2023.
//

import UIKit


class BaseController: UIViewController {
    
    //MARK: - Properties
    
    
    
    //MARK: - UIComponent
    
    
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true
    }
    
}

// MARK: - Method
extension BaseController {
	func saveFileToDB(at url: URL, fileName: String? = nil) -> Bool {
//		let path = url.path
//		let relativePath = path.replacingOccurrences(of: URL.document().path, with: "")
//
//		if let _ = realm.objects(FileModel.self).first(where: {
//			$0.relativePath == relativePath
//		}) {
//			return false
//		}
//
//		let fileModel = FileModel()
//		fileModel.name = fileName ?? path.fileName
//		fileModel.creationDate = url.creationDate?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
//		fileModel.fileSize = url.fileSizeString
//		fileModel.relativePath = relativePath
//
//		if let data = try? Data(contentsOf: url) {
//			let mimeType = Swime.mimeType(data: data)
//			let localType = mimeType?.type.getLocalType()
//			fileModel.fileType = localType?.rawValue ?? FileModel.FileType.photo.rawValue
//		}
//
//		do {
//			try realm.write { realm.add(fileModel) }
//			return true
//		} catch {
//			return false
//		}

		guard let realm = RealmService.shared.realmObj(),
			  let fileModel = RealmService.shared.convertToFileModel(with: url, fileName: fileName)
		else { return false }

		let success = RealmService.shared.saveObject(fileModel)
		if success {
			let importFolder = RealmService.shared.importFolder()
			try? realm.write {
				importFolder?.files.append(fileModel)
			}
		}
		return success
	}
    
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }

}
