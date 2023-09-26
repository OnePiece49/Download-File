//
//  ZipFolderTBCell.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 07/08/2023.
//

import UIKit

class ZipFolderTBCell: UITableViewCell {

	static let cellHeight: CGFloat = 81

	var viewModel: ZipFolderTBCellViewModel? {
		didSet {
			nameLbl.text = viewModel?.filename
			fileSizeLbl.text = viewModel?.filesize
		}
	}

	// MARK: - UI components
	private let posterImv: UIImageView = {
		let imv = UIImageView()
		imv.translatesAutoresizingMaskIntoConstraints = false
		imv.contentMode = .scaleAspectFit
		imv.image = UIImage(named: AssetConstant.ic_zip_black)
		imv.clipsToBounds = true
		return imv
	}()

	private let nameLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 2
		label.font = .fontGilroyMedium(16)
		label.textColor = UIColor.black
		label.textAlignment = .left
		label.text = "Changgg"
		return label
	}()

	private let fileSizeLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 1
		label.font = .fontGilroyMedium(12)
		label.textColor = UIColor(rgb: 0x6C6C6C)
		label.textAlignment = .left
		label.text = "55.5 MB"
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
		let stack = UIStackView(arrangedSubviews: [nameLbl, fileSizeLbl])
		stack.axis = .vertical
		stack.spacing = 4
		stack.translatesAutoresizingMaskIntoConstraints = false

		contentView.addSubview(posterImv)
		contentView.addSubview(stack)

		NSLayoutConstraint.activate([
			posterImv.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
			posterImv.topAnchor.constraint(equalTo: contentView.topAnchor),
			posterImv.widthAnchor.constraint(equalToConstant: 53),
			posterImv.heightAnchor.constraint(equalToConstant: 61),

			stack.leftAnchor.constraint(equalTo: posterImv.rightAnchor, constant: 16),
			stack.centerYAnchor.constraint(equalTo: posterImv.centerYAnchor),
			stack.heightAnchor.constraint(lessThanOrEqualTo: posterImv.heightAnchor),
			stack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20)
		])
	}

}
