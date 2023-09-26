//
//  NotReachDomainView.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 13/08/2023.
//

import Foundation

import UIKit

class NotReachDomainView: UIView {
    
    //MARK: - Properties
    private lazy var notReachLbl: UILabel = {
        let label = UILabel()
        label.text = "Domain cannot be reached"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var notReachImv: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: AssetConstant.ic_can_not_load)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    
    //MARK: - View Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    func configureUI() {
        addSubview(notReachLbl)
        addSubview(notReachImv)
        
        NSLayoutConstraint.activate([
            notReachImv.centerXAnchor.constraint(equalTo: centerXAnchor),
            notReachImv.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -15),
            
            notReachLbl.centerXAnchor.constraint(equalTo: centerXAnchor),
            notReachLbl.topAnchor.constraint(equalTo: notReachImv.bottomAnchor, constant: 30),
        ])
        notReachImv.setDimensions(width: 80, height: 80)

    }
    
    //MARK: - Selectors
    
}
//MARK: - delegate


//MARK: -
