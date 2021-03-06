//
//  AppDelegate.swift
//  Instagram
//
//  Created by 徐炜楠 on 2017/10/27.
//  Copyright © 2017年 xuweinan. All rights reserved.
//

import UIKit
import AVOSCloud

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        AVOSCloud.setApplicationId("QvjVufzK2Q3EGAUKEUwKa3HM-gzGzoHsz", clientKey: "fbNdi3mj1ABNjIxcxWCFAhtT")
        login()
        window?.backgroundColor = .white
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func login(){
        //获取UserDefaults中储存的Key为username的值
        let username:String? = UserDefaults.standard.string(forKey: "username")
        if username != nil{
            UserDefaults.standard.set(true, forKey: "online")
            print("已有默认用户")
            let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let myTabBar = storyboard.instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
            window?.rootViewController = myTabBar
        }
    }
    func offline(){
        guard !UserDefaults.standard.bool(forKey: "online") else {
            return
        }
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let ARVC = storyboard.instantiateViewController(withIdentifier: "ARImage")
        window?.rootViewController = ARVC
    }

}

