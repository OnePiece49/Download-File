//
//  GridImportCLCell.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 01/08/2023.
//

import UIKit
import SDWebImage

class GridImportCLCell: UICollectionViewCell {

	static let cellWidth: CGFloat = 86
	static let cellHeight: CGFloat = 170

	var viewModel: ImportCLCellViewModel? {
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
		label.font = .fontGilroyMedium(14)
		label.textColor = UIColor.black
		label.textAlignment = .center
		return label
	}()

	private let fileSizeLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 1
		label.font = .fontGilroyMedium(12)
		label.textColor = UIColor(rgb: 0x6C6C6C)
		label.textAlignment = .center
		return label
	}()

	// MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupConstraints()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupConstraints()
	}

	// MARK: - Methods
	private func setupConstraints() {
		contentView.addSubview(posterImv)
		contentView.addSubview(nameLbl)
		contentView.addSubview(fileSizeLbl)

		NSLayoutConstraint.activate([
			posterImv.leftAnchor.constraint(equalTo: contentView.leftAnchor),
			posterImv.topAnchor.constraint(equalTo: contentView.topAnchor),
			posterImv.rightAnchor.constraint(equalTo: contentView.rightAnchor),
			posterImv.heightAnchor.constraint(equalTo: posterImv.widthAnchor),

			nameLbl.leftAnchor.constraint(equalTo: contentView.leftAnchor),
			nameLbl.topAnchor.constraint(equalTo: posterImv.bottomAnchor, constant: 4),
			nameLbl.rightAnchor.constraint(equalTo: contentView.rightAnchor),

			fileSizeLbl.leftAnchor.constraint(equalTo: contentView.leftAnchor),
			fileSizeLbl.topAnchor.constraint(equalTo: nameLbl.bottomAnchor, constant: 4),
			fileSizeLbl.rightAnchor.constraint(equalTo: contentView.rightAnchor)
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
	}
}
