//
//  BookmarkViewModel.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 07/08/2023.
//

import UIKit

class BookmarkViewModel {

    private let realm = RealmService.shared.realmObj()
    private var urls: [UrlModel] = []
    private let currentUrl: URL?
    
    var bindingViewModel: (() -> Void)?
    var bindingBookmark: ((Bool) -> Void)?
    var bindingClear: (() -> Void)?
    var bindingDeleteBookmark: ((_ isCurrentUrl: Bool) -> Void)?
    
    func bookmark() {
        guard let bookmark = RealmService.shared.bookmarkFolder() else {return}
        guard let currentUrl = currentUrl else {return}
        let urlModel = UrlModel()
        urlModel.urlString = currentUrl.absoluteString
        
        if isBookmarked {
            bindingBookmark?(false)
            return
        }
        
        try? realm?.write({
            bookmark.urls.append(urlModel)
        })
        urls.append(urlModel)
        self.bindingBookmark?(true)
    }

    var isBookmarked: Bool {
        guard let currentUrl = currentUrl else {return false}
        
        if urls.firstIndex(where: { url in
            return url.urlString == currentUrl.absoluteString
        }) != nil {
            return true
        }
        
        return false
    }
    
    
    var canBookmark: Bool {
        return currentUrl != nil && currentUrl != URL(string: "about:blank")
    }
    
    var numberCell: Int {
        return urls.count
    }
    
    func urlString(at indexPath: IndexPath) -> String {
        return urls[indexPath.row].urlString
    }
    
    func clearBookmark() {
        guard let bookmark = RealmService.shared.bookmarkFolder(), let urlsModel = realm?.objects(UrlModel.self) else {return}
        try? realm?.write({
            bookmark.urls.removeAll()
            realm?.delete(urlsModel)
        })
        
        urls = []
        bindingClear?()
    }
    
    func deleteBookmark(at indexPath: IndexPath) {
        guard let bookmark = RealmService.shared.bookmarkFolder(),
              let urlModel = realm?.object(ofType: UrlModel.self, forPrimaryKey: urls[indexPath.row].id) else {return}
        
        let isCurrent = (urls[indexPath.row].urlString == currentUrl?.absoluteString)
        try? realm?.write({
            bookmark.urls.remove(at: indexPath.row)
            realm?.delete(urlModel)
        })

        
        urls.remove(at: indexPath.row)
        bindingDeleteBookmark?(isCurrent)   
    }
    
    func loadData() {
        guard let bookmark = RealmService.shared.bookmarkFolder() else {
            return
            
        }
        self.urls = bookmark.urls.toArray(ofType: UrlModel.self)
        self.bindingViewModel?()
    }
    
    init(currentUrl: URL?) {
        self.currentUrl = currentUrl
    }
}
