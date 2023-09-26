//
//  FileDisplayModeTBCell.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 08/08/2023.
//

import UIKit

class FileDisplayModeTBCell: UITableViewCell {

	//MARK: - Properties
	static let cellHeight: CGFloat = 48

	var displayMode: FileController.DisplayMode? {
		didSet { updateUI() }
	}

	var hasSelected: Bool = false {
		didSet {
			self.titleBtn.tintColor = .primaryBlue
			self.titleLbl.textColor = .primaryBlue
		}
	}

	// MARK: - UI components
	private lazy var titleLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private lazy var titleBtn: UIButton = {
		let button = UIButton(type: .system)
		button.tintColor = .black
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
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
		contentView.addSubview(titleLbl)
		contentView.addSubview(titleBtn)

		NSLayoutConstraint.activate([
			titleLbl.centerYAnchor.constraint(equalTo: centerYAnchor),
			titleLbl.leftAnchor.constraint(equalTo: leftAnchor, constant: 19),

			titleBtn.centerYAnchor.constraint(equalTo: centerYAnchor),
			titleBtn.rightAnchor.constraint(equalTo: rightAnchor, constant: -17),
		])
	}

	private func updateUI() {
		guard let displayMode = displayMode else { return }
		self.titleLbl.text = displayMode.title
		self.titleBtn.setImage(UIImage(named: displayMode.iconName), for: .normal)
	}
}
