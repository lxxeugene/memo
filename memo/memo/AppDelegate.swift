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
    // 애플리케이션 실행 직후 호출
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // User Notification Center를 통해서 노티피케이션 권한 획득
        let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [UNAuthorizationOptions.alert, UNAuthorizationOptions.sound,
            UNAuthorizationOptions.badge]) { (granted, error) in
            print("허용여부 \(granted), 오류 : \(error?.localizedDescription ?? "없음")")
        }
        // 맨처음 화면의 뷰 컨트롤러(memotableviewcontroller)를 UserNotification의 delegate로 설정
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





