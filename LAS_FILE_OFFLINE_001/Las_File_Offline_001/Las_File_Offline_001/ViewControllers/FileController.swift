//
//  ViewController.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 28/07/2023.
//

import UIKit
import PhotosUI
import MobileCoreServices
import QuickLook

extension FileController {

	enum HomeType {
		case folder
		case recentImport

		var title: String {
			switch self {
				case .folder: return ""
				case .recentImport: return "Recent Imports"
			}
		}
	}

	enum DisplayMode: CaseIterable {
		case grid
		case list

		var title: String {
			switch self {
				case .grid: return "Grid"
				case .list: return "List"
			}
		}

		var iconName: String {
			switch self {
				case .grid: return AssetConstant.ic_grid_mode
				case .list: return AssetConstant.ic_list_mode
			}
		}
	}

}

class FileController: BaseController {

	// MARK: - Properties
	private let layouts: [HomeType] = [.folder, .recentImport]
	private let viewModel = FileViewModel()

	// MARK: - UIComponent
	private var navbarView: NavigationCustomView!

	private let fileTbv: UITableView = {
		let tbv = UITableView()
		tbv.translatesAutoresizingMaskIntoConstraints = false
		return tbv
	}()

	// MARK: - View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavbar()
		setupTBView()
		setupConstraints()
		bindViewModel()
		print(URL.document())
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		viewModel.loadData()
	}

	private func setupConstraints() {
		view.addSubview(navbarView)
		view.addSubview(fileTbv)

		NSLayoutConstraint.activate([
			navbarView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
			navbarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			navbarView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
			navbarView.heightAnchor.constraint(equalToConstant: 44),

			fileTbv.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
			fileTbv.topAnchor.constraint(equalTo: navbarView.bottomAnchor),
			fileTbv.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
			fileTbv.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}

	private func setupTBView() {
		fileTbv.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
		fileTbv.delegate = self
		fileTbv.dataSource = self
		fileTbv.register(FileFolderTBCell.self, forCellReuseIdentifier: FileFolderTBCell.cellId)
		fileTbv.register(FileImportTBCell.self, forCellReuseIdentifier: FileImportTBCell.cellId)
	}

	private func setupNavbar() {
		let firstAtrLeft = AttibutesButton(tilte: "Files",
										   font: .fontGilroyBold(32),
										   titleColor: .black)

		let firstAtrRight = AttibutesButton(image: UIImage(named: AssetConstant.ic_option)?.withRenderingMode(.alwaysOriginal),
											sizeImage: CGSize(width: 30, height: 30)) { [weak self] in
			self?.didTapMoreBtn()
		}
		let secondAtrRight = AttibutesButton(image: UIImage(named: AssetConstant.ic_plus_file)?.withRenderingMode(.alwaysOriginal),
											 sizeImage: CGSize(width: 50, height: 30)) { [weak self] in
			self?.didTapAddFile()
		}

		navbarView = NavigationCustomView(attributeLeftButtons: [firstAtrLeft],
										  attributeRightBarButtons: [firstAtrRight, secondAtrRight],
										  beginSpaceLeftButton: 20,
										  beginSpaceRightButton: 18, continueSpaceRight: 20)
		navbarView.translatesAutoresizingMaskIntoConstraints = false
		navbarView.backgroundColor = .white
	}
}

// MARK: - Method
extension FileController {
	func openZipFolder() {
		guard let zipFolder = viewModel.zipFolder else { return }
		let zipVM = ZipFolderViewModel(zipFolder: zipFolder)
		let vc = ZipFolderController(viewModel: zipVM)
		self.navigationController?.pushViewController(vc, animated: true)
	}

	func unzipFileSuccess() {
		guard let cell = fileTbv.cellForRow(at: IndexPath(row: 0, section: 0)) as? FileFolderTBCell else { return }
		cell.unzipFileSuccess()
	}

	private func bindViewModel() {
		viewModel.onLoadDataSuccess = { [weak self] in
			self?.fileTbv.reloadData()
		}

		viewModel.onChangeDisplayMode = { [weak self] in
			self?.fileTbv.reloadData()
		}

		viewModel.onCreateFolder = { [weak self] in
			self?.fileTbv.reloadData()
		}

		viewModel.onDeleteFolder = { [weak self] in
			self?.fileTbv.reloadData()
		}

		viewModel.onRenameFolder = { [weak self] in
			self?.fileTbv.reloadData()
		}

		viewModel.onRecentFilesChange = { [weak self] in
			let indexPath = IndexPath(item: 1, section: 0)
			self?.fileTbv.reloadRows(at: [indexPath], with: .none)
		}
	}

	private func didTapMoreBtn() {
		let point = self.navbarView.rightButtons[0].convert(self.navbarView.rightButtons[0].bounds.origin, to: self.view)
		let vc = FileDisplayModeController(displayMode: viewModel.displayMode,
										   popoverSize: FileDisplayModeController.rootViewSize,
										   pointAppear: CGPoint(x: point.x + 30, y: point.y + 30))
		vc.modalPresentationStyle = .overFullScreen

		vc.onToggleMode = { [weak self] mode in
			self?.viewModel.toggleDisplayMode(mode)
		}

		self.present(vc, animated: false)
	}

	private func didTapAddFile() {
		let vc = ImportFileSheetController()
		vc.delegate = self
		vc.modalPresentationStyle = .overFullScreen
		self.present(vc, animated: false) {
			vc.showSheet()
		}
	}

	private func saveFileToDocument(url: URL, loadingView: LoadingAnimationView) {
		let filename = url.lastPathComponent
		guard let urlSave = URL.importFolder()?.appendingPathComponent(filename) else { return }

		if FileManager.default.fileExists(atPath: urlSave.path) {
			DispatchQueue.main.async {
				self.view.displayToast("Failed to import: File exists")
				loadingView.dismiss()
			}
			return
		}

		do {
			try FileManager.default.copyItem(at: url, to: urlSave)

			DispatchQueue.main.async {
				let success = self.viewModel.saveFileToDB(with: urlSave)
				let msg = success ? "Import file successfully" : "Failed to import: File exists"
				self.view.displayToast(msg)
				loadingView.dismiss()
			}

		} catch {
			print("DEBUG: \(#function) - error: \(error)")
			DispatchQueue.main.async {
				self.view.displayToast("Failed to import: File exists")
				loadingView.dismiss()
			}
		}
	}
}

// MARK: - UITableViewDelegate
extension FileController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return layouts.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch layouts[indexPath.row] {
			case .folder:
				let cell = tableView.dequeueReusableCell(withIdentifier: FileFolderTBCell.cellId,
														 for: indexPath) as! FileFolderTBCell
				cell.delegate = self
				cell.viewModel = FileFolderTBCellViewModel(folders: viewModel.userCreatedFolders,
														   zipFolder: viewModel.zipFolder,
														   displayMode: viewModel.displayMode)
				cell.selectionStyle = .none

				cell.onSelectOption = { [weak self] selectedIndex, sender in
					self?.openFolderOption(index: selectedIndex, sender: sender)
				}
				return cell

			case .recentImport:
				let cell = tableView.dequeueReusableCell(withIdentifier: FileImportTBCell.cellId,
														 for: indexPath) as! FileImportTBCell
				cell.delegate = self
				cell.viewModel = FileImportTBCellViewModel(files: viewModel.recentFiles,
														   type: layouts[indexPath.row],
														   displayMode: viewModel.displayMode)
				cell.selectionStyle = .none
				return cell
		}
	}

	private func openFolderOption(index: Int, sender: UIButton) {
		let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
			self?.deleteFolder(at: index, sender: sender)
		}
		let renameAction = UIAlertAction(title: "Rename", style: .default) { [weak self] _ in
			self?.renameFolder(at: index)
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

		sheet.addAction(deleteAction)
		sheet.addAction(renameAction)
		sheet.addAction(cancelAction)

		sheet.popoverPresentationController?.sourceView = sender
		self.present(sheet, animated: true)
	}

	private func deleteFolder(at index: Int, sender: UIButton) {
		let sheet = UIAlertController(title: nil,
									  message: "Are you sure you want to delete this folder?",
									  preferredStyle: .alert)

		let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
			guard let self = self else { return }
			let success = self.viewModel.deleteFolder(at: index)
			let msg = success ? "Delete folder successful" : "Failed to delete folder"
			self.view.displayToast(msg)
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

		sheet.addAction(deleteAction)
		sheet.addAction(cancelAction)
		self.present(sheet, animated: true)
	}

	private func renameFolder(at index: Int) {
		let alert = UIAlertController(title: "New name",
									  message: nil,
									  preferredStyle: .alert)

		alert.addTextField()
		alert.textFields?.first?.placeholder = "Enter name"

		let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
			guard let self = self else { return }

			let text = alert.textFields?.first?.text

			guard let text = text, text.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
				self.view.displayToast("Folder's name is invalide")
				return
			}

			let success = self.viewModel.renameFolder(at: index, name: text)
			let msg = success ? "Rename folder successful" : "Folder's name already existed"
			self.view.displayToast(msg)
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

		alert.addAction(saveAction)
		alert.addAction(cancelAction)
		self.present(alert, animated: true)
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let layout = layouts[indexPath.row]

		switch layout {
			case .folder:
				return viewModel.estimateRowHeight(of: layout)
			case .recentImport:
				return viewModel.estimateRowHeight(of: layout) + FileImportTBCell.headerHeight
		}
	}
}

// MARK: - ImportFileSheetControllerDelegate
extension FileController: ImportFileSheetControllerDelegate {
	func didSelectCameraRoll(_ controller: ImportFileSheetController) {
		if #available(iOS 14, *) {
			self.openPhotosApp()
		} else {
			self.openPhotoLibary()
		}
	}

	func didSelectFileBrowser(_ controller: ImportFileSheetController) {
		self.openDocumentPicker()
	}
}

// MARK: - PHPickerViewControllerDelegate
@available(iOS 14.0, *)
extension FileController: PHPickerViewControllerDelegate {
	private func openPhotosApp() {
		var config = PHPickerConfiguration()
		config.selectionLimit = 1
		config.filter = .any(of: [.images, .videos])

		let picker = PHPickerViewController(configuration: config)
		picker.delegate = self
		self.present(picker, animated: true)
	}

	func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
		picker.dismiss(animated: true)

		guard let result = results.first else { return }
		let prov = result.itemProvider
		let imageType = UTType.image.identifier
		let videoType = UTType.movie.identifier

		let loadingView = LoadingAnimationView()
		loadingView.setMessage("Importing file...")
		loadingView.show()

		prov.loadFileRepresentation(forTypeIdentifier: imageType) { [weak self] url, error in
			if let url = url {
				self?.saveFileToDocument(url: url, loadingView: loadingView)

			} else {
				prov.loadFileRepresentation(forTypeIdentifier: videoType) { url, error in
					if let url = url {
						self?.saveFileToDocument(url: url, loadingView: loadingView)

					} else {
						DispatchQueue.main.async { self?.view.displayToast("Failed to import file") }
					}
				}
			}
		}
	}
}

// MARK: - UIImagePickerControllerDelegate
extension FileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	private func openPhotoLibary() {
		let localUIPicker = UIImagePickerController()
		localUIPicker.delegate = self
		localUIPicker.allowsEditing = false
		localUIPicker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]

		if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
			localUIPicker.sourceType = UIImagePickerController.SourceType.photoLibrary
			self.present(localUIPicker, animated: true)
		}
	}

	func imagePickerController(_ picker: UIImagePickerController,
							   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		var outputURL: URL?

		if let imageURL = info[.imageURL] as? URL {
			outputURL = imageURL
		} else if let videoURL = info[.mediaURL] as? URL {
			outputURL = videoURL
		}

		guard let outputURL = outputURL else {
			view.displayToast("Failed to import file")
			return
		}

		let loadingView = LoadingAnimationView()
		loadingView.setMessage("Importing file...")
		loadingView.show()

		self.saveFileToDocument(url: outputURL, loadingView: loadingView)
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		self.dismiss(animated: true)
	}
}

// MARK: - UIDocumentPickerDelegate
extension FileController: UIDocumentPickerDelegate {
	private func openDocumentPicker() {
		let documentPicker: UIDocumentPickerViewController

		if #available(iOS 14.0, *) {
			let supportedTypes: [UTType] = [.image, .audiovisualContent, .text,
											.pdf, .spreadsheet, .content]
			documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)

		} else {
			let documentTypes: [String] = [
				kUTTypeImage,
				kUTTypeAudiovisualContent,
				kUTTypeText,
				kUTTypePDF,
				kUTTypeSpreadsheet,
				kUTTypeContent // retrieve docx
			].map { String($0) }
			documentPicker = UIDocumentPickerViewController(documentTypes: documentTypes, in: .import)
		}
		documentPicker.delegate = self
		documentPicker.allowsMultipleSelection = false
		self.present(documentPicker, animated: true, completion: nil)
	}

	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		guard let url = urls.first else { return }

		let loadingView = LoadingAnimationView()
		loadingView.setMessage("Importing file...")
		loadingView.show()

		self.saveFileToDocument(url: url, loadingView: loadingView)
	}

	func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
		self.dismiss(animated: true)
	}
}

// MARK: - FileFolderTBCellDelegate, FileImportTBCellDelegate
extension FileController: FileFolderTBCellDelegate, TextFieldSheetControllerDelegate, FileImportTBCellDelegate {
	func didTapCreateFolder(_ cell: FileFolderTBCell) {
		let vc = TextFieldSheetController(option: .newFolder)
		vc.delegate = self
		vc.modalPresentationStyle = .overFullScreen
		self.present(vc, animated: false)
	}

	func didTapDone(withText text: String, option: TextFieldSheetController.Option, sender: UITextField, _ vc: TextFieldSheetController) {
		vc.removeSheet { [weak self] in
			guard let self = self, option == .newFolder else { return }
			let success = self.viewModel.createFolder(name: text)
			if success {
				self.view.displayToast("Create new folder success")
			} else {
				self.view.displayToast("Failed to create new folder")
			}
		}
	}

	func didTapOpenFolder(_ cell: FileFolderTBCell, folder: FolderModel) {
		let folderVM = FolderDetailViewModel(folder: folder)
		let vc = FolderDetailController(viewModel: folderVM)
		self.navigationController?.pushViewController(vc, animated: true)
	}

	func didTapOpenZipFolder(_ cell: FileFolderTBCell, zipFolder: FolderZipModel) {
		let zipVM = ZipFolderViewModel(zipFolder: zipFolder)
		let vc = ZipFolderController(viewModel: zipVM)
		self.navigationController?.pushViewController(vc, animated: true)
	}

	func didSelectFile(_ cell: FileImportTBCell, at index: Int, file: FileModel) {
		self.previewDocx(currentPreviewItemIndex: index, parentVC: self)
	}

	func didSelectSeeMore(_ cell: FileImportTBCell) {
		let folderVM = RecentImportDetailViewModel(files: viewModel.allFiles)
		let vc = RecentImportDetailController(viewModel: folderVM)
		navigationController?.pushViewController(vc, animated: true)
	}
}

// MARK: - QLPreviewControllerDataSource, PreviewItemPresentable
extension FileController: PreviewItemPresentable, QLPreviewControllerDataSource {
	func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
		return viewModel.recentFiles.count
	}

	func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
		let file = viewModel.recentFiles[index]
		return (file.absolutePath as? NSURL) ?? NSURL()
	}
}

