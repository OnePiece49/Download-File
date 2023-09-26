//
//  RecentImportDetailController.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 04/08/2023.
//

import UIKit
import QuickLook

extension RecentImportDetailController {
	enum Mode {
		case normal
		case select
	}
}

class RecentImportDetailController: BaseController {

	var viewModel: RecentImportDetailViewModel

	private let highlightLblHeight: CGFloat = 40

	// MARK: - UI components
	private var navbarView: NavigationCustomView!

	private let nodataView: FolderNoDataView = {
		let view = FolderNoDataView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		view.isUserInteractionEnabled = false
		return view
	}()

	private let highlightLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 1
		label.font = .fontGilroyMedium(20)
		label.textColor = .black
		label.textAlignment = .left
		label.isHidden = true
		return label
	}()

	private lazy var hightlightBtn: UIButton = {
		let btn = UIButton(type: .custom)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.setTitleColor(.black, for: .normal)
		btn.titleLabel?.font = .fontGilroyMedium(20)
		btn.contentEdgeInsets.left = 18
		btn.contentHorizontalAlignment = .left
		btn.isHidden = true
		btn.isUserInteractionEnabled = false
		return btn
	}()

	private let fileTbv: UITableView = {
		let tbv = UITableView()
		tbv.translatesAutoresizingMaskIntoConstraints = false
		return tbv
	}()

	private let headerActionView: HeaderActionView = {
		let view = HeaderActionView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.alpha = 0
		return view
	}()

	private let bottomActionView: BottomActionView = {
		let view = BottomActionView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.allowAction = [.share, .copy, .delete]
		return view
	}()

	// MARK: - Lifecycle
	init(viewModel: RecentImportDetailViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		print("FolderDetailController deinit")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavbar()
		setupTBView()
		bindViewModel()
		setupConstraints()
		headerActionView.delegate = self
		bottomActionView.delegate = self
	}

	private func setupNavbar() {
		let firstAtrLeft = AttibutesButton(tilte: "Back", font: .fontGilroySemi(16), titleColor: .primaryBlue) { [weak self] in
			self?.backBtnTapped()
		}
		let firstAtrRight = AttibutesButton(tilte: "Select", font: .fontGilroySemi(16), titleColor: .primaryBlue) { [weak self] in
			self?.viewModel.toggleMode()
		}

		navbarView = NavigationCustomView(centerTitle: "Recent Imports",
										  centertitleFont: .fontGilroyBold(22)!,
										  attributeLeftButtons: [firstAtrLeft],
										  attributeRightBarButtons: [firstAtrRight],
										  beginSpaceLeftButton: 20)
		navbarView.translatesAutoresizingMaskIntoConstraints = false
		navbarView.backgroundColor = .white
	}

	private func setupTBView() {
		fileTbv.rowHeight = FolderDetailTBCell.cellHeight
		fileTbv.separatorStyle = .none
		fileTbv.delegate = self
		fileTbv.dataSource = self
		fileTbv.register(FolderDetailTBCell.self, forCellReuseIdentifier: FolderDetailTBCell.cellId)
	}

	private func setupConstraints() {
		let stack = UIStackView(arrangedSubviews: [hightlightBtn, fileTbv])
		stack.spacing = 4
		stack.axis = .vertical
		stack.translatesAutoresizingMaskIntoConstraints = false

		view.addSubview(navbarView)
		view.addSubview(stack)
		view.addSubview(headerActionView)
		view.addSubview(bottomActionView)

		NSLayoutConstraint.activate([
			navbarView.leftAnchor.constraint(equalTo: view.leftAnchor),
			navbarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			navbarView.rightAnchor.constraint(equalTo: view.rightAnchor),
			navbarView.heightAnchor.constraint(equalToConstant: 44),

			headerActionView.leftAnchor.constraint(equalTo: view.leftAnchor),
			headerActionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			headerActionView.rightAnchor.constraint(equalTo: view.rightAnchor),
			headerActionView.heightAnchor.constraint(equalToConstant: HeaderActionView.viewHeight),

			stack.leftAnchor.constraint(equalTo: view.leftAnchor),
			stack.topAnchor.constraint(equalTo: navbarView.bottomAnchor),
			stack.rightAnchor.constraint(equalTo: view.rightAnchor),
			stack.bottomAnchor.constraint(equalTo: view.bottomAnchor),

			bottomActionView.leftAnchor.constraint(equalTo: view.leftAnchor),
			bottomActionView.rightAnchor.constraint(equalTo: view.rightAnchor),
			bottomActionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: BottomActionView.viewHeight),
			bottomActionView.heightAnchor.constraint(equalToConstant: BottomActionView.viewHeight)
		])
	}
}

// MARK: - Methods
extension RecentImportDetailController {
	private func bindViewModel() {
		viewModel.onSelectFile = { [weak self] index in
			guard let self = self else { return }
			self.updateHeaderActionView()
			self.updateBottomActionView()
			self.fileTbv.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
			self.hightlightBtn.setTitle(self.viewModel.highlightText, for: .normal)
		}

		viewModel.onSelectAllFiles = { [weak self] in
			guard let self = self else { return }
			self.updateHeaderActionView()
			self.updateBottomActionView()
			self.hightlightBtn.setTitle(self.viewModel.highlightText, for: .normal)
			self.fileTbv.reloadData()
		}

		viewModel.onModeChange = { [weak self] in
			guard let self = self else { return }

			let mode = self.viewModel.mode
			let transform = self.bottomActionView.transform
			let translated = transform.translatedBy(x: 0, y: -BottomActionView.viewHeight)
			let condition = mode == .normal

			UIView.animate(withDuration: 0.2) {
				self.headerActionView.alpha = condition ? 0 : 1
				self.bottomActionView.transform = condition ? .identity : translated
				self.fileTbv.contentInset.bottom = condition ? 0 : BottomActionView.viewHeight
				self.hightlightBtn.alpha = condition ? 0 : 1
				self.hightlightBtn.isHidden = condition ? true : false
			}

			self.updateBottomActionView()
			self.headerActionView.changeSelectMode(condition ? .deselect : .select)
			self.hightlightBtn.setTitle(self.viewModel.highlightText, for: .normal)
			self.fileTbv.reloadData()
		}

		viewModel.onNoDataViewChange = { [weak self] in
			guard let self = self else { return }
			let noFiles = self.viewModel.hasNoFiles

			self.navbarView.rightButtons[0].isEnabled = !noFiles
			self.navbarView.rightButtons[0].setTitleColor(noFiles ? .gray : .primaryBlue, for: .normal)
			noFiles ? self.nodataView.fadeIn() : self.nodataView.fadeOut()
		}

		viewModel.checkDataStatus()
	}

	private func updateHeaderActionView() {
		if viewModel.didSelectAll {
			headerActionView.changeSelectMode(.deselect)

		} else {
			headerActionView.changeSelectMode(.select)
		}
	}

	private func updateBottomActionView() {
		if viewModel.didDeselectAll {
			bottomActionView.enableAction([])

		} else {
			bottomActionView.enableAction([.share, .copy, .move, .zip, .delete])
		}
	}

	private func backBtnTapped() {
		self.navigationController?.popViewController(animated: true)
	}
}

// MARK: - UITableViewDataSource
extension RecentImportDetailController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfItems
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: FolderDetailTBCell.cellId,
												 for: indexPath) as! FolderDetailTBCell
		cell.viewModel = viewModel.getCellVM(at: indexPath.row)
		cell.selectionStyle = .none
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if viewModel.mode == .select {
			let _ = viewModel.selectFile(at: indexPath.row)

		} else {
			self.previewDocx(currentPreviewItemIndex: indexPath.item, parentVC: self)
		}
	}
}

// MARK: - QLPreviewControllerDataSource
extension RecentImportDetailController: PreviewItemPresentable, QLPreviewControllerDataSource {
	func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
		return viewModel.numberOfItems
	}

	func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
		let url = viewModel.files[index].absolutePath
		return (url as? NSURL) ?? NSURL()
	}
}

// MARK: - ActionViewDelegate
extension RecentImportDetailController: HeaderActionViewDelegate, BottomActionViewDelegate {
	func didTapCancel(_ view: HeaderActionView) {
		viewModel.toggleMode()
	}

	func didTapSelectAll(_ view: HeaderActionView) {
		viewModel.selectAllFiles()
	}

	func didTapDeselectAll(_ view: HeaderActionView) {
		viewModel.selectAllFiles()
	}

	func didSelectAction(_ action: BottomActionView.ActionType) {
		switch action {
			case .share:
				shareFiles()

			case .copy:
				let fileVM = FileActionSheetViewModel(type: .copy, files: viewModel.selectedFiles, currentFolder: nil)
				let vc = FileActionSheetController(viewModel: fileVM)
				vc.delegate = self
				vc.modalPresentationStyle = .overFullScreen
				self.present(vc, animated: false) {
					vc.showSheet()
				}

			case .move, .zip:
				break

			case .delete:
				deleteFiles()
		}
	}

	private func shareFiles() {
		let objectsToShare: [Any] = viewModel.selectedFiles.compactMap { $0.absolutePath }
		let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
		activityVC.popoverPresentationController?.sourceView = bottomActionView.shareStack
		self.present(activityVC, animated: true, completion: nil)
	}

	private func deleteFiles() {
		let alert = UIAlertController(title: "Delete Files",
									  message: "These files will be permanently deleted in all folders. Are you sure you want to delete these files?",
									  preferredStyle: .alert)

		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] alert in
			guard let self = self else { return }
			let success = self.viewModel.deleteFiles()
			let msg = success ? "Delete file successful" : "Failed to delete file"
			self.view.displayToast(msg)
		}))

		self.present(alert, animated: true)
	}
}

extension RecentImportDetailController: FileActionSheetControllerDelegate {
	func finishModifyFolder(_ controller: FileActionSheetController, actionType: FileActionSheetController.ActionType) {
		viewModel.resetAfterModify(type: actionType)
	}
}
