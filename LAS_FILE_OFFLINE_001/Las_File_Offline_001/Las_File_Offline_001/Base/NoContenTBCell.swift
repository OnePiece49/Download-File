//
//  NoContenTBCell.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 03/08/2023.
//

import Foundation

import UIKit

class NoContenTBCell: UITableViewCell {
    
    //MARK: - Properties
    var font: UIFont? {
        didSet {
            nodataLbl.font = font
        }
    }
    
    
    private lazy var nodataLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .fontGilroyMedium(30)
        label.text = "No Content"
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
        addSubview(nodataLbl)
        
        NSLayoutConstraint.activate([
            nodataLbl.centerXAnchor.constraint(equalTo: centerXAnchor),
            nodataLbl.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50),
        ])
        
    }
    
    //MARK: - Selectors
    
}
//MARK: - delegate

