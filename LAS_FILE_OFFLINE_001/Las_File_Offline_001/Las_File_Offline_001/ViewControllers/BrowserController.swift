//
//  BrowserController.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 28/07/2023.
//

import UIKit
import WebKit

class BrowserController: BaseController {
    
    //MARK: - Properties

    var widthSearchView: CGFloat = 200
    let queue = DispatchQueue(label: "api")
    let configureWebView = WKWebViewConfiguration()
    var canReloadOldUrl: Bool = false
    
    
    private lazy var suggestCL: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SuggestCLCell.self, forCellWithReuseIdentifier: SuggestCLCell.cellId)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    //MARK: - UIComponent
    let progressLoading = UIProgressView(frame: .zero)
    let searchVoiceVC = VoiceOverlayController()
    let searchView = CustomSearchBarView()
    let loadingIndicator = UIActivityIndicatorView()
    var navWebKit: NavigationCustomView!
    var webView: WKWebView!
    let loadFailedView = NotReachDomainView()
    
    //MARK: - View Lifecycle
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let _ = object as? WKWebView {
            if keyPath == #keyPath(WKWebView.canGoBack) {
                self.navWebKit.leftButtons[0].isEnabled = self.webView.canGoBack
                self.navWebKit.leftButtons[0].alpha = self.webView.canGoBack ? 1.0 : 0.5
                
            } else if keyPath == #keyPath(WKWebView.canGoForward) {
                self.navWebKit.leftButtons[1].isEnabled = self.webView.canGoForward
                self.navWebKit.leftButtons[1].alpha = self.webView.canGoForward ? 1.0 : 0.5
            }
            

            if keyPath == #keyPath(WKWebView.url) && canReloadOldUrl && webView.url == URL(string: "about:blank") {
                self.loadFailedView.isHidden = false
                self.loadingIndicator.stopAnimating()
            }
            
            if keyPath == #keyPath(WKWebView.estimatedProgress) {
                if webView.url == URL(string: "about:blank") {
                    progressLoading.isHidden = true
                }
                self.progressLoading.progress = Float(self.webView.estimatedProgress)
                
                if webView.estimatedProgress == 1 {
                    finishLoading()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavWebView()
        configureUI()
        configureProperties()
        configureVoiceVC()
    }
    
    private func configureUI() {
        view.addSubview(searchView)
        view.addSubview(progressLoading)
        view.addSubview(suggestCL)
        view.addSubview(loadingIndicator)
        view.addSubview(loadFailedView)
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        progressLoading.translatesAutoresizingMaskIntoConstraints = false
        self.configWebView()
               
        NSLayoutConstraint.activate([
            searchView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14),
            searchView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -14),
            searchView.heightAnchor.constraint(equalToConstant: 40),
            
            progressLoading.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            progressLoading.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            progressLoading.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 3.5),
            progressLoading.heightAnchor.constraint(equalToConstant: 2.5),
            
            suggestCL.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 18),
            suggestCL.leftAnchor.constraint(equalTo: searchView.leftAnchor, constant: 40),
            suggestCL.rightAnchor.constraint(equalTo: searchView.rightAnchor, constant: -40),
            suggestCL.heightAnchor.constraint(equalToConstant: 70),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            loadFailedView.leftAnchor.constraint(equalTo: view.leftAnchor),
            loadFailedView.rightAnchor.constraint(equalTo: view.rightAnchor),
            loadFailedView.topAnchor.constraint(equalTo: searchView.bottomAnchor),
            loadFailedView.bottomAnchor.constraint(equalTo: navWebKit.topAnchor)
        ])
        loadingIndicator.setDimensions(width: 40, height: 40)
        view.layoutIfNeeded()

        widthSearchView = searchView.frame.width - 80 - SuggestCLCell.miniSpacing * CGFloat((SuggestBrowser.allCases.count - 1))
        suggestCL.reloadData()
        suggestCL.isScrollEnabled = false
        progressLoading.isHidden = true
        loadFailedView.isHidden = true

    }
    
    private func configureNavWebView() {
        let firstAttributeLeft = AttibutesButton(image: UIImage(named: AssetConstant.ic_back),
                                                 sizeImage: CGSize(width: 30, height: 30),
                                                 tincolor: .primaryBlue) { [weak self] in
            self?.webView.goBack()
        }
        
        let secondAttributeLeft = AttibutesButton(image: UIImage(named: AssetConstant.ic_next),
                                                  sizeImage: CGSize(width: 30, height: 30),
                                                  tincolor: .primaryBlue) { [weak self] in
            self?.webView.goForward()
        }
        
        let attributeRight =  AttibutesButton(image: UIImage(named: AssetConstant.ic_reload),
                                              sizeImage: CGSize(width: 30, height: 30),
                                              tincolor: .primaryBlue) { [weak self] in
            self?.webView.reload()
        }
        
        let secondRight =  AttibutesButton(image: UIImage(named: AssetConstant.ic_home),
                                              sizeImage: CGSize(width: 30, height: 30),
                                              tincolor: .primaryBlue) { [weak self] in
            self?.gobackMainHome()
        }
        
        let thirdRight =  AttibutesButton(image: UIImage(named: AssetConstant.ic_bookmark),
                                              sizeImage: CGSize(width: 20, height: 21),
                                              tincolor: .primaryBlue) { [weak self] in
            let url = self?.webView.url
            let viewModel = BookmarkViewModel(currentUrl: url)
            let vc = BookmarkSheetController(viewModel: viewModel)
            vc.modalPresentationStyle = .overFullScreen
            vc.delegate = self
            self?.present(vc, animated: false)
        }
        
        
        self.navWebKit = NavigationCustomView(centerTitle: "",
                                              attributeLeftButtons: [firstAttributeLeft,
                                                                     secondAttributeLeft],
                                              attributeRightBarButtons: [attributeRight,
                                                                         secondRight,
                                                                         thirdRight],
                                              isHiddenDivider: true,
                                              beginSpaceLeftButton: 15,
                                              beginSpaceRightButton: 25,
                                              continueSpaceleft: 12,
                                              continueSpaceRight: 40)
        
        navWebKit.translatesAutoresizingMaskIntoConstraints = false
        navWebKit.backgroundColor = UIColor(rgb: 0x000000).withAlphaComponent(0.05)
        
        view.addSubview(navWebKit)

        NSLayoutConstraint.activate([
            navWebKit.heightAnchor.constraint(equalToConstant: 35),
            navWebKit.leftAnchor.constraint(equalTo: view.leftAnchor),
            navWebKit.rightAnchor.constraint(equalTo: view.rightAnchor),
            navWebKit.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        self.navWebKit.rightButtons[2].contentMode = .scaleToFill
        self.navWebKit.rightButtons[2].contentVerticalAlignment = .fill
        self.navWebKit.rightButtons[2].contentHorizontalAlignment = .fill
    }
    
}

//MARK: - Method
extension BrowserController {
    
    //MARK: - Helpers
    
    private func updateSearchView() {
        guard let url = webView.url else {return}
        
        if url == URL(string: "about:blank") {
            self.searchView.textForSearchView(text: "")
            return
        }
        self.searchView.textForSearchView(text: url.absoluteString)
    }
    
    private func configureVoiceVC() {
        searchVoiceVC.delegate = self
        searchVoiceVC.settings.autoStop = true
        searchVoiceVC.settings.autoStopTimeout = 60
    }
    
    private func configWebView() {
        configureWebView.allowsInlineMediaPlayback = true
        configureWebView.mediaTypesRequiringUserActionForPlayback = .all
        webView = WKWebView(frame: .zero, configuration: configureWebView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 15),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor),
            webView.bottomAnchor.constraint(equalTo: navWebKit.topAnchor),
        ])
        self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: [.new, .old], context: nil)
        self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: [.new, .old], context: nil)
        self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: .new, context: nil)
        self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: [.new, .old], context: nil)
        
        self.navWebKit.leftButtons[0].isEnabled = self.webView.canGoBack
        self.navWebKit.leftButtons[0].alpha = self.webView.canGoBack ? 1.0 : 0.5
        self.navWebKit.leftButtons[1].isEnabled = self.webView.canGoForward
        self.navWebKit.leftButtons[1].alpha = self.webView.canGoForward ? 1.0 : 0.5
        self.navWebKit.rightButtons[0].alpha = 0.5
        self.navWebKit.rightButtons[0].isEnabled = false
    }

    private func configureProperties() {
        searchView.delegate = self
        webView.isHidden = true
    }
    
    private func gobackMainHome() {
        self.loadFailedView.isHidden = true
        self.webView.stopLoading()
        self.webView.isHidden = true
        self.suggestCL.isHidden = false
        self.loadingIndicator.stopAnimating()
        self.navWebKit.leftButtons[0].isEnabled = false
        self.navWebKit.leftButtons[0].alpha = 0.5
        self.navWebKit.leftButtons[1].isEnabled = false
        self.navWebKit.leftButtons[1].alpha = 0.5
        self.navWebKit.rightButtons[0].alpha = 0.5
        self.navWebKit.rightButtons[0].isEnabled = false
        self.canReloadOldUrl = false
        if let clearURL = URL(string: "about:blank") {
            self.webView.load(URLRequest(url: clearURL))
            self.updateSearchView()
        }
        
        self.webView.backForwardList.perform(Selector(("_removeAllItems")))
    }
    
    //MARK: - Selectors
    
}


// MARK: - Delegate VoiceOverlayDelegate
extension BrowserController: VoiceOverlayDelegate {
    func recording(text: String?, final: Bool?, error: Error?) {
        guard let text = text, text != "" && final == true else {return}
        searchWithText(text: text)
    }
}

// MARK: - Delegate UICollectionViewDelegate, UICollectionViewDataSource
extension BrowserController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SuggestBrowser.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SuggestCLCell.cellId,
                                                      for: indexPath) as! SuggestCLCell
        cell.cellType = SuggestBrowser(rawValue: indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: widthSearchView / CGFloat(SuggestBrowser.allCases.count), height: SuggestCLCell.heightCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return SuggestCLCell.miniSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let suggestType = SuggestBrowser(rawValue: indexPath.row), let request = suggestType.urlRequest  else {return}
        
        requestApi(urlRequest: request)
    }
    
}

// MARK: - Delegate CustomSearchBarDelegate
extension BrowserController: CustomSearchBarDelegate {
    func didTapMicButton() {
        searchVoiceVC.start(on: self.tabBarController ?? self) { _, done, _ in
        } errorHandler: { _ in
        }

    }
    
    func didEndSearching(textField: UITextField) {
        guard let text = textField.text, text != "" else {return}
        searchWithText(text: text)
    }
    
    private func searchWithText(text: String) {
        let isWeb = verifyUrl(urlString: text)
                
        if isWeb {
            guard let url = URL(string: text) else {return}
            let urlRequest = URLRequest(url: url)
            requestApi(urlRequest: urlRequest)
            return
        }
        
        if !isWeb  {
            let temp = "https://\(text)"
            let tempUrl = URL(string: temp)
            
            let isW = verifyUrl(urlString: temp)
            if isW && text.contains(".") && !text.contains(" ") {
                guard let url = tempUrl else {return}
                var urlRequest = URLRequest(url: url)
                urlRequest.timeoutInterval = 7
                
                requestApi(urlRequest: urlRequest)
                return
            }
        }
        
        let textComponent = text.folding(options: .diacriticInsensitive, locale: nil).components(separatedBy: " ")
        let searchString = textComponent.joined(separator: "+")

        guard let url = URL(string: "https://www.google.com/search?q=" + searchString) else {return}
        let urlRequest = URLRequest(url: url)
        requestApi(urlRequest: urlRequest)
    }

    
    private func finishLoading() {
        if webView.url == URL(string: "about:blank") {
            return
        }
        
        self.loadingIndicator.stopAnimating()
        self.webView.isHidden = false
        
        self.navWebKit.rightButtons[0].alpha = 1
        self.navWebKit.rightButtons[0].isEnabled = true
        self.configureWebView.allowsAirPlayForMediaPlayback = true
        
        self.navWebKit.leftButtons[0].isEnabled = self.webView.canGoBack
        self.navWebKit.leftButtons[0].alpha = self.webView.canGoBack ? 1.0 : 0.5
        self.navWebKit.leftButtons[1].isEnabled = self.webView.canGoForward
        self.navWebKit.leftButtons[1].alpha = self.webView.canGoForward ? 1.0 : 0.5
        self.progressLoading.isHidden = true
    }
    
    private func requestApi(urlRequest: URLRequest) {
        self.canReloadOldUrl = true
        self.loadFailedView.isHidden = false
        self.progressLoading.progress = 0
        self.progressLoading.isHidden = false
        self.loadFailedView.isHidden = true
        loadingIndicator.startAnimating()
        webView.load(urlRequest)
        self.suggestCL.isHidden = true
        self.updateSearchView()
    }
}

// MARK: - Delegate BookmarkSheetDelegate
extension BrowserController: BookmarkSheetDelegate {
    func didSelecCell(urlString: String) {
        searchWithText(text: urlString)
    }
    
    
}
