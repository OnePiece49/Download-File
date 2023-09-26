//
//  SettingController.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 28/07/2023.
//

import UIKit
import MessageUI

class SettingsController: BaseController {

    // MARK: - UI components
    private lazy var settingLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .fontGilroyBold(32)
        label.text = "Setting"
        return label
    }()

    private lazy var tableView: UITableView = {
        let tbv = UITableView()
        tbv.translatesAutoresizingMaskIntoConstraints = false
        tbv.register(SettingTBCell.self, forCellReuseIdentifier: SettingTBCell.cellId)
        tbv.isScrollEnabled = false
        tbv.delegate = self
        tbv.dataSource = self
        return tbv
    }()

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupConstraints()
    }

    private func setupConstraints() {
        view.addSubview(settingLbl)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            settingLbl.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            settingLbl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 13),

            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.topAnchor.constraint(equalTo: settingLbl.bottomAnchor, constant: 15),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - Private methods
extension SettingsController {
    private func rateApp() {
        guard let url = URL(string: "itms-apps://itunes.apple.com/app/" + "appId") else { return}
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func shareApp(cell: UITableViewCell) {
        let firstItem = "Files LasBom App"

        // Setting url
        let secondItem : NSURL = NSURL(string: "http://your-url.com/")!

        // If you want to use an image
        let image: UIImage = UIImage(named: AssetConstant.ic_app_default)!
        let activityItems: [Any] = [firstItem, secondItem, image]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = cell
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)

        // Pre-configuring activity items
        if #available(iOS 13.0, *) {
            activityViewController.activityItemsConfiguration = [
                UIActivity.ActivityType.message
            ] as? UIActivityItemsConfigurationReading
        }

        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToFacebook
        ]

        if #available(iOS 13.0, *) {
            activityViewController.isModalInPresentation = true
        }

        self.present(activityViewController, animated: true, completion: nil)
    }

    private func sendFeedback(controller: UIViewController) {
        let emailSupport = ""
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients([emailSupport])
            controller.present(composeVC, animated: true, completion: nil)

        } else {
            let alert = UIAlertController(title: "Notification", message: "You have not set up an email.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
            if let popover = alert.popoverPresentationController {
                popover.sourceView = controller.view
                popover.sourceRect = controller.view.bounds
            }
            controller.present(alert, animated: true, completion: nil)
        }
    }

    private func termOfPolicy() {
        guard let url = URL(string: "https://www.google.com.vn/") else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension SettingsController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension SettingsController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingOption.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingTBCell.cellId,
                                                 for: indexPath) as! SettingTBCell
        cell.cellType = SettingOption(rawValue: indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let option = SettingOption(rawValue: indexPath.row) else { return }
        switch option {
        case .rate:
            self.rateApp()
        case .share:
            guard let cell = tableView.cellForRow(at: indexPath) else {return}
            self.shareApp(cell: cell)
        case .contact:
            self.sendFeedback(controller: self)
        case .privacy:
            self.termOfPolicy()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SettingTBCell.heightCell
    }
}
