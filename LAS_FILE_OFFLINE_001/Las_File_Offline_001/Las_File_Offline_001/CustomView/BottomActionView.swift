//
//  BottomActionView.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 03/08/2023.
//

import UIKit

extension BottomActionView {
	enum ActionType: Int, CaseIterable {
		case share, copy, move, zip, delete

		var title: String {
			switch self {
				case .share: return "Share"
				case .copy: return "Copy"
				case .move: return "Move"
				case .zip: return "Zip"
				case .delete: return "Delete"
			}
		}

		var imgName: String {
			switch self {
				case .share: return AssetConstant.ic_share_black
				case .copy: return AssetConstant.ic_copy
				case .move: return AssetConstant.ic_move
				case .zip: return AssetConstant.ic_zip_small
				case .delete: return AssetConstant.ic_delete_black
			}
		}
	}
}

protocol BottomActionViewDelegate: AnyObject {
	func didSelectAction(_ action: BottomActionView.ActionType)
}

class BottomActionView: UIView {

	static let viewHeight: CGFloat = 81

	weak var delegate: BottomActionViewDelegate?

	private var btnArray: [UIButton] {
		return [shareBtn, copyBtn, moveBtn, zipBtn, deleteBtn]
	}

	private var stackArray: [UIStackView] {
		return [shareStack, copyStack, moveStack, zipStack, deleteStack]
	}

	// MARK: - Public
	var allowAction: [BottomActionView.ActionType] = ActionType.allCases {
		didSet {
			let numbers = allowAction.map { $0.rawValue }
			let stackArray = [shareStack, copyStack, moveStack, zipStack, deleteStack]

			for stack in stackArray {
				if !numbers.contains(stack.tag) {
					stack.isHidden = true
				}
			}
		}
	}

	func enableAction(_ actions: [ActionType]) {
		let numbers = actions.map { $0.rawValue }

		for (index, btn) in btnArray.enumerated() {
			if numbers.contains(btn.tag) {
				enableBtn(btn, stack: stackArray[index])
			} else {
				disableBtn(btn, stack: stackArray[index])
			}
		}
	}

	// MARK: - UI components
	private lazy var shareBtn: UIButton = createBtn(type: .share)
	private lazy var copyBtn: UIButton = createBtn(type: .copy)
	private lazy var moveBtn: UIButton = createBtn(type: .move)
	private lazy var zipBtn: UIButton = createBtn(type: .zip)
	private lazy var deleteBtn: UIButton = createBtn(type: .delete)

	private lazy var shareLbl: UILabel = createLbl(type: .share)
	private lazy var copyLbl: UILabel = createLbl(type: .copy)
	private lazy var moveLbl: UILabel = createLbl(type: .move)
	private lazy var zipLbl: UILabel = createLbl(type: .zip)
	private lazy var deleteLbl: UILabel = createLbl(type: .delete)

	lazy var shareStack: UIStackView = createStack(btn: shareBtn, lbl: shareLbl, type: .share)
	private lazy var copyStack: UIStackView = createStack(btn: copyBtn, lbl: copyLbl, type: .copy)
	private lazy var moveStack: UIStackView = createStack(btn: moveBtn, lbl: moveLbl, type: .move)
	private lazy var zipStack: UIStackView = createStack(btn: zipBtn, lbl: zipLbl, type: .zip)
	private lazy var deleteStack: UIStackView = createStack(btn: deleteBtn, lbl: deleteLbl, type: .delete)

	// MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
		setupConstraints()
		dropShadow()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupConstraints() {
		let finalStack = UIStackView(arrangedSubviews: [shareStack, copyStack, moveStack, zipStack, deleteStack])
		finalStack.distribution = .equalCentering
		finalStack.translatesAutoresizingMaskIntoConstraints = false

		addSubview(finalStack)

		NSLayoutConstraint.activate([
			finalStack.leftAnchor.constraint(equalTo: leftAnchor, constant: 30),
			finalStack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
			finalStack.rightAnchor.constraint(equalTo: rightAnchor, constant: -30),
			finalStack.heightAnchor.constraint(equalToConstant: 60)
		])
	}

	// MARK: - Methods
	private func createBtn(type: ActionType) -> UIButton {
		let btn = UIButton(type: .system)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.tag = type.rawValue
		btn.setImage(UIImage(named: type.imgName)?.withRenderingMode(.alwaysOriginal), for: .normal)
		btn.addTarget(self, action: #selector(actionBtnTapped(_:)), for: .touchUpInside)
		btn.setDimensions(width: 32, height: 32)
		return btn
	}

	private func createLbl(type: ActionType) -> UILabel {
		let lbl = UILabel()
		lbl.translatesAutoresizingMaskIntoConstraints = false
		lbl.text = type.title
		lbl.textColor = .black
		lbl.font = .fontGilroySemi(12)
		lbl.setContentHuggingPriority(.defaultLow + 1, for: .vertical)
		lbl.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
		return lbl
	}

	private func createStack(btn: UIButton, lbl: UILabel, type: ActionType) -> UIStackView {
		let stack = UIStackView(arrangedSubviews: [btn, lbl])
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .vertical
		stack.spacing = -4
		stack.alignment = .center
		stack.tag = type.rawValue
		return stack
	}

	@objc private func actionBtnTapped(_ sender: UIButton) {
		guard let action = ActionType(rawValue: sender.tag) else { return }
		delegate?.didSelectAction(action)
	}

	private func disableBtn(_ btn: UIButton, stack: UIStackView) {
		stack.alpha = 0.2
		btn.isEnabled = false
	}

	private func enableBtn(_ btn: UIButton, stack: UIStackView) {
		stack.alpha = 1
		btn.isEnabled = true
	}
}
