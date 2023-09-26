//
//  GridFolderCLCell.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 02/08/2023.
//

import UIKit

class GridFolderCLCell: UICollectionViewCell {

	static let cellWidth: CGFloat = 105
	static let cellHeight: CGFloat = 140

	var viewModel: FolderCLCellViewModel? {
		didSet { updateUI() }
	}
	var onSelectOption: ((_ sender: UIButton) -> Void)?

	// MARK: - UI components
	private let posterImv: UIImageView = {
		let imv = UIImageView()
		imv.translatesAutoresizingMaskIntoConstraints = false
		imv.contentMode = .scaleAspectFill
		imv.isUserInteractionEnabled = false
		return imv
	}()

	private let nameLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 2
		label.font = .fontGilroyMedium(16)
		label.textColor = UIColor.black
		label.textAlignment = .left
		return label
	}()

	private lazy var optionBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.tintColor = .white
		btn.setImage(UIImage(named: AssetConstant.ic_option), for: .normal)
		btn.addTarget(self, action: #selector(optionBtnTapped), for: .touchUpInside)
		return btn
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
		contentView.addSubview(optionBtn)

		NSLayoutConstraint.activate([
			posterImv.leftAnchor.constraint(equalTo: contentView.leftAnchor),
			posterImv.topAnchor.constraint(equalTo: contentView.topAnchor),
			posterImv.widthAnchor.constraint(equalToConstant: GridFolderCLCell.cellWidth),
			posterImv.heightAnchor.constraint(equalToConstant: 91),

			nameLbl.leftAnchor.constraint(equalTo: contentView.leftAnchor),
			nameLbl.topAnchor.constraint(equalTo: posterImv.bottomAnchor, constant: 8),
			nameLbl.rightAnchor.constraint(equalTo: contentView.rightAnchor),

			optionBtn.leftAnchor.constraint(equalTo: posterImv.leftAnchor, constant: -4),
			optionBtn.topAnchor.constraint(equalTo: posterImv.topAnchor, constant: -4),
			optionBtn.widthAnchor.constraint(equalToConstant: 36),
			optionBtn.heightAnchor.constraint(equalToConstant: 36),
		])
	}

	private func updateUI() {
		guard let viewModel = viewModel else { return }
		posterImv.image = UIImage(named: viewModel.posterName)
		nameLbl.text = viewModel.folderName
		optionBtn.isHidden = viewModel.shouldHideOption
		optionBtn.isEnabled = viewModel.shouldEnableOption
		optionBtn.setImage(UIImage(named: viewModel.optionImgName), for: .normal)
	}

	@objc private func optionBtnTapped() {
		onSelectOption?(optionBtn)
	}
}
