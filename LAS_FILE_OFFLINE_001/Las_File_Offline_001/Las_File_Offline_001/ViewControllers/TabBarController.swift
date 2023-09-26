//
//  TabBarController.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 28/07/2023.
//

import UIKit


class TabBarController: UITabBarController {
    
    //MARK: - Properties
    
    
    //MARK: - UIComponent
    
    
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureProperties()
		selectedIndex = 1
    }
    
}

//MARK: - Method
extension TabBarController {
    
    //MARK: - Helpers
    func configureUI() {
		let downloadVC =  templateNavigationController(rootViewController: DownloadController(), namedImage: AssetConstant.ic_download)
		let fileVC =  templateNavigationController(rootViewController: FileController(), namedImage: AssetConstant.ic_file)
		let browserVC =  templateNavigationController(rootViewController: BrowserController(), namedImage: AssetConstant.ic_browser)
		let settingVC =  templateNavigationController(rootViewController: SettingsController(), namedImage: AssetConstant.ic_setting)
        
        self.viewControllers = [downloadVC, fileVC, browserVC, settingVC]
        self.navigationController?.navigationBar.isHidden = true
        styleTabbar()
    }
    
    func configureProperties() {
        
    }
    
    private func templateNavigationController(rootViewController: UIViewController,
                                              namedImage: String) -> UIViewController {
//        let nav = UINavigationController(rootViewController: rootViewController)
//        rootViewController.navigationBar.barTintColor = .white
        rootViewController.tabBarItem.image = UIImage(named: namedImage)
        rootViewController.tabBarItem.imageInsets = UIDevice.current.is_iPhone ? UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0) : .zero
        return rootViewController
    }
    
    private func styleTabbar() {
		(tabBar.items![0] ).selectedImage = UIImage(named: AssetConstant.ic_download_selected)?.withRenderingMode(.alwaysOriginal)
		(tabBar.items![1] ).selectedImage = UIImage(named: AssetConstant.ic_file_selected)?.withRenderingMode(.alwaysOriginal)
		(tabBar.items![2] ).selectedImage = UIImage(named: AssetConstant.ic_browser_selected)?.withRenderingMode(.alwaysOriginal)
		(tabBar.items![3] ).selectedImage = UIImage(named: AssetConstant.ic_setting_selected)?.withRenderingMode(.alwaysOriginal)
        
        tabBar.backgroundColor = .white
     }
    
    //MARK: - Selectors
    
}

