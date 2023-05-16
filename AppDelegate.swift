//
//  AppDelegate.swift
//  memo
//
//  Created by lxxeugene on 2023/05/01.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [UNAuthorizationOptions.alert, UNAuthorizationOptions.sound,
            UNAuthorizationOptions.badge]) { (granted, error) in
            print("허용여부 \(granted), 오류 : \(error?.localizedDescription ?? "없음")")
        }
        
        if let navigationController: UINavigationController = self.window?.rootViewController as? UINavigationController,
           let memosTableViewController: MemosTableViewController = navigationController.viewControllers.first as?
            MemosTableViewController {
            
            UNUserNotificationCenter.current().delegate = memosTableViewController
        }
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    // MARK: - Core Data stack
    
}
