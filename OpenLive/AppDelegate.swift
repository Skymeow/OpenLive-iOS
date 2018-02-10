//
//  AppDelegate.swift
//  OpenLive
//
//  Created by GongYuhua on 6/25/16.
//  Copyright © 2016 Agora. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import FBSDKCoreKit
import FBSDKLoginKit
import Google
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        /* Facebook login */
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
    
    //    MARK: for FBSDK
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        
        return handled
    }
    
    func application(application: UIApplication,
                     openURL url: NSURL, options: [String: AnyObject]) -> Bool {
        
        return GIDSignIn.sharedInstance().handle(url as URL!,
                                                 sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication.rawValue] as? String,
                                                 annotation: options[UIApplicationOpenURLOptionsKey.annotation.rawValue])
    }
    
    //    MARK: connectToSocket
    func applicationDidBecomeActive(_ application: UIApplication) {
      SocketService.instance.establishConnection()
    }
    
    //    MARK: leave Socket
    func applicationWillTerminate(_ application: UIApplication) {
        SocketService.instance.closeConnection()
    }
}
