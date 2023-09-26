//
//  ListFolderCLCell.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 02/08/2023.
//

import UIKit

class ListFolderCLCell: UICollectionViewCell {

	static let cellHeight: CGFloat = 81

	var viewModel: FolderCLCellViewModel? {
		didSet { updateUI() }
	}
	var onSelectOption: ((_ sender: UIButton) -> Void)?

	// MARK: - UI components
	private let posterImv: UIImageView = {
		let imv = UIImageView()
		imv.translatesAutoresizingMaskIntoConstraints = false
		imv.contentMode = .scaleAspectFill
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

	private let folderSizeLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 1
		label.font = .fontGilroyMedium(12)
		label.textColor = UIColor(rgb: 0x6C6C6C)
		label.textAlignment = .left
		return label
	}()

	lazy var optionBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.tintColor = .black 
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
		let stack = UIStackView(arrangedSubviews: [nameLbl, folderSizeLbl])
		stack.axis = .vertical
		stack.spacing = 4
		stack.translatesAutoresizingMaskIntoConstraints = false

		contentView.addSubview(posterImv)
		contentView.addSubview(stack)
		contentView.addSubview(optionBtn)

		NSLayoutConstraint.activate([
			posterImv.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
			posterImv.topAnchor.constraint(equalTo: contentView.topAnchor),
			posterImv.widthAnchor.constraint(equalToConstant: 71),
			posterImv.heightAnchor.constraint(equalToConstant: 61),

			stack.leftAnchor.constraint(equalTo: posterImv.rightAnchor, constant: 16),
			stack.centerYAnchor.constraint(equalTo: posterImv.centerYAnchor),
			stack.heightAnchor.constraint(lessThanOrEqualTo: posterImv.heightAnchor),

			optionBtn.leftAnchor.constraint(equalTo: stack.rightAnchor, constant: 12),
			optionBtn.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
			optionBtn.centerYAnchor.constraint(equalTo: posterImv.centerYAnchor),
			optionBtn.widthAnchor.constraint(equalToConstant: 36),
			optionBtn.heightAnchor.constraint(equalToConstant: 36),
		])
	}

	private func updateUI() {
		guard let viewModel = viewModel else { return }
		posterImv.image = UIImage(named: viewModel.posterName)
		nameLbl.text = viewModel.folderName
		folderSizeLbl.text = viewModel.folderSize
		optionBtn.isHidden = viewModel.shouldHideOption
		optionBtn.isEnabled = viewModel.shouldEnableOption
		optionBtn.setImage(UIImage(named: viewModel.optionImgName), for: .normal)
	}

	@objc private func optionBtnTapped() {
		onSelectOption?(optionBtn)
	}
}
