//
//  FileActionSheetTBCell.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 04/08/2023.
//

import UIKit

class FileActionSheetTBCell: UITableViewCell {

	static let cellHeight: CGFloat = 68

	var viewModel: FolderCLCellViewModel? {
		didSet { updateUI() }
	}

	// MARK: - UI components
	private let posterImv: UIImageView = {
		let imv = UIImageView()
		imv.translatesAutoresizingMaskIntoConstraints = false
		imv.contentMode = .scaleAspectFill
		imv.layer.cornerRadius = 10
		imv.clipsToBounds = true
		imv.image = UIImage(named: AssetConstant.ic_folder_large)
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

	private let folderSizeLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 1
		label.font = .fontGilroyMedium(12)
		label.textColor = UIColor(rgb: 0x6C6C6C)
		label.textAlignment = .left
		return label
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
		let stack = UIStackView(arrangedSubviews: [nameLbl, folderSizeLbl])
		stack.axis = .vertical
		stack.spacing = 4
		stack.translatesAutoresizingMaskIntoConstraints = false

		contentView.addSubview(posterImv)
		contentView.addSubview(stack)

		NSLayoutConstraint.activate([
			posterImv.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
			posterImv.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			posterImv.widthAnchor.constraint(equalToConstant: 55),
			posterImv.heightAnchor.constraint(equalToConstant: 48),

			stack.leftAnchor.constraint(equalTo: posterImv.rightAnchor, constant: 16),
			stack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
			stack.centerYAnchor.constraint(equalTo: posterImv.centerYAnchor),
			stack.heightAnchor.constraint(lessThanOrEqualTo: posterImv.heightAnchor)
		])
	}

	private func updateUI() {
		guard let viewModel = viewModel else { return }
		posterImv.image = UIImage(named: viewModel.posterName)
		nameLbl.text = viewModel.folderName
		folderSizeLbl.text = viewModel.folderSize
	}
}
