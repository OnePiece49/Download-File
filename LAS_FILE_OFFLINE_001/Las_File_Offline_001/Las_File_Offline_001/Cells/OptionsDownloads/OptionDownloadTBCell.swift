//
//  OptionDownloadTBCell.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 30/07/2023.
//

import UIKit

class OptionDownloadTBCell: UITableViewCell {
    
    //MARK: - Properties
    static let heightCell: CGFloat = 48
    var cellType: OptionDownload? {
        didSet {updateUI()}
    }
    
    var hasSelected: Bool = false {
        didSet {
            self.titleBtn.tintColor = .primaryBlue
            self.titleLbl.textColor = .primaryBlue
        }
    }
    
    private lazy var titleLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleBtn: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    private func configureUI() {
        contentView.addSubview(titleLbl)
        contentView.addSubview(titleBtn)
        
        NSLayoutConstraint.activate([
            titleLbl.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLbl.leftAnchor.constraint(equalTo: leftAnchor, constant: 19),
            
            titleBtn.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleBtn.rightAnchor.constraint(equalTo: rightAnchor, constant: -17),
        ])
    }
    
    private func updateUI() {
        self.titleLbl.text = cellType?.title
        self.titleBtn.setImage(cellType?.image, for: .normal)

    }
    
    //MARK: - Selectors
    
}
//MARK: - delegate

