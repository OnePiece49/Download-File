//
//  LoadingVC.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 29/07/2023.
//

import UIKit

class LoadingAnimationView: UIView {

	// MARK: - properties
	private let indicatorView: UIActivityIndicatorView = {
		if #available(iOS 13.0, *) {
			let view = UIActivityIndicatorView(style: .large)
			view.translatesAutoresizingMaskIntoConstraints = false
			view.color = .white
			return view
		} else {
			let view = UIActivityIndicatorView(style: .white)
			view.translatesAutoresizingMaskIntoConstraints = false
			return view
		}
	}()

	private let messageLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.font = .fontGilroyMedium(18)
		label.textColor = .white
		label.textAlignment = .center
		label.text = ""
		return label
	}()

	// MARK: - initial
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUIs()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUIs()
	}

	// MARK: - private
	private func setupUIs() {
		backgroundColor = UIColor.black.withAlphaComponent(0.6)
		applyBlurBackground(style: .dark)
		addSubview(indicatorView)
		addSubview(messageLabel)

		indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40).isActive = true
		indicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
		indicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true

		messageLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
		messageLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
		messageLabel.topAnchor.constraint(equalTo: indicatorView.bottomAnchor, constant: 20).isActive = true
		messageLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true

	}

	// MARK: - public
	func show() {
		guard let window = UIWindow.keyWindow else { return }

		self.frame = window.bounds
		self.alpha = 0
		window.addSubview(self)

		UIView.animate(withDuration: 0.3) {
			self.alpha = 1
		} completion: { finished in
			self.start()
		}
	}

	func dismiss() {
		stop()

		UIView.animate(withDuration: 0.3) {
			self.alpha = 0
		} completion: { finished in
			self.removeFromSuperview()
		}
	}

	private func start() {
		indicatorView.startAnimating()
	}

	private func stop() {
		indicatorView.stopAnimating()
	}

	func setMessage(_ message: String) {
		messageLabel.text = message
	}
}
