//
//  FileFolderTBCell.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 31/07/2023.
//

import UIKit

protocol FileFolderTBCellDelegate: AnyObject {
	func didTapCreateFolder(_ cell: FileFolderTBCell)
	func didTapOpenFolder(_ cell: FileFolderTBCell, folder: FolderModel)
	func didTapOpenZipFolder(_ cell: FileFolderTBCell, zipFolder: FolderZipModel)
}

class FileFolderTBCell: UITableViewCell {

	var viewModel: FileFolderTBCellViewModel? {
		didSet {
			guard let viewModel = viewModel else { return }
			folderClv.isScrollEnabled = viewModel.displayMode == .grid
			folderClv.reloadData()
		}
	}

	weak var delegate: FileFolderTBCellDelegate?
	var onSelectOption: ((_ selectedIndex: Int, _ sender: UIButton) -> Void)?

	// MARK: - UI components
	private let folderClv: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		let clv = UICollectionView(frame: .zero, collectionViewLayout: layout)
		clv.translatesAutoresizingMaskIntoConstraints = false
		return clv
	}()

	// MARK: - Init
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupCLView()
		setupConstraints()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupCLView()
		setupConstraints()
	}

	private func setupConstraints() {
		contentView.addSubview(folderClv)
		folderClv.pinToEdges(contentView)
	}

	private func setupCLView() {
		folderClv.isScrollEnabled = true
		folderClv.showsHorizontalScrollIndicator = false
		folderClv.delegate = self
		folderClv.dataSource = self
		folderClv.register(GridFolderCLCell.self, forCellWithReuseIdentifier: GridFolderCLCell.cellId)
		folderClv.register(ListFolderCLCell.self, forCellWithReuseIdentifier: ListFolderCLCell.cellId)
	}

	func unzipFileSuccess() {
		folderClv.scrollToItem(at: IndexPath(row: 2, section: 0), at: .centeredHorizontally, animated: false)
	}
}

// MARK: - UICollectionViewDataSource
extension FileFolderTBCell: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return viewModel?.numberOfItems() ?? 0
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let viewModel = viewModel else { return UICollectionViewCell() }

		switch viewModel.displayMode {
			case .grid:
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridFolderCLCell.cellId,
															  for: indexPath) as! GridFolderCLCell
				cell.viewModel = viewModel.getCellViewModel(index: indexPath.item)

				cell.onSelectOption = { [weak self] sender in
					self?.onSelectOption?(indexPath.item - 2, sender)
				}
				return cell

			case .list:
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListFolderCLCell.cellId,
															  for: indexPath) as! ListFolderCLCell
				cell.viewModel = viewModel.getCellViewModel(index: indexPath.item)

				cell.onSelectOption = { [weak self] sender in
					self?.onSelectOption?(indexPath.item - 2, sender)
				}
				return cell
		}
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if indexPath.item == 0 {
			delegate?.didTapCreateFolder(self)

		} else if indexPath.item == 1 {
			guard let zip = viewModel?.getFolderZipModel() else { return }
			delegate?.didTapOpenZipFolder(self, zipFolder: zip)

		} else {
			guard let folder = viewModel?.getFolderModel(at: indexPath) else { return }
			delegate?.didTapOpenFolder(self, folder: folder)
		}
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FileFolderTBCell: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		guard let displayMode = viewModel?.displayMode else { return .zero }
		if displayMode == .grid {
			return CGSize(width: GridFolderCLCell.cellWidth, height: GridFolderCLCell.cellHeight)
		} else {
			return CGSize(width: collectionView.frame.width, height: ListFolderCLCell.cellHeight)
		}
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return viewModel?.displayMode == .grid ? UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding) : .zero
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return viewModel?.displayMode == .grid ? 40 : 0
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
}

