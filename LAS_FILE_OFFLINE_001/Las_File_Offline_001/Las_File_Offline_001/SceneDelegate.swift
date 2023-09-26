//
//  SceneDelegate.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 28/07/2023.
//

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scence = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scence)
        self.window = window
        RealmService.shared.configuration()
        let root = UINavigationController(rootViewController: TabBarController())
        root.setNavigationBarHidden(true, animated: false)
        print("DEBUG: \(String(describing: URL.downloadFolder()))")

        window.rootViewController = root
        window.makeKeyAndVisible()
    }



}

