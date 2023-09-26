//
//  ZipFilesSuccessController.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 08/08/2023.
//

import UIKit

class ZipFilesSuccessController: BottomSheetViewController {

	let zipFile: FileZipModel

	override var rootView: UIView {
		return containerView
	}

	override var sheetHeight: BottomSheetHeight {
		return .fixed(270)
	}

	override var sheetType: BottomSheetType {
		return .fill
	}

	// MARK: - UI components
	private let containerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .white
		return view
	}()

	private let iconImv: UIImageView = {
		let imv = UIImageView()
		imv.translatesAutoresizingMaskIntoConstraints = false
		imv.contentMode = .scaleAspectFit
		imv.image = UIImage(named: AssetConstant.ic_zip_black)
		return imv
	}()

	private let fileNameLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 2
		label.font = .fontGilroySemi(18)
		label.textColor = .black
		label.textAlignment = .left
		return label
	}()

	private let fileSizeLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 1
		label.font = .fontGilroyMedium(14)
		label.textColor = UIColor(rgb: 0x6C6C6C)
		label.textAlignment = .left
		return label
	}()

	private let countLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 1
		label.font = .fontGilroySemi(14)
		label.textColor = UIColor(rgb: 0x6C6C6C)
		return label
	}()

	private lazy var shareBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.setTitle("Share", for: .normal)
		btn.setTitleColor(UIColor.black, for: .normal)
		btn.titleLabel?.font = .fontGilroyMedium(16)
		btn.layer.cornerRadius = 15
		btn.layer.borderWidth = 1
		btn.layer.borderColor = UIColor.black.cgColor
		btn.addTarget(self, action: #selector(shareBtnTapped), for: .touchUpInside)
		return btn
	}()

	private lazy var fileBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.setTitle("Back to Files", for: .normal)
		btn.setTitleColor(UIColor.white, for: .normal)
		btn.titleLabel?.font = .fontGilroyMedium(16)
		btn.backgroundColor = UIColor.primaryBlue
		btn.layer.cornerRadius = 15
		btn.addTarget(self, action: #selector(fileBtnTapped), for: .touchUpInside)
		return btn
	}()

	// MARK: - Lifecycle
	init(zipFile: FileZipModel) {
		self.zipFile = zipFile
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupConstraints()

		fileNameLbl.text = zipFile.name
		fileSizeLbl.text = zipFile.fileSize
		countLbl.text = "\(zipFile.files.count) items"
	}

	override func setupConstraints() {
		super.setupConstraints()

		let lblStack = UIStackView(arrangedSubviews: [fileNameLbl, countLbl, fileSizeLbl])
		lblStack.axis = .vertical
		lblStack.spacing = 8
		lblStack.translatesAutoresizingMaskIntoConstraints = false

		let btnStack = UIStackView(arrangedSubviews: [fileBtn, shareBtn])
		btnStack.axis = .horizontal
		btnStack.spacing = 40
		btnStack.translatesAutoresizingMaskIntoConstraints = false

		containerView.addSubview(iconImv)
		containerView.addSubview(lblStack)
		containerView.addSubview(btnStack)

		NSLayoutConstraint.activate([
			iconImv.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20),
			iconImv.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
			iconImv.widthAnchor.constraint(equalToConstant: 80),
			iconImv.heightAnchor.constraint(equalToConstant: 120),

			lblStack.leftAnchor.constraint(equalTo: iconImv.rightAnchor, constant: 20),
			lblStack.centerYAnchor.constraint(equalTo: iconImv.centerYAnchor),
			lblStack.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -12),
			lblStack.heightAnchor.constraint(lessThanOrEqualTo: iconImv.heightAnchor),

			btnStack.topAnchor.constraint(equalTo: iconImv.bottomAnchor, constant: 20),
			btnStack.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

			fileBtn.widthAnchor.constraint(equalToConstant: 150),
			fileBtn.heightAnchor.constraint(equalToConstant: 46),
			shareBtn.widthAnchor.constraint(equalToConstant: 150),
			shareBtn.heightAnchor.constraint(equalToConstant: 46),
		])
	}

	// MARK: - Methods
	@objc private func shareBtnTapped() {
		let objectsToShare: [Any] = [zipFile.absolutePath as Any]
		let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
		activityVC.popoverPresentationController?.sourceView = self.view
		self.present(activityVC, animated: true, completion: nil)
	}

	@objc private func fileBtnTapped() {
		removeSheet() {
			guard let navi = UIWindow.keyWindow?.rootViewController as? UINavigationController else { return }
			navi.popToRootViewController(animated: true)
		}
	}
}
