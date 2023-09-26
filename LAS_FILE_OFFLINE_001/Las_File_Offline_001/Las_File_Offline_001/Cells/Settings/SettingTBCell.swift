//
//  SettingTBCell.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 03/08/2023.
//

import UIKit


enum SettingOption: Int, CaseIterable {
    case rate
    case share
    case contact
    case privacy
    
    var title: String {
        switch self {
        case .rate:
            return "Rate App"
        case .share:
            return "Share with friend"
        case .contact:
            return "Contact"
        case .privacy:
            return "Privacy"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .rate:
            return UIImage(named: AssetConstant.ic_rate_app)
        case .share:
            return UIImage(named: AssetConstant.ic_share_blue)
        case .contact:
            return UIImage(named: AssetConstant.ic_contact)
        case .privacy:
            return UIImage(named: AssetConstant.ic_privacy)
        }
    }
}


class SettingTBCell: UITableViewCell {
    
    //MARK: - Properties
    private lazy var settingImv: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .center
        return iv
    }()

    private lazy var settingLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .fontGilroyMedium(16)
        return label
    }()
    
    static let heightCell: CGFloat = 75
    
    var cellType: SettingOption? {
        didSet {
            updateUI()
        }
    }
    
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
        addSubview(settingImv)
        addSubview(settingLbl)
        
        NSLayoutConstraint.activate([
            settingImv.centerYAnchor.constraint(equalTo: centerYAnchor),
            settingImv.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            
            
            settingLbl.centerYAnchor.constraint(equalTo: centerYAnchor),
            settingLbl.leftAnchor.constraint(equalTo: settingImv.rightAnchor, constant: 20),
        ])
        settingImv.setDimensions(width: 30, height: 30)

    }
    
    //MARK: - Selectors
    private func updateUI() {
        settingImv.image = cellType?.image
        settingLbl.text = cellType?.title
    }
}
//MARK: - delegate

