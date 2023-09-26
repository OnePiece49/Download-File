//
//  DownloadTBCell.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 31/07/2023.
//

import UIKit

import UIKit

class DownloadTBCell: UITableViewCell {
    
    //MARK: - Properties
    static let heightCell: CGFloat = 80
    
    var viewModel: DowloadCellViewModel? {
        didSet {
            updateUI()
        }
    }
    
    var cellType: FileModel.FileType? {
        return viewModel?.fileType
    }
    
    var fileURL: URL? {
        return viewModel?.fileURL
    }
    
    var imageFile: UIImage? {
        return viewModel?.actualImage
    }
    
    private lazy var nameFileLbl: UILabel = {
        let label = UILabel()
        label.font = .fontGilroyMedium(16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var sizeLbl: UILabel = {
        let label = UILabel()
        label.font = .fontGilroyMedium(12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var fileImv: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.backgroundColor = UIColor(rgb: 0xE7F3FF)
        iv.contentMode = .center
        return iv
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
        addSubview(fileImv)
        addSubview(nameFileLbl)
        addSubview(sizeLbl)
        
        NSLayoutConstraint.activate([
            fileImv.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            fileImv.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            fileImv.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7),
            fileImv.widthAnchor.constraint(equalTo: fileImv.heightAnchor),
            
            nameFileLbl.topAnchor.constraint(equalTo: fileImv.topAnchor, constant: 10),
            nameFileLbl.leftAnchor.constraint(equalTo: fileImv.rightAnchor, constant: 16),
            nameFileLbl.rightAnchor.constraint(equalTo: rightAnchor, constant: -30),
            
            sizeLbl.topAnchor.constraint(equalTo: nameFileLbl.bottomAnchor, constant: 12),
            sizeLbl.leftAnchor.constraint(equalTo: nameFileLbl.leftAnchor),
            sizeLbl.rightAnchor.constraint(equalTo: rightAnchor, constant: -30),
        ])
    }
    
    private func updateUI() {

        if viewModel?.isPhoto == true {
            let _ = viewModel?.imageFile(iv: fileImv)
        } else {
            self.fileImv.image = viewModel?.imageFile()
        }
        
        self.sizeLbl.text = viewModel?.sizeFile
        self.nameFileLbl.text = viewModel?.nameFile
        self.fileImv.contentMode = viewModel?.contentMode ?? .center
    }
    
    //MARK: - Selectors
    
}
//MARK: - delegate

