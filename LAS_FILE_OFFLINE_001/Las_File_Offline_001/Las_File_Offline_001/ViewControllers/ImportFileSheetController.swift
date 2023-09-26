//
//  ImportFileSheetController.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 31/07/2023.
//

import UIKit

enum ImportFileOption {
	case cameraRoll
	case fileBrowser

	var title: String {
		switch self {
			case .cameraRoll: return "Camera Roll"
			case .fileBrowser: return "Import Files"
		}
	}

	var iconName: String {
		switch self {
			case .cameraRoll: return AssetConstant.ic_camera_roll
			case .fileBrowser: return AssetConstant.ic_import_file
		}
	}
}

protocol ImportFileSheetControllerDelegate: AnyObject {
	func didSelectCameraRoll(_ controller: ImportFileSheetController)
	func didSelectFileBrowser(_ controller: ImportFileSheetController)
}

class ImportFileSheetController: BottomSheetViewController {

	override var rootView: UIView {
		return containerView
	}

	override var sheetHeight: BottomSheetHeight {
		return .fixed(240)
	}

	override var sheetType: BottomSheetType {
		return .float(leftSpacing: 0, rightSpacing: 0, bottomSpacing: 0)
	}

	private let layouts: [ImportFileOption] = [.cameraRoll, .fileBrowser]
	weak var delegate: ImportFileSheetControllerDelegate?

	// MARK: - UI components
	private let containerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .white
		return view
	}()

	private var headerView: NavigationCustomView!

	private let importFileTbv: UITableView = {
		let tbv = UITableView()
		tbv.translatesAutoresizingMaskIntoConstraints = false
		return tbv
	}()

	// MARK: - Life cycle
    override func viewDidLoad() {
		setupHeaderView()
		setupTBView()
        super.viewDidLoad()
    }

	override func setupConstraints() {
		super.setupConstraints()
		containerView.addSubview(headerView)
		containerView.addSubview(importFileTbv)

		NSLayoutConstraint.activate([
			headerView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
			headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
			headerView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
			headerView.heightAnchor.constraint(equalToConstant: 66),

			importFileTbv.leftAnchor.constraint(equalTo: containerView.leftAnchor),
			importFileTbv.topAnchor.constraint(equalTo: headerView.bottomAnchor),
			importFileTbv.rightAnchor.constraint(equalTo: containerView.rightAnchor),
			importFileTbv.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
		])
	}

	private func setupHeaderView() {
		let firstBtnLeft = AttibutesButton(image: UIImage(named: AssetConstant.ic_plus)?.withRenderingMode(.alwaysOriginal),
										   sizeImage: CGSize(width: 17, height: 17))
		let secondBtnLeft = AttibutesButton(tilte: "Import From", font: .fontGilroyBold(16), tincolor: .black)

		let firstBtnRight = AttibutesButton(tilte: "Cancel", font: .fontGilroyBold(16), titleColor: .primaryBlue) { [weak self] in
			self?.removeSheet()
		}

		headerView = NavigationCustomView(attributeLeftButtons: [firstBtnLeft, secondBtnLeft],
										  attributeRightBarButtons: [firstBtnRight],
										  beginSpaceLeftButton: 20, beginSpaceRightButton: 18)
		headerView.backgroundColor = .white
	}

	private func setupTBView() {
		importFileTbv.isScrollEnabled = false
		importFileTbv.separatorStyle = .none
		importFileTbv.delegate = self
		importFileTbv.dataSource = self
		importFileTbv.register(ImportFileSheetTBCell.self, forCellReuseIdentifier: ImportFileSheetTBCell.cellId)
	}

	override func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
		return
	}
}

// MARK: - UITableViewDelegate
extension ImportFileSheetController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return layouts.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: ImportFileSheetTBCell.cellId, for: indexPath) as! ImportFileSheetTBCell
		cell.selectionStyle = .none
		cell.option = layouts[indexPath.row]
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let option = layouts[indexPath.row]
		self.removeSheet(completion: { [weak self] in
			guard let self = self else { return }
			switch option {
				case .cameraRoll:
					self.delegate?.didSelectCameraRoll(self)
				case .fileBrowser:
					self.delegate?.didSelectFileBrowser(self)
			}
		})
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return ImportFileSheetTBCell.cellHeight
	}
}

