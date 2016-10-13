//
//  AppDelegate.swift
//  imageIt
//
//  Created by Suresh on 7/14/16.
//  Copyright © 2016 Esbee ventures. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import GoogleSignIn
import TwitterKit
import Fabric

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Firebase setup
        FIRApp.configure()
//        //facebook setup
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        Fabric.with([Twitter.self()])
//        let key = NSBundle.mainBundle().objectForInfoDictionaryKey("consumerKey")
//        let secret = NSBundle.mainBundle().objectForInfoDictionaryKey("consumerSecret")
//        if key != nil && secret != nil {
//            Twitter.sharedInstance().startWithConsumerKey(key as! String, consumerSecret: secret as! String)
//            
//        }
        
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if let user = user {
                currentUserID = user.uid
                DataService.dataService.USER_REF.queryOrderedByChild("userId").queryEqualToValue(currentUserID).observeEventType(.Value, withBlock: { (snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                        for snap in snapshots {
                            if let userDictionary = snap.value as? Dictionary<String, AnyObject> {
                                currentUser.userEmail = userDictionary["userEmail"] as! String
                                currentUser.userName = userDictionary["userName"] as! String
                                currentUser.userBirth = userDictionary["userBirth"] as! String
                                currentUser.profileURL = userDictionary["userImage"] as! String
                                currentUser.userId = userDictionary["userId"] as! String
                                currentUser.userLocation = userDictionary["userLocation"] as! String
                                print(currentUser)
                                self.showTabBarController()
                            }
                        }
                    } else {
                        print("we don't have that, add it to the DB now")
                    }
                })
            } else {
                self.showLoginViewController()
            }
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
          FBSDKAppEvents.activateApp()
    
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

  
    func application(application: UIApplication,
                     openURL url: NSURL,
                             sourceApplication: String?,
                             annotation: AnyObject) -> Bool {
        
        if ((url.scheme?.hasPrefix("fb")) == true) {
            return FBSDKApplicationDelegate.sharedInstance().application(
                application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
        }
        
        return GIDSignIn.sharedInstance().handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
        
    }
    
    
    func showTabBarController() {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let newRootController = storyboard.instantiateViewControllerWithIdentifier("tabBarIdentifier")
        window?.rootViewController = newRootController
    }
    
    func showLoginViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let newRootController = storyboard.instantiateViewControllerWithIdentifier("loginViewIdentifier")
        window?.rootViewController = newRootController
    }
}

