//
//  HeaderActionView.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 03/08/2023.
//

import UIKit

protocol HeaderActionViewDelegate: AnyObject {
	func didTapCancel(_ view: HeaderActionView)
	func didTapSelectAll(_ view: HeaderActionView)
	func didTapDeselectAll(_ view: HeaderActionView)
}

class HeaderActionView: UIView {

	enum SelectMode {
		case select, deselect

		var title: String {
			switch self {
				case .select: return "Select All"
				case .deselect: return "Deselect All"
			}
		}
	}

	static let viewHeight: CGFloat = 44

	weak var delegate: HeaderActionViewDelegate?

	private var selectMode: SelectMode = .select

	// MARK: - UI components
	private lazy var cancelBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.setTitle("Cancel", for: .normal)
		btn.setTitleColor(.primaryBlue, for: .normal)
		btn.titleLabel?.font = .fontGilroySemi(16)
		btn.addTarget(self, action: #selector(cancelBtnTapped), for: .touchUpInside)
		return btn
	}()

	private lazy var selectAllBtn: UIButton = {
		let btn = UIButton(type: .custom)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.setTitle("Select All", for: .normal)
		btn.setTitleColor(.primaryBlue, for: .normal)
		btn.titleLabel?.font = .fontGilroySemi(16)
		btn.addTarget(self, action: #selector(selectAllBtnTapped), for: .touchUpInside)
		return btn
	}()

	// MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
		setupConstraints()
		selectMode = .select
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupConstraints() {
		addSubview(cancelBtn)
		addSubview(selectAllBtn)

		NSLayoutConstraint.activate([
			cancelBtn.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
			cancelBtn.topAnchor.constraint(equalTo: topAnchor),
			cancelBtn.bottomAnchor.constraint(equalTo: bottomAnchor),

			selectAllBtn.topAnchor.constraint(equalTo: topAnchor),
			selectAllBtn.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
			selectAllBtn.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}

	// MARK: - Methods
	func changeSelectMode(_ mode: SelectMode) {
		self.selectMode = mode
		self.selectAllBtn.setTitle(selectMode.title, for: .normal)
	}

	@objc private func cancelBtnTapped() {
		delegate?.didTapCancel(self)
	}

	@objc private func selectAllBtnTapped() {
		switch selectMode {
			case .select:
				delegate?.didTapSelectAll(self)
				selectMode = .deselect
			case .deselect:
				delegate?.didTapDeselectAll(self)
				selectMode = .select
		}
	}
}
