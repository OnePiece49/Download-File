//
//  AppDelegate.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 28/07/2023.
//

import UIKit
import AVFoundation
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    class AppDelegate: UIResponder, UIApplicationDelegate {
        
        var window: UIWindow?
        
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            
            
            let root = UINavigationController(rootViewController: TabBarController())
            root.setNavigationBarHidden(true, animated: false)
            
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = root
            window?.makeKeyAndVisible()
            RealmService.shared.configuration()

            
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(AVAudioSession.Category.playback, mode: .default)
            } catch let error as NSError {
                print("DEBUG: Setting category to AVAudioSessionCategoryPlayback failed: \(error)")
            }
            return true
        }
        
    }



}
