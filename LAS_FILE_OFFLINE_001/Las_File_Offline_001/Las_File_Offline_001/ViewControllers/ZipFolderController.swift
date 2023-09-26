//
//  ZipFolderController.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 07/08/2023.
//

import UIKit

class ZipFolderController: BaseController {

	var viewModel: ZipFolderViewModel

	// MARK: - UI components
	private var navbarView: NavigationCustomView!

	private let nodataView: FolderNoDataView = {
		let view = FolderNoDataView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		view.isUserInteractionEnabled = false
		return view
	}()

	private let zipFileTbv: UITableView = {
		let tbv = UITableView()
		tbv.translatesAutoresizingMaskIntoConstraints = false
		return tbv
	}()

	// MARK: - Lifecycle
	init(viewModel: ZipFolderViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavbar()
		setupTBView()
		setupConstraints()
		bindViewModel()
	}

	private func setupNavbar() {
		let firstAtrLeft = AttibutesButton(tilte: "Back", font: .fontGilroySemi(16), titleColor: .primaryBlue) { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		navbarView = NavigationCustomView(centerTitle: "Zip Files",
										  centertitleFont: .fontGilroyBold(22)!,
										  attributeLeftButtons: [firstAtrLeft],
										  attributeRightBarButtons: [],
										  beginSpaceLeftButton: 20)
		navbarView.translatesAutoresizingMaskIntoConstraints = false
		navbarView.backgroundColor = .white
	}

	private func setupTBView() {
		zipFileTbv.rowHeight = ZipFolderTBCell.cellHeight
		zipFileTbv.separatorStyle = .none
		zipFileTbv.delegate = self
		zipFileTbv.dataSource = self
		zipFileTbv.register(ZipFolderTBCell.self, forCellReuseIdentifier: ZipFolderTBCell.cellId)
	}

	private func setupConstraints() {
		view.addSubview(navbarView)
		view.addSubview(zipFileTbv)
		view.addSubview(nodataView)

		nodataView.pinToEdges(view)

		NSLayoutConstraint.activate([
			navbarView.leftAnchor.constraint(equalTo: view.leftAnchor),
			navbarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			navbarView.rightAnchor.constraint(equalTo: view.rightAnchor),
			navbarView.heightAnchor.constraint(equalToConstant: 44),

			zipFileTbv.leftAnchor.constraint(equalTo: view.leftAnchor),
			zipFileTbv.topAnchor.constraint(equalTo: navbarView.bottomAnchor),
			zipFileTbv.rightAnchor.constraint(equalTo: view.rightAnchor),
			zipFileTbv.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])
	}

	private func bindViewModel() {
		viewModel.onDeleteZipFile = { [weak self] in
			guard let self = self else { return }
			self.viewModel.shouldHideNoData ? self.nodataView.fadeOut() : self.nodataView.fadeIn()
			self.zipFileTbv.reloadData()
		}

		viewModel.shouldHideNoData ? nodataView.fadeOut() : nodataView.fadeIn()
	}
}

// MARK: - UITableViewDataSource
extension ZipFolderController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfItems
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: ZipFolderTBCell.cellId,
												 for: indexPath) as! ZipFolderTBCell
		cell.viewModel = ZipFolderTBCellViewModel(zipFile: viewModel.zipFiles[indexPath.row])
		cell.selectionStyle = .none
		return cell
	}

	func tableView(_ tableView: UITableView,
				   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		if viewModel.numberOfItems == 0 { return nil }

		guard let cell = tableView.cellForRow(at: indexPath) as? ZipFolderTBCell else { return nil }

		let deleteAction = UIContextualAction(style: .destructive,
											  title: nil) { [weak self] (_, _, completion) in
			self?.deleteZipFile(at: indexPath)
			completion(true)
		}
		deleteAction.backgroundColor = .red
		deleteAction.image = UIImage(named: AssetConstant.ic_delete)

		let moreAction = UIContextualAction(style: .destructive,
											title: nil) { [weak self] (_, _, completion) in
			self?.moreAction(cell: cell, indexpath: indexPath)
			completion(true)
		}
		moreAction.backgroundColor = UIColor(rgb: 0xDEDEDE)
		moreAction.image = UIImage(named: AssetConstant.ic_more)

		let config = UISwipeActionsConfiguration(actions: [deleteAction, moreAction])
		return config
	}

	private func moreAction(cell: ZipFolderTBCell, indexpath: IndexPath) {
		let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		let shareAction = UIAlertAction(title: "Share", style: .default) { [weak self] _ in
			self?.shareAction(cell: cell)
		}
		let unzipAction = UIAlertAction(title: "Unzip", style: .default) { [weak self] _ in
			self?.unzipAction(indexPath: indexpath)
		}
		let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
			self?.deleteZipFile(at: indexpath)
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

		sheet.addAction(shareAction)
		sheet.addAction(unzipAction) 	
		sheet.addAction(deleteAction)
		sheet.addAction(cancelAction)

		sheet.popoverPresentationController?.sourceView = cell
		self.present(sheet, animated: true)
	}

	private func shareAction(cell: ZipFolderTBCell) {
		let objectsToShare: [Any] = [cell.viewModel?.zipfileURL as Any]
		let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
		activityVC.popoverPresentationController?.sourceView = self.view
		self.present(activityVC, animated: true, completion: nil)
	}

	private func unzipAction(indexPath: IndexPath) {
		let success = viewModel.unzipFile(at: indexPath.row)
		let msg = success ? "Unzip file success" : "Unzip file failed"
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			self.view.displayToast(msg)
			self.navigationController?.popViewController(animated: true)

			guard let navi = UIWindow.keyWindow?.rootViewController as? UINavigationController,
				  let tabbar = navi.viewControllers.first as? TabBarController,
				  let fileVC = tabbar.viewControllers?[1] as? FileController else { return }
			fileVC.unzipFileSuccess()
		}
	}

	private func deleteZipFile(at indexPath: IndexPath) {
		let alert = UIAlertController(title: "Delete File",
									  message: "This file will be permanently deleted. Are you sure you want to delete this file?",
									  preferredStyle: .alert)

		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] alert in
			guard let self = self else { return }
			let success = self.viewModel.deleteZipFile(at: indexPath.row)
			let msg = success ? "Delete file successful" : "Failed to delete file"
			self.view.displayToast(msg)
		}))

		self.present(alert, animated: true)
	}
}
