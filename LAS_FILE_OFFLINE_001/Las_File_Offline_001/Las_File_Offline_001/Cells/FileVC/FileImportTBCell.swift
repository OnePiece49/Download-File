//
//  FileImportTBCell.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 31/07/2023.
//

import UIKit

struct FileImportTBCellViewModel {

	var title: String {
		return type.title
	}

	var numberOfItems: Int {
		return files.count
	}

	var shouldHideNoData: Bool {
		return numberOfItems != 0
	}

	var shouldHideSeeMore: Bool {
		return numberOfItems == 0
	}

	func getFileModel(at indexPath: IndexPath) -> FileModel {
		return files[indexPath.item]
	}

	var files: [FileModel]
	var type: FileController.HomeType
	var displayMode: FileController.DisplayMode

	init(files: [FileModel], type: FileController.HomeType, displayMode: FileController.DisplayMode) {
		self.files = files
		self.type = type
		self.displayMode = displayMode
	}
}

protocol FileImportTBCellDelegate: AnyObject {
	func didSelectFile(_ cell: FileImportTBCell, at index: Int, file: FileModel)
	func didSelectSeeMore(_ cell: FileImportTBCell)
}

class FileImportTBCell: UITableViewCell {

	static let headerHeight: CGFloat = 50.5

	var viewModel: FileImportTBCellViewModel? {
		didSet {
			titleLbl.text = viewModel?.title
			seeMoreBtn.isHidden = viewModel?.shouldHideSeeMore ?? false
			nodataView.isHidden = viewModel?.shouldHideNoData ?? true
			fileClv.reloadData()
		}
	}

	weak var delegate: FileImportTBCellDelegate?

	// MARK: - UI components
	private let nodataView: FolderNoDataView = {
		let view = FolderNoDataView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = false
		view.isUserInteractionEnabled = false
		return view
	}()

	private let headerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let titleLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 1
		label.font = UIFont.fontGilroyBold(19)
		label.textColor = UIColor.black
		return label
	}()

	private lazy var seeMoreBtn: UIButton = {
		let btn = UIButton(type: .custom)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.titleLabel?.font = .fontGilroySemi(16)
		btn.setTitleColor(.black, for: .normal)
		btn.setTitle("See More", for: .normal)
		btn.setImage(UIImage(named: AssetConstant.ic_see_all), for: .normal)
		btn.semanticContentAttribute = .forceRightToLeft
		btn.titleEdgeInsets.left = -10
		btn.addTarget(self, action: #selector(seeMoreBtnTapped), for: .touchUpInside)
		return btn
	}()

	private let fileClv: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
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
		headerView.addSubview(titleLbl)
		headerView.addSubview(seeMoreBtn)
		contentView.addSubview(headerView)
		contentView.addSubview(fileClv)
		contentView.addSubview(nodataView)

		NSLayoutConstraint.activate([
			headerView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
			headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
			headerView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
			headerView.heightAnchor.constraint(equalToConstant: FileImportTBCell.headerHeight),

			titleLbl.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 20),
			titleLbl.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

			seeMoreBtn.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -12),
			seeMoreBtn.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
			seeMoreBtn.heightAnchor.constraint(equalToConstant: 36),

			nodataView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
			nodataView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
			nodataView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
			nodataView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

			fileClv.leftAnchor.constraint(equalTo: contentView.leftAnchor),
			fileClv.topAnchor.constraint(equalTo: headerView.bottomAnchor),
			fileClv.rightAnchor.constraint(equalTo: contentView.rightAnchor),
			fileClv.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
		])
	}

	private func setupCLView() {
		fileClv.isScrollEnabled = false
		fileClv.delegate = self
		fileClv.dataSource = self
		fileClv.register(GridImportCLCell.self, forCellWithReuseIdentifier: GridImportCLCell.cellId)
		fileClv.register(ListImportCLCell.self, forCellWithReuseIdentifier: ListImportCLCell.cellId)
	}

	@objc private func seeMoreBtnTapped() {
		delegate?.didSelectSeeMore(self)
	}
}

// MARK: - UICollectionViewDataSource
extension FileImportTBCell: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return viewModel?.numberOfItems ?? 0
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let viewModel = viewModel else { return UICollectionViewCell() }

		switch viewModel.displayMode {
			case .grid:
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridImportCLCell.cellId,
															  for: indexPath) as! GridImportCLCell
				let file = viewModel.getFileModel(at: indexPath)
				cell.viewModel = ImportCLCellViewModel(file: file)
				return cell
			case .list:
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListImportCLCell.cellId,
															  for: indexPath) as! ListImportCLCell
				let file = viewModel.getFileModel(at: indexPath)
				cell.viewModel = ImportCLCellViewModel(file: file)
				return cell
		}
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let file = viewModel?.getFileModel(at: indexPath) else { return }
		delegate?.didSelectFile(self, at: indexPath.item, file: file)
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FileImportTBCell: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		guard let displayMode = viewModel?.displayMode else { return .zero }
		if displayMode == .grid {
			return CGSize(width: GridImportCLCell.cellWidth, height: GridImportCLCell.cellHeight)
		} else {
			return CGSize(width: collectionView.frame.width, height: ListImportCLCell.cellHeight)
		}
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return viewModel?.displayMode == .grid ? UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding) : .zero
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		let spacing: CGFloat = (UIScreen.main.bounds.width - padding*2 - GridImportCLCell.cellWidth*columns) / (columns - 1)
		return viewModel?.displayMode == .grid ? spacing : 0
	}
}
