//
//  TextFieldSheetController.swift
//  FileManagerLearning
//
//  Created by Đức Anh Trần on 29/07/2023.
//

import UIKit

protocol TextFieldSheetControllerDelegate: AnyObject {
    func didTapDone(withText text: String, option: TextFieldSheetController.Option, sender: UITextField, _ vc: TextFieldSheetController)
}

class TextFieldSheetController: BottomSheetViewController {

	// MARK: - Properties
	weak var delegate: TextFieldSheetControllerDelegate?
	private let option: Option

	override var rootView: UIView {
		return containerView
	}

	override var sheetHeight: BottomSheetHeight {
		return .fixed(270)
	}

	// MARK: - UI components
	private let containerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .white
		return view
	}()

	private let iconImv: UIImageView = {
		let imv = UIImageView()
		imv.translatesAutoresizingMaskIntoConstraints = false
		imv.contentMode = .scaleAspectFill
		imv.image = UIImage(named: AssetConstant.ic_zip_blue)
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

	let primaryTxf: UITextField = {
		let txf = UITextField()
		txf.translatesAutoresizingMaskIntoConstraints = false
		txf.font = .fontGilroyBold(20)
		txf.textAlignment = .center
		txf.textColor = .black
		return txf
	}()

	private let separatorView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .primaryBlue
		return view
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

	private lazy var doneBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.titleLabel?.font = .fontGilroyBold(16)
		btn.setTitleColor(.white, for: .normal)
		btn.backgroundColor = UIColor(rgb: 0xADADAD)
		btn.isEnabled = false
		btn.layer.cornerRadius = 21
		btn.addTarget(self, action: #selector(doneBtnTapped), for: .touchUpInside)
		return btn
	}()

	// MARK: - Lifecycle
	init(option: Option) {
		self.option = option
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
        print("DEBUG: textfield VC deinit")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		configureUI()
		NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(_:)),
											   name: UITextField.textDidChangeNotification, object: primaryTxf)
		NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(_:)),
											   name: UIResponder.keyboardWillShowNotification, object: nil)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		primaryTxf.becomeFirstResponder()
	}

	override func setupConstraints() {
		super.setupConstraints()
		containerView.addSubview(iconImv)
		containerView.addSubview(titleLbl)
		containerView.addSubview(primaryTxf)
		containerView.addSubview(separatorView)
		containerView.addSubview(cancelBtn)
		containerView.addSubview(doneBtn)

		let doneBtnWidth: CGFloat = option == .downloadURL ? 140 : 110

		NSLayoutConstraint.activate([
			iconImv.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16),
			iconImv.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
			iconImv.widthAnchor.constraint(equalToConstant: 27),
			iconImv.heightAnchor.constraint(equalToConstant: 32),

			titleLbl.leftAnchor.constraint(equalTo: iconImv.rightAnchor, constant: 12),
			titleLbl.centerYAnchor.constraint(equalTo: iconImv.centerYAnchor),

			primaryTxf.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 22),
			primaryTxf.topAnchor.constraint(equalTo: iconImv.bottomAnchor, constant: 65),
			primaryTxf.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -22),
			primaryTxf.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

			separatorView.leftAnchor.constraint(equalTo: primaryTxf.leftAnchor),
			separatorView.topAnchor.constraint(equalTo: primaryTxf.bottomAnchor, constant: 8),
			separatorView.rightAnchor.constraint(equalTo: primaryTxf.rightAnchor),
			separatorView.heightAnchor.constraint(equalToConstant: 1),

			cancelBtn.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 55),
			cancelBtn.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
			cancelBtn.heightAnchor.constraint(equalToConstant: 42),
			cancelBtn.widthAnchor.constraint(equalToConstant: 110),

			doneBtn.topAnchor.constraint(equalTo: cancelBtn.topAnchor),
			doneBtn.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20),
			doneBtn.heightAnchor.constraint(equalToConstant: 42),
			doneBtn.widthAnchor.constraint(equalToConstant: doneBtnWidth),
		])
	}

	override func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
		return
	}

	override func didTapDimmingView() {
		return
	}
}

// MARK: - Methods
extension TextFieldSheetController {
	private func configureUI() {
		iconImv.image = UIImage(named: option.getIconName())
		titleLbl.text = option.getTitle()
		primaryTxf.placeholder = option.getPlaceholder()
		doneBtn.setTitle(option.getButtonTitle(), for: .normal)
	}

	@objc private func textFieldDidChange(_ notification: Notification) {
		if let textField = notification.object as? UITextField, textField == primaryTxf {
			textField.text?.isEmpty == true ? enableDoneBtn(false) : enableDoneBtn(true)
		}
	}

	private func enableDoneBtn(_ enable: Bool) {
		doneBtn.isEnabled = enable
		doneBtn.backgroundColor = enable ? .primaryBlue : UIColor(rgb: 0xADADAD)
	}

	@objc private func handleKeyboardWillShow(_ notification: Notification) {
		guard let userInfo = notification.userInfo else { return }
		let keyboardSize: CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
		let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
		showSheet(keyboardHeight: keyboardSize.height, duration: duration)
	}

	@objc private func cancelBtnTapped() {
		primaryTxf.resignFirstResponder()
		self.removeSheet()
	}

	@objc private func doneBtnTapped() {
		if let text = primaryTxf.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            delegate?.didTapDone(withText: text, option: option, sender: self.primaryTxf, self)
		}
	}
}

// MARK: - Enum Option
extension TextFieldSheetController {
	enum Option {
		case zipFile, newFolder, downloadURL

		func getTitle() -> String {
			switch self {
				case .zipFile: return "Zip Files"
				case .newFolder: return "Create New Folder"
				case .downloadURL: return "Download URL"
			}
		}

		func getIconName() -> String {
			switch self {
				case .zipFile: return AssetConstant.ic_zip_blue
				case .newFolder: return AssetConstant.ic_folder_small
				case .downloadURL: return AssetConstant.ic_link
			}
		}

		func getPlaceholder() -> String {
			switch self {
				case .zipFile: return "Archive Name"
				case .newFolder: return "Folder Name"
				case .downloadURL: return "https://example.com"
			}
		}

		func getButtonTitle() -> String {
			switch self {
				case .zipFile, .newFolder: return "SAVE"
				case .downloadURL: return "DOWNLOAD"
			}
		}
	}
}
