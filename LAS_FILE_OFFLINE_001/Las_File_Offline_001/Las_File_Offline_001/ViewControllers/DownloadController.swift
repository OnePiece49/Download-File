//
//  DownloadController.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 28/07/2023.
//

import UIKit
import WebKit
import Toast_Swift
import QuickLook
import AVFoundation
import AVKit

class DownloadController: BaseController {
    
    //MARK: - Properties
    private let viewModel = DownloadViewModel()
    private var outputURL: URL?
    private let configuration = WKWebViewConfiguration()
    private var noCententCellHeight: CGFloat {
        return view.frame.height - self.insetTop - 44
    }
    
    //MARK: - UIComponent
    let player = AVPlayer()
    private var navigationBar: NavigationCustomView!
    private var webView: WKWebView!
    private let loadingView = LoadingView(message: "Downloading...")
    
    private lazy var downloadTB: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DownloadTBCell.self, forCellReuseIdentifier: DownloadTBCell.cellId)
        tableView.register(NoContenTBCell.self, forCellReuseIdentifier: NoContenTBCell.cellId)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        return tableView
    }()
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
}

//MARK: - Method
extension DownloadController {
    
    //MARK: - Helpers
    private func loadData() {
        player.isMuted = true
        viewModel.bindingViewModel = { [weak self] in
            self?.downloadTB.reloadData()
        }
        
        viewModel.bindingDowmload = { [weak self] in
            self?.downloadTB.reloadData()
        }
        
        viewModel.bindingDeleteFile = { [weak self] indexPath in
            self?.view.displayToast("Delete file successfully", duration: 2.0, position: .center)
            self?.downloadTB.reloadData()
        }
        
        viewModel.bindingRenameFile = { [weak self] indexPath in
            self?.downloadTB.reloadRows(at: [indexPath], with: .automatic)
        }
        
        viewModel.loadData()
    }
    
    private func configureUI() {
        configureNavigationBar()
        configureWebView()
        
        view.addSubview(navigationBar)
        view.addSubview(downloadTB)
        view.addSubview(loadingView)
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 44),
            
            downloadTB.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            downloadTB.leftAnchor.constraint(equalTo: view.leftAnchor),
            downloadTB.rightAnchor.constraint(equalTo: view.rightAnchor),
            downloadTB.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leftAnchor.constraint(equalTo: view.leftAnchor),
            loadingView.rightAnchor.constraint(equalTo: view.rightAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        loadingView.alpha = 0
    }

    private func configureWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "WebViewControllerMessageHandler")

        configuration.userContentController = contentController
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsAirPlayForMediaPlayback = false //mute voice webview
        configuration.mediaTypesRequiringUserActionForPlayback = .all
        webView = WKWebView(frame: .zero, configuration: configuration)
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        webView.isHidden = true
        webView.navigationDelegate = self
        view.addSubview(webView)
    }
    
    private func configureNavigationBar() {
        let firstAttributeLeft = AttibutesButton(tilte: "Downloads",
                                                 font: .fontGilroyBold(32),
                                                  titleColor: .black)
        
        let firstAttributeRight = AttibutesButton(image: UIImage(named: AssetConstant.ic_option)?.withRenderingMode(.alwaysOriginal),
                                                  sizeImage: .init(width: 30, height: 30)) { [weak self] in
            self?.didSelectOptionButton()
        }
        
        let secondAttributeRight = AttibutesButton(image: UIImage(named: AssetConstant.ic_plus_url)?.withRenderingMode(.alwaysOriginal),
                                                   sizeImage: .init(width: 50, height: 30)) { [weak self] in
            let vc = TextFieldSheetController(option: .downloadURL)
            vc.modalPresentationStyle = .overFullScreen
            vc.delegate = self
            self?.present(vc, animated: false)
        }
        
        self.navigationBar = NavigationCustomView(centerTitle: "",
                                                  attributeLeftButtons: [firstAttributeLeft],
                                                  attributeRightBarButtons: [firstAttributeRight,
                                                                             secondAttributeRight],
                                                  isHiddenDivider: true,
                                                  beginSpaceLeftButton: 20,
                                                  beginSpaceRightButton: 18,
                                                  continueSpaceRight: 20)
        
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.backgroundColor = .white
    }
    
    private func didSelectOptionButton() {
        let point = self.navigationBar.rightButtons[0].convert(self.navigationBar.rightButtons[0].bounds.origin, to: self.view)
        let vc = OptionDownloadController(selectedOption: viewModel.filterOption,
                                          popoverSize: OptionDownloadController.sizeView,
                                          pointAppear: CGPoint(x: point.x + 30, y: point.y + 30))
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        self.present(vc, animated: false)
    }
    
    //MARK: - Selectors
    
}

// MARK: - Delegate WKNavigationDelegate, WKScriptMessageHandler
extension DownloadController: WKNavigationDelegate, WKScriptMessageHandler {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
       
        guard let url = webView.url, url != URL(string: "about:blank") else {return}

        let js = """
        let length = document.getElementsByTagName('video').length
         if (length == 0) {
            window.webkit.messageHandlers.WebViewControllerMessageHandler.postMessage({ "src": [0] });
         }
        for(let i = 0; i < length; i++) {
            let video = document.getElementsByTagName('video')[i];
            let src = video.src;
            window.webkit.messageHandlers.WebViewControllerMessageHandler.postMessage({ "src": src });
        }
        """

        let nameFile = url.lastPathComponent.appending("?\(url.query ?? "")" )
        self.outputURL = URL.downloadFolder()?.appendingPathComponent(nameFile)
        
        webView.evaluateJavaScript(js)
        webView.stopLoading()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any] else {
            print("DEBUG: 0.0.0.0.0.0 could not convert message body to dictionary: \(message.body)")
            return
        }
        
        guard let urlString = body["src"] as? String else {
            loadingView.dismiss()
            self.view.displayToast("Downloads File Failed. Please try again with others URL", position: .center)
            return
        }
        let url = URL(string: urlString)
        
        DownloadManager.shared.downloadFile(inputURL: url,
                                            outputURL: outputURL) { success, output, fileExist  in
            DispatchQueue.main.async {
                self.loadingView.dismiss()
                
                if fileExist {
                    self.view.displayToast("File \(self.outputURL!.lastPathComponent) already exists.")
                    return
                }
                
                if success {
                    self.viewModel.saveDataToRealm(output: output!, name: nil)
                    self.view.displayToast("Downloads File Successfully", position: .center)
                } else {
                    self.view.displayToast("Downloads File Failed. Please try again with others URL", position: .center)
                }
            }
        }
    }
}

// MARK: - Delegate TextFieldSheetControllerDelegate
extension DownloadController: TextFieldSheetControllerDelegate {
    
    func didTapDone(withText text: String,
                    option: TextFieldSheetController.Option,
                    sender: UITextField,
                    _ vc: TextFieldSheetController) {
        
        vc.dismiss(animated: true) {
            self.dowloadUrl(url: text)
        }
        
    }
    
    private func loadYouTube(url: URL?) {
        guard let url = url, self.verifyUrl(urlString: url.absoluteString) == true else {
            self.loadingView.dismiss()
            print("DEBUG: \(self.verifyUrl(urlString: url?.absoluteString)) kkkk")
            self.view.displayToast("Downloads File Failed. Please try again with others URL", position: .center)
            return
        }

        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
    }
    
    
    private func dowloadUrl(url: String) {
        let url = URL(string: url)
        let isExist = checkExistedFile(inputUrl: url)
        if isExist.0 {
            self.view.displayToast("File \(isExist.1) already exists.", position: .center)
            return
        }
        
        self.loadingView.show()
        
        var nameFile: String? = ""
        if url?.query == nil {
             nameFile = url?.deletingPathExtension().lastPathComponent
        } else {
             nameFile = url?.deletingPathExtension().lastPathComponent.appending("?\(url?.query ?? "")" )
        }
        
        self.outputURL = URL.downloadFolder()?.appendingPathComponent(nameFile ?? "Updating")
    
 
        
        DownloadManager.shared.downloadFile(inputURL: url,
                                            outputURL: outputURL) { success, output, fileExisted  in
            DispatchQueue.main.async {
                
                if fileExisted {
                    self.loadingView.dismiss()
                    self.view.displayToast("File \(output!.lastPathComponent) already exists.", position: .center)
                    return
                }
                
                if success {
                    self.viewModel.saveDataToRealm(output: output!, name: nil)
                    self.view.displayToast("Downloads File Successfully", duration: 3.0, position: .center)
                    self.loadingView.dismiss()
                } else {
                    self.loadYouTube(url: url)
                }
            }

        }
    }
    
    private func checkExistedFile(inputUrl: URL?) -> (Bool, String) {
        guard let inputUrl = inputUrl else {return (false, "")}
        
        let nameFile = inputUrl.lastPathComponent.appending(inputUrl.query ?? "")
        guard let tempUrl = URL.downloadFolder()?.appendingPathComponent(nameFile) else {return (false, "")}
        
        let isExisted = FileManager.default.fileExists(atPath: tempUrl.path)
        print("DEBUG: \(tempUrl.absoluteString) kkkk and isExisted: \(isExisted)")
        return (isExisted, nameFile)
    }
    
}

// MARK: - Delegate OptionDownloadVCDelegate
extension DownloadController: OptionDownloadVCDelegate {
    func didSlectOption(type: OptionDownload) {
        viewModel.filterOption = type
        viewModel.loadData()
    }
}

// MARK: - Delegate UITableViewDelegate, DataSource, QLPreviewControllerDataSource
extension DownloadController: UITableViewDelegate, UITableViewDataSource, PreviewItemPresentable {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel.numberCells != 0) ? viewModel.numberCells : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.numberCells == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NoContenTBCell.cellId,
                                                     for: indexPath) as! NoContenTBCell
			cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: DownloadTBCell.cellId,
                                                 for: indexPath) as! DownloadTBCell
        cell.viewModel = DowloadCellViewModel(file: viewModel.fileAtIndexPath(at: indexPath))

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.numberCells == 0 {return}
		self.previewDocx(currentPreviewItemIndex: indexPath.row, parentVC: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (viewModel.numberCells != 0)  ? DownloadTBCell.heightCell : self.noCententCellHeight
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
            -> UISwipeActionsConfiguration? {
                if viewModel.numberCells == 0 {return nil}
                
            guard let cell = tableView.cellForRow(at: indexPath) as? DownloadTBCell else {return nil}
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completionHandler) in
                self?.deleteFile(indexPath: indexPath)
                completionHandler(true)
            }
            deleteAction.backgroundColor = .red
            deleteAction.image = UIImage(named: AssetConstant.ic_delete)?.withRenderingMode(.alwaysOriginal)
                
            let moreAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completionHandler) in
                self?.moreAction(cell: cell, indexpath: indexPath)
                completionHandler(true)
            }
                
            moreAction.backgroundColor = UIColor(rgb: 0xDEDEDE)
            moreAction.image = UIImage(named: AssetConstant.ic_more)?.withRenderingMode(.alwaysOriginal)
            
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction, moreAction])
            return configuration
    }
    
    private func moreAction(cell: DownloadTBCell, indexpath: IndexPath) {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertVC.addAction(UIAlertAction(title: "Share", style: .default, handler: { [weak self]  alert in
            let objectsToShare: [Any] = [cell.viewModel?.fileURL as Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self?.view
            self?.present(activityVC, animated: true, completion: nil)
        }))
        
        alertVC.addAction(UIAlertAction(title: "Rename", style: .default, handler: { [weak self] alert in
            self?.renameFile(indexPath: indexpath)
        }))
        
        alertVC.addAction(UIAlertAction(title: "Copy To", style: .default, handler: { [weak self] alert in
            let vm = FileActionSheetViewModel(type: .copy,
                                              files: [self!.viewModel.fileAtIndexPath(at: indexpath)],
                                              currentFolder: nil)
            let copyVC = FileActionSheetController(viewModel: vm)
            copyVC.modalPresentationStyle = .overFullScreen
            copyVC.delegate = self
            self?.present(copyVC, animated: false, completion: {
                copyVC.showSheet()
            })
        }))
        
        alertVC.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] alert in
            self?.deleteFile(indexPath: indexpath)
        }))
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if UIDevice.current.is_iPhone {
            self.present(alertVC, animated: true)
        } else {
            if let popoverController = alertVC.popoverPresentationController {
              popoverController.barButtonItem = UIBarButtonItem(customView: cell)
            }
            self.present(alertVC, animated: true)
        }
    }
    
    private func renameFile(indexPath: IndexPath) {
        let alertVC = UIAlertController(title: "New Name", message: "", preferredStyle: .alert)
        alertVC.addTextField()
        alertVC.textFields?.first?.placeholder = "Enter name"
        
        alertVC.addAction(UIAlertAction(title: "Save", style: .default, handler: { alert in
            if alertVC.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                self.view.displayToast("Name File Is Invalide", duration: 3.0, position: .center)
                return
            }
            
            self.viewModel.renameFile(name: alertVC.textFields?.first?.text, at: indexPath)
        }))
        
        self.present(alertVC, animated: true)
    }
    
    private func deleteFile(indexPath: IndexPath) {
        let alertVC = UIAlertController(title: "Delete File", message: "Deleting this file will also delete all copied files in other folders. \n\nAre you sure to delete file ?", preferredStyle: .alert)
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertVC.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] alert in
            self?.viewModel.deleteFile(at: indexPath)
        }))
        
        self.present(alertVC, animated: true)
    }
    
}

extension DownloadController: QLPreviewControllerDataSource {
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let cell = downloadTB.cellForRow(at: IndexPath(row: index, section: 0)) as? DownloadTBCell
        return cell?.viewModel?.file.absolutePath as? NSURL ?? NSURL()
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
		return viewModel.numberCells
    }
}


extension DownloadController: FileActionSheetControllerDelegate {
    func finishModifyFolder(_ controller: FileActionSheetController, actionType: FileActionSheetController.ActionType) {
        self.view.displayToast("Copy File Successfully", duration: 2.0, position: .center)
    }
    
    
}
