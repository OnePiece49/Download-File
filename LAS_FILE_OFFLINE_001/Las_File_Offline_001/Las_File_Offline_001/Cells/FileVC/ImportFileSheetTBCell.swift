//
//  ImportFileSheetTBCell.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 31/07/2023.
//

import UIKit

class ImportFileSheetTBCell: UITableViewCell {

	static let cellHeight: CGFloat = 60

	var option: ImportFileOption? {
		didSet {
			guard let option = option else { return }
			iconImv.image = UIImage(named: option.iconName)
			titleLbl.text = option.title
		}
	}

	// MARK: - UI components
	private let iconImv: UIImageView = {
		let imv = UIImageView()
		imv.translatesAutoresizingMaskIntoConstraints = false
		imv.contentMode = .scaleAspectFill
		return imv
	}()

	private let titleLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 1
		label.font = .fontGilroyMedium(16)
		label.textColor = .black
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

	private func setupConstraints() {
		contentView.addSubview(iconImv)
		contentView.addSubview(titleLbl)

		NSLayoutConstraint.activate([
			iconImv.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
			iconImv.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			iconImv.widthAnchor.constraint(equalToConstant: 20),
			iconImv.heightAnchor.constraint(equalToConstant: 20),

			titleLbl.leftAnchor.constraint(equalTo: iconImv.rightAnchor, constant: 12),
			titleLbl.rightAnchor.constraint(equalTo: contentView.rightAnchor),
			titleLbl.centerYAnchor.constraint(equalTo: iconImv.centerYAnchor)
		])
	}
}
