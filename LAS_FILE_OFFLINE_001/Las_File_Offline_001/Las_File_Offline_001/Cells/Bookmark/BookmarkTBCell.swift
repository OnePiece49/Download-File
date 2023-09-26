//
//  BookmarkTBCell.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 07/08/2023.
//

import UIKit

class BookmarkTBCell: UITableViewCell {
    
    //MARK: - Properties
    static let heightCell: CGFloat = 55
    
    var urlString: String? {
        didSet {
            self.urlLabel.text = urlString
        }
    }
    
    private lazy var urlLabel: UILabel = {
        let label = UILabel()
        label.font = .fontGilroyMedium(15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - View Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Helpers
    func configureUI() {
        addSubview(urlLabel)
        
        NSLayoutConstraint.activate([
            urlLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 15),
            urlLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -15),
            
            urlLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

    }
    
    //MARK: - Selectors
    
}
//MARK: - delegate

