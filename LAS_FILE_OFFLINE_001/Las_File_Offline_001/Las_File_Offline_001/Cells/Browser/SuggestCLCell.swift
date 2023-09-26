//
//  SuggestCLCell.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 02/08/2023.
//

import UIKit

enum SuggestBrowser: Int, CaseIterable {
    case google
    case youtobe
    case facebook
    
    var image: UIImage? {
        switch self {
        case .google:
            return UIImage(named: AssetConstant.ic_google)
        case .youtobe:
            return UIImage(named: AssetConstant.ic_youtobe)
        case .facebook:
            return UIImage(named: AssetConstant.ic_facebook)
        }
    }
    
    var title: String {
        switch self {
        case .google:
            return "Google"
        case .youtobe:
            return "Youtobe"
        case .facebook:
            return "Facebook"
        }
    }
    
    
    
    var linkUrl: URL? {
        switch self {
        case .google:
            return URL(string: "https://www.google.com.vn/")
        case .youtobe:
            return URL(string: "https://www.youtube.com/")
        case .facebook:
            return URL(string: "https://www.facebook.com/")
        }
    }
    
    var urlRequest: URLRequest? {
        guard let url = self.linkUrl else {return nil}
        
        return URLRequest(url: url)
    }
}


class SuggestCLCell: UICollectionViewCell {
    
    //MARK: - Properties
    var cellType: SuggestBrowser? {
        didSet {
            updateUI()
        }
    }
    
    static let heightCell: CGFloat = 70
    static let miniSpacing: CGFloat = 10
    
    private lazy var suggestImv: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var suggestLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .fontGilroyMedium(14)
        label.textAlignment = .center
        return label
    }()
    //MARK: - View Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Helpers
    private func configureUI() {
        addSubview(suggestImv)
        addSubview(suggestLbl)
        
        NSLayoutConstraint.activate([
            suggestImv.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            suggestImv.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            suggestLbl.topAnchor.constraint(equalTo: suggestImv.bottomAnchor, constant: 7),
            suggestLbl.leftAnchor.constraint(equalTo: leftAnchor),
            suggestLbl.rightAnchor.constraint(equalTo: rightAnchor),
        ])
        suggestImv.setDimensions(width: 40, height: 40)
    }
    
    private func updateUI() {
        suggestImv.image = cellType?.image
        suggestLbl.text = cellType?.title
    }
    
    //MARK: - Selectors
    
}
//MARK: - delegate
