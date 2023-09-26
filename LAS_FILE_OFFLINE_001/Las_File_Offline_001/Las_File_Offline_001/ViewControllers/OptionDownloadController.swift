//
//  TestPopController.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 30/07/2023.
//

import UIKit

protocol OptionDownloadVCDelegate: AnyObject {
    func didSlectOption(type: OptionDownload)
}

enum OptionDownload: Int, CaseIterable {
    case all
    case photos
    case videos
    case audios
    case docx
    
    var image: UIImage? {
        switch self {
        case .all:
            return UIImage(named: AssetConstant.ic_all)
        case .photos:
            return UIImage(named: AssetConstant.ic_photo)
        case .videos:
            return UIImage(named: AssetConstant.ic_video)
        case .audios:
            return UIImage(named: AssetConstant.ic_audio)
        case .docx:
            return UIImage(named: AssetConstant.ic_document)
        }
    }
    
    var title: String {
        switch self {
        case .all:
            return "All"
        case .photos:
            return AppConstant.photo
        case .videos:
            return AppConstant.video
        case .audios:
            return AppConstant.audio
        case .docx:
            return AppConstant.docx
        }
    }
}

class OptionDownloadController: PopoverCustomController {
    
    //MARK: - Properties
    static let sizeView: CGSize = CGSize(width: 258, height: 243)
    
    
    //MARK: - UIComponent
    weak var delegate: OptionDownloadVCDelegate?
    let optionTB = UITableView()
    var selectedOption: OptionDownload
    
    override var popoverView: UIView {
        return optionTB
    }
    
    //MARK: - View Lifecycle
    init(selectedOption: OptionDownload,
                  popoverSize: CGSize,
                  pointAppear: CGPoint,
                  popoverDirection: PopoverDirection = .botLeft) {
        self.selectedOption = selectedOption
        super.init(popoverSize: popoverSize, pointAppear: pointAppear, popoverDirection: popoverDirection)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureProperties()
    }
    
    override func configureUI() {
        super.configureUI()
        
        optionTB.layer.cornerRadius = 10
        optionTB.backgroundColor = .white
    }
}

//MARK: - Method
extension OptionDownloadController {
    
    //MARK: - Helpers
    func configureProperties() {
        optionTB.separatorStyle = .singleLine
        optionTB.delegate = self
        optionTB.dataSource = self
        optionTB.register(OptionDownloadTBCell.self, forCellReuseIdentifier: OptionDownloadTBCell.cellId)
        optionTB.clipsToBounds = true
        optionTB.isScrollEnabled = false
    }
    
    //MARK: - Selectors
    
}


extension OptionDownloadController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OptionDownload.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OptionDownloadTBCell.cellId,
                                                 for: indexPath) as! OptionDownloadTBCell
        cell.cellType = OptionDownload(rawValue: indexPath.row)
        if cell.cellType == selectedOption {
            cell.hasSelected = true
        }
        
        if indexPath.row != 0 {
            cell.separatorInset = .init(top: 0, left: OptionDownloadController.sizeView.width, bottom: 0, right: 0)
        } else {
            cell.separatorInset = .init(top: 0, left: 17, bottom: 0, right: 17)
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.didSlectOption(type: OptionDownload(rawValue: indexPath.row) ?? .all)
        self.animationDismiss()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return OptionDownloadTBCell.heightCell
    }
    
}

