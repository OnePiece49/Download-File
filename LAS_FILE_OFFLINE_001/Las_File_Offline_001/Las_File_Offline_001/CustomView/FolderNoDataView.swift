//
//  FolderNoDataView.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 04/08/2023.
//

import UIKit

class FolderNoDataView: UIView {

	private lazy var imageBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.setImage(UIImage(named: AssetConstant.ic_folder_large), for: .normal)
		btn.isUserInteractionEnabled = false
		btn.tintColor = UIColor(rgb: 0xDEDEDE)
		return btn
	}()

	private let messageLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 2
		label.font = .fontGilroySemi(22)
		label.textColor = .black
		label.textAlignment = .center
		label.text = "No data"
		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupConstraints() {
		addSubview(imageBtn)
		addSubview(messageLbl)

		NSLayoutConstraint.activate([
			imageBtn.centerXAnchor.constraint(equalTo: centerXAnchor),
			imageBtn.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
			imageBtn.widthAnchor.constraint(equalToConstant: 71),
			imageBtn.heightAnchor.constraint(equalToConstant: 61),

			messageLbl.leftAnchor.constraint(equalTo: leftAnchor),
			messageLbl.topAnchor.constraint(equalTo: imageBtn.bottomAnchor, constant: 24),
			messageLbl.rightAnchor.constraint(equalTo: rightAnchor)
		])
	}

//	func setMessage(_ msg: String) {
//		messageLbl.text = msg
//	}
}
