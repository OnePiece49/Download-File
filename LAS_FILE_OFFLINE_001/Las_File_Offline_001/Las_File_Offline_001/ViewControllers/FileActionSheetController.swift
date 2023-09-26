//
//  FileActionSheetController.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 04/08/2023.
//

import UIKit

extension FileActionSheetController {
	enum ActionType: String {
		case copy
		case move

		var title: String {
			switch self {
				case .copy: return "Copy"
				case .move: return "Move"
			}
		}

		var imgName: String {
			switch self {
				case .copy: return AssetConstant.ic_copy_to
				case .move: return AssetConstant.ic_move_to
			}
		}
	}
}

protocol FileActionSheetControllerDelegate: AnyObject {
	func finishModifyFolder(_ controller: FileActionSheetController, actionType: FileActionSheetController.ActionType)
}

class FileActionSheetController: BottomSheetViewController {

	weak var delegate: FileActionSheetControllerDelegate?
	private let viewModel: FileActionSheetViewModel

	override var rootView: UIView {
		return containerView
	}

	override var sheetHeight: BottomSheetHeight {
		return .aspect(560/852)
	}

	override var sheetType: BottomSheetType {
		return .float(leftSpacing: 0, rightSpacing: 0, bottomSpacing: 0)
	}

	// MARK: - UI components
	let containerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .white
		return view
	}()

	private lazy var headerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(iconImv)
		view.addSubview(titleLbl)
		view.addSubview(cancelBtn)
		return view
	}()

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
		label.font = .fontGilroyBold(16)
		label.textColor = .black
		return label
	}()

	private lazy var cancelBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.setTitle("Cancel", for: .normal)
		btn.setTitleColor(.primaryBlue, for: .normal)
		btn.titleLabel?.font = .fontGilroyBold(16)
		btn.addTarget(self, action: #selector(cancelBtnTapped), for: .touchUpInside)
		return btn
	}()

	let folderTbv: UITableView = {
		let tbv = UITableView()
		tbv.translatesAutoresizingMaskIntoConstraints = false
		return tbv
	}()

	lazy var bottomView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(createFolderBtn)
		return view
	}()

	lazy var createFolderBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.setTitle("Create Folder", for: .normal)
		btn.setTitleColor(.primaryBlue, for: .normal)
		btn.setImage(UIImage(named: AssetConstant.ic_plus)?.withRenderingMode(.alwaysOriginal), for: .normal)
		btn.imageEdgeInsets.left = -12
		btn.addTarget(self, action: #selector(createFolderBtnTapped), for: .touchUpInside)
		return btn
	}()

	// MARK: - Lifecycle
	init(viewModel: FileActionSheetViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
		setupTBView()
        super.viewDidLoad()
		bindViewModel()
		iconImv.image = UIImage(named: viewModel.imgName)
		titleLbl.text = viewModel.title
    }

	private func setupTBView() {
		folderTbv.rowHeight = FileActionSheetTBCell.cellHeight
		folderTbv.separatorStyle = .none
		folderTbv.delegate = self
		folderTbv.dataSource = self
		folderTbv.register(FileActionSheetTBCell.self, forCellReuseIdentifier: FileActionSheetTBCell.cellId)
	}

	override func setupConstraints() {
		super.setupConstraints()
		containerView.addSubview(headerView)
		containerView.addSubview(folderTbv)
		containerView.addSubview(bottomView)

		NSLayoutConstraint.activate([
			headerView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
			headerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
			headerView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
			headerView.heightAnchor.constraint(equalToConstant: 36),

			iconImv.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 20),
			iconImv.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

			titleLbl.leftAnchor.constraint(equalTo: iconImv.rightAnchor, constant: 12),
			titleLbl.centerYAnchor.constraint(equalTo: iconImv.centerYAnchor),

			cancelBtn.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -20),
			cancelBtn.centerYAnchor.constraint(equalTo: iconImv.centerYAnchor),

			folderTbv.leftAnchor.constraint(equalTo: containerView.leftAnchor),
			folderTbv.topAnchor.constraint(equalTo: headerView.bottomAnchor),
			folderTbv.rightAnchor.constraint(equalTo: containerView.rightAnchor),
			folderTbv.bottomAnchor.constraint(equalTo: bottomView.topAnchor),

			bottomView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
			bottomView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
			bottomView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor),
			bottomView.heightAnchor.constraint(equalToConstant: 36),

			createFolderBtn.leftAnchor.constraint(equalTo: bottomView.leftAnchor, constant: 20),
			createFolderBtn.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 20)
		])
	}

	@objc private func cancelBtnTapped() {
		self.removeSheet()
	}

	@objc private func createFolderBtnTapped() {
		let alert = UIAlertController(title: "Create new folder", message: "", preferredStyle: .alert)
		alert.addTextField()

		alert.textFields?.first?.placeholder = "Enter name"

		alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak self] _ in
			let text = alert.textFields?.first?.text

			guard let text = text, text.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
				self?.view.displayToast("File's name is invalide", position: .center)
				return
			}
			let success = self?.viewModel.createFolder(name: text)
			let msg = success == true ? "Create folder successful" : "Failed to delete folder"
			self?.view.displayToast(msg)
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

		self.present(alert, animated: true)
	}

	private func bindViewModel() {
		viewModel.onCreateFolder = { [weak self] in
			self?.folderTbv.reloadData()
		}
	}
}

// MARK: - UITableViewDataSource
extension FileActionSheetController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfItems
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: FileActionSheetTBCell.cellId,
												 for: indexPath) as! FileActionSheetTBCell
		cell.viewModel = FolderCLCellViewModel(folder: viewModel.folders[indexPath.row],
											   zipFolder: nil)
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let sucess = viewModel.didSelectFolder(at: indexPath.row)

		if sucess {
			removeSheet { [weak self] in
				guard let self = self else { return }
				self.delegate?.finishModifyFolder(self, actionType: self.viewModel.type)
			}
			view.displayToast("\(viewModel.type.title) file successful")

		} else {
			view.displayToast("Failed to \(viewModel.type.rawValue) file")
		}
	}
}

