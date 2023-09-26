//
//  FolderDetailTBCell.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 03/08/2023.
//

import UIKit
import SDWebImage

class FolderDetailTBCell: UITableViewCell {

	static let cellHeight: CGFloat = 88

	var viewModel: FolderDetailTBCellViewModel? {
		didSet { updateUI() }
	}

	// MARK: - UI components
	private let posterImv: UIImageView = {
		let imv = UIImageView()
		imv.translatesAutoresizingMaskIntoConstraints = false
		imv.contentMode = .scaleAspectFill
		imv.layer.cornerRadius = 10
		imv.clipsToBounds = true
		imv.backgroundColor = UIColor(rgb: 0xE7F3FF)
		return imv
	}()

	private let nameLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 2
		label.font = .fontGilroyMedium(16)
		label.textColor = UIColor.black
		label.textAlignment = .left
		label.text = "Camera-roll.png"
		return label
	}()

	private let fileSizeLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 1
		label.font = .fontGilroyMedium(12)
		label.textColor = UIColor(rgb: 0x6C6C6C)
		label.textAlignment = .left
		label.text = "12.5 MB"
		return label
	}()

	private let checklistImv: UIImageView = {
		let imv = UIImageView()
		imv.translatesAutoresizingMaskIntoConstraints = false
		imv.contentMode = .scaleAspectFill
		imv.image = UIImage(named: AssetConstant.ic_checklist_unselect)
		return imv
	}()

	// MARK: - Init
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupConstraints()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupConstraints()
	}

	// MARK: - Methods
	private func setupConstraints() {
		let stack = UIStackView(arrangedSubviews: [nameLbl, fileSizeLbl])
		stack.axis = .vertical
		stack.spacing = 4
		stack.translatesAutoresizingMaskIntoConstraints = false

		contentView.addSubview(posterImv)
		contentView.addSubview(stack)
		contentView.addSubview(checklistImv)

		NSLayoutConstraint.activate([
			posterImv.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
			posterImv.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			posterImv.widthAnchor.constraint(equalToConstant: 72),
			posterImv.heightAnchor.constraint(equalTo: posterImv.widthAnchor),

			stack.leftAnchor.constraint(equalTo: posterImv.rightAnchor, constant: 16),
			stack.centerYAnchor.constraint(equalTo: posterImv.centerYAnchor),
			stack.heightAnchor.constraint(lessThanOrEqualTo: posterImv.heightAnchor),

			checklistImv.leftAnchor.constraint(equalTo: stack.rightAnchor, constant: 8),
			checklistImv.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
			checklistImv.centerYAnchor.constraint(equalTo: posterImv.centerYAnchor),
			checklistImv.widthAnchor.constraint(equalToConstant: 20),
			checklistImv.heightAnchor.constraint(equalToConstant: 20),
		])
	}

	private func updateUI() {
		guard let viewModel = viewModel else { return }
		nameLbl.text = viewModel.fileName
		fileSizeLbl.text = viewModel.fileSize

		if viewModel.isPhoto {
			let transformer = SDImageResizingTransformer(size: CGSize(width: 200, height: 200), scaleMode: .fill)
			posterImv.sd_setImage(with: viewModel.absoluteURL, placeholderImage: nil, context: [.imageTransformer: transformer])
			posterImv.contentMode = .scaleAspectFill
		} else {
			posterImv.image = UIImage(named: viewModel.getDefaultImage())
			posterImv.contentMode = .center
		}

		checklistImv.isHidden = viewModel.shouldHideChecklist
		checklistImv.image = UIImage(named: viewModel.checklistImgName)
	}

//	func updateSelectionState(_ select: Bool) {
//		let imgName = select ? AssetConstant.ic_checklist_select : AssetConstant.ic_checklist_unselect
//		checklistImv.image = UIImage(named: imgName)
//	}
//
//	func updateSelectionMode(_ mode: FolderDetailController.Mode) {
//		self.mode = mode
//		checklistImv.isHidden = (mode == .normal) ? true : false
//	}

	
}
