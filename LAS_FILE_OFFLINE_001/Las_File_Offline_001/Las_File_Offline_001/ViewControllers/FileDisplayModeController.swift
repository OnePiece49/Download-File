//
//  FileDisplayModeController.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 08/08/2023.
//

import UIKit

class FileDisplayModeController: PopoverCustomController {

	//MARK: - Properties
	static let rootViewSize: CGSize = CGSize(width: 258, height: FileDisplayModeTBCell.cellHeight*2)
	var displayMode: FileController.DisplayMode
	private let layouts: [FileController.DisplayMode] = [.grid, .list]
	var onToggleMode: ((_ displayMode: FileController.DisplayMode) -> Void)?

	//MARK: - UIComponent
	private let optionTbv = UITableView()

	override var popoverView: UIView {
		return optionTbv
	}

	//MARK: - View Lifecycle
	init(displayMode: FileController.DisplayMode,
		 popoverSize: CGSize,
		 pointAppear: CGPoint,
		 popoverDirection: PopoverDirection = .botLeft) {
		self.displayMode = displayMode
		super.init(popoverSize: popoverSize, pointAppear: pointAppear, popoverDirection: popoverDirection)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		configureProperties()
	}

	override func configureUI() {
		super.configureUI()
		optionTbv.layer.cornerRadius = 10
		optionTbv.backgroundColor = .white
	}

	private func configureProperties() {
		optionTbv.separatorStyle = .singleLine
		optionTbv.delegate = self
		optionTbv.dataSource = self
		optionTbv.register(FileDisplayModeTBCell.self, forCellReuseIdentifier: FileDisplayModeTBCell.cellId)
		optionTbv.clipsToBounds = true
		optionTbv.isScrollEnabled = false
	}
}

// MARK: - UITableViewDataSource
extension FileDisplayModeController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return layouts.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: FileDisplayModeTBCell.cellId,
												 for: indexPath) as! FileDisplayModeTBCell
		cell.displayMode = layouts[indexPath.row]

		if cell.displayMode == displayMode {
			cell.hasSelected = true
		}
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		onToggleMode?(layouts[indexPath.row])
		self.animationDismiss()
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return FileDisplayModeTBCell.cellHeight
	}
}
