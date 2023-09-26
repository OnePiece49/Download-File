//
//  BookmarkSheetController.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 07/08/2023.
//

import Foundation


import UIKit
import MediaPlayer

protocol BookmarkSheetDelegate: AnyObject {
    func didSelecCell(urlString: String)
}

class BookmarkSheetController: BottomSheetViewCustomController {
    
    //MARK: - Properties
    var musics: [MPMediaItem] = []
    weak var delegate: BookmarkSheetDelegate?
    var navigationBar: NavigationCustomView!
    let containerView = UIView(frame: .zero)
    let tableView = UITableView(frame: .zero, style: .plain)
    let viewModel: BookmarkViewModel
    
    override var durationAnimation: CGFloat {
        return 0.3
    }
    
    override var bottomSheetView: UIView {
        return containerView
    }
    
    override var heightBottomSheetView: CGFloat {
        return view.frame.height - 220
    }
    
    override var maxHeightScrollTop: CGFloat {
        return 0
    }
    
    override var minHeightScrollBottom: CGFloat {
        return 300
    }
    
    override var canMoveBottomSheet: Bool {
        return false
    }
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleClearButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var miniClearView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(rgb: 0xD8D8D8)
        view.addSubview(clearButton)
        NSLayoutConstraint.activate([
            clearButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -5),
            clearButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25),
        ])

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        loadData()
        configureProperties()
        
    }
    
    deinit {
        print("DEBUG: BookmarkSheetController deinit")
    }
    
    //MARK: - Helpers
    init(viewModel: BookmarkViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadData() {
        viewModel.bindingViewModel = { [weak self] in
            self?.tableView.reloadData()
            self?.navigationBar.leftButtons[0].isEnabled = self!.viewModel.canBookmark ? true : false
            self?.navigationBar.leftButtons[0].alpha =  self!.viewModel.canBookmark ? 1.0 : 0.4
            self?.tableView.isScrollEnabled = (self?.viewModel.numberCell != 0) ? true : false
            
            if self?.viewModel.isBookmarked == true {
                self?.navigationBar.leftButtons[0].setImage(UIImage(named: AssetConstant.ic_bookmarked)?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        
        viewModel.bindingBookmark = { [weak self] success in
            if success {
                self?.tableView.reloadData()
                self?.navigationBar.leftButtons[0].setImage(UIImage(named: AssetConstant.ic_bookmarked)?.withRenderingMode(.alwaysOriginal), for: .normal)
                self?.view.displayToast("Bookmark Url succcess")
            } else {
                self?.view.displayToast("Url already existed. Bookmark failed")
            }
        }
        
        viewModel.bindingClear = { [weak self] in
            self?.tableView.reloadData()
            self?.view.displayToast("Clear Bookmark Successfully")
            self?.navigationBar.leftButtons[0].setImage(UIImage(named: AssetConstant.ic_not_bookmark)?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        viewModel.bindingDeleteBookmark = { [weak self] isCurrentUrl in
            self?.tableView.reloadData()
            if isCurrentUrl {
                self?.navigationBar.leftButtons[0].setImage(UIImage(named: AssetConstant.ic_not_bookmark)?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
            self?.view.displayToast("Delete Successfully")
        }
        
        viewModel.loadData()
    }
    
    func configureUI() {
        containerView.clipsToBounds = true
        configureNaviationBar()
        
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.layer.cornerRadius = 20
        navigationBar.backgroundColor = .white
        containerView.backgroundColor = .white
        
        containerView.addSubview(navigationBar)
        containerView.addSubview(tableView)
        containerView.addSubview(miniClearView)
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            navigationBar.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 45),
            
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 10),
            tableView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: miniClearView.topAnchor),
            
            miniClearView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            miniClearView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            miniClearView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            miniClearView.heightAnchor.constraint(equalToConstant: 80),
        ])
    }
    
    func configureProperties() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BookmarkTBCell.self,
                           forCellReuseIdentifier: BookmarkTBCell.cellId)
        tableView.register(NoContenTBCell.self,
                           forCellReuseIdentifier: NoContenTBCell.cellId)
    }
    
    private func configureNaviationBar() {
        let firstAttributeLeft = AttibutesButton(image: UIImage(named: AssetConstant.ic_not_bookmark),
                                                 sizeImage: CGSize(width: 30, height: 30),
                                                 tincolor: .black) { [weak self] in
            self?.viewModel.bookmark()
        }
        
        let attributeRight = AttibutesButton(tilte: "Cancel",
                                             font: .boldSystemFont(ofSize: 16),
                                             titleColor: .primaryBlue) { [weak self] in
            self?.animationDismiss()
        }
        
        let attibuted = NSAttributedString(string: "Bookmarks", attributes: [.font : UIFont.boldSystemFont(ofSize: 18)])
        self.navigationBar = NavigationCustomView(centerTitle: "",
                                                  attributedTitle: attibuted,
                                                  attributeLeftButtons: [firstAttributeLeft],
                                                  attributeRightBarButtons: [attributeRight],
                                                  isHiddenDivider: true,
                                                  beginSpaceLeftButton: 20,
                                                  beginSpaceRightButton: 15)
        
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.backgroundColor = .white
    }
    
    //MARK: - Selectors
    @objc func handleClearButtonTapped() {
        viewModel.clearBookmark()
    }
    
}
//MARK: - delegate
extension BookmarkSheetController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel.numberCell != 0) ? viewModel.numberCell : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.numberCell == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NoContenTBCell.cellId,
                                                     for: indexPath) as! NoContenTBCell
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkTBCell.cellId,
                                                 for: indexPath) as! BookmarkTBCell
        cell.urlString = viewModel.urlString(at: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
        if viewModel.numberCell == 0 {return}
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelecCell(urlString: viewModel.urlString(at: indexPath))
        self.animationDismiss()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (viewModel.numberCell != 0) ? BookmarkTBCell.heightCell : heightBottomSheetView
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
            -> UISwipeActionsConfiguration? {
            
            if viewModel.numberCell == 0 {return nil}

            let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completionHandler) in
                self?.viewModel.deleteBookmark(at: indexPath)
                completionHandler(true)
            }
            deleteAction.backgroundColor = .red
            deleteAction.image = UIImage(named: AssetConstant.ic_delete)?.withRenderingMode(.alwaysOriginal)
            
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            return configuration
    }
    
}


