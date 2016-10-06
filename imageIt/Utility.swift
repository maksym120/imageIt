//
//  Utility.swift
//  imageIt
//
//  Created by MAX on 9/29/16.
//  Copyright © 2016 Esbee ventures. All rights reserved.
//

import UIKit
import MRProgress
import Firebase
import Reachability
import FBSDKLoginKit
import GoogleSignIn

let AppUtility = Utility.sharedInstance

class Utility: NSObject {
    
    var activityOverlay:MRProgressOverlayView!
    
    let reachability = Reachability(hostName: "google.com")
    
    class var sharedInstance :Utility {
        struct Singleton {
            static let instance = Utility()
        }
        return Singleton.instance
    }

    override init() {
    
    }
    
    func showAlert(message:String, title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okButton)
        topViewController().presentViewController(alertController, animated: true, completion: nil)
    }

    func showActivityOverlay(text: String) {
        if activityOverlay == nil {
            activityOverlay = MRProgressOverlayView.showOverlayAddedTo(UIApplication.sharedApplication().keyWindow, animated: true)
        }
        
        activityOverlay.titleLabelText = text
        activityOverlay.tintColor = UIColor.darkGrayColor()
    }
    
    func hideActivityOverlay() {
        dispatch_async(dispatch_get_main_queue(), {
            if self.activityOverlay != nil {
                self.activityOverlay.dismiss(true)
            }
            
            self.activityOverlay = nil
        })
    }
    
    func topViewController() -> UIViewController {
        return topViewControllerWithRootViewController(UIApplication.sharedApplication().keyWindow!.rootViewController!)
    }
    
    func topViewControllerWithRootViewController(rootViewController:UIViewController) -> UIViewController {
        if rootViewController.isKindOfClass(UITabBarController) {
            let tabBarController = rootViewController as! UITabBarController
            return self.topViewControllerWithRootViewController(tabBarController.selectedViewController!)
        }else if rootViewController.isKindOfClass(UINavigationController) {
            let navController = rootViewController as! UINavigationController
            return self.topViewControllerWithRootViewController(navController.visibleViewController!)
        }else if (rootViewController.presentedViewController != nil) {
            let presentedViewController = rootViewController.presentedViewController
            return self.topViewControllerWithRootViewController(presentedViewController!)
        }else{
            return rootViewController
        }
    }
    
    func loginWithEmail(email: String, password: String, compleionClosure: ((success: Bool) -> () )) {
        if isInternetConnectionNotActive() {
            compleionClosure(success: false)
            return
        }
        
        showActivityOverlay("")
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { user, error in
            self.hideActivityOverlay()
            if error != nil {
                print("Incorrect")
                print (error)
                compleionClosure(success: false)
                self.showAlert("Login Failed. Please try again.", title: "Login Error")
                return
            }
            else {
                currentUserID = user!.uid
                if let username = user?.displayName {
                    currentUserName = username
                }
                if let useremail = user?.email {
                    currentUserEmail = useremail
                }
                compleionClosure(success: true)
            }
            
        })
    }
    
    func loginWithFacebook(completionClosure: ((success: Bool) -> () )) {
        
        if isInternetConnectionNotActive() {
            completionClosure(success: false)
            return
        }
        
        let facebookLogin = FBSDKLoginManager()
        print("Logging in")
        
        facebookLogin.logInWithReadPermissions(["public_profile", "email", "user_friends"], handler:{(facebookResult, facebookError) -> Void in
            
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
                self.hideActivityOverlay()
                self.showAlert("Facebook Login is failed", title: "Login Error")
                completionClosure(success: false)
                return
            }
                
            else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
                self.hideActivityOverlay()
                self.showAlert("Facebook Login is cencelled", title: "Login Error")
                completionClosure(success: false)
                return
            }
                
            else {
                print("You’re inz and result is \(facebookResult.description) ;)")
                let fbToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Facebook Access Token : \(fbToken)")
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(fbToken)
                self.firebaseAuth(credential, completionClosure: { (success) in
                    completionClosure(success: true)
                })
            }
            
        });
    }
    
    func firebaseAuth(credential: FIRAuthCredential, completionClosure: ((success: Bool) -> () )) {
        self.showActivityOverlay("")
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            self.hideActivityOverlay()
            if (error == nil) {
                print("SUCESS")
                completionClosure(success: true)
                currentUserID = user!.uid
                if let username = user?.displayName {
                    currentUserName = username
                }
                if let useremail = user?.email {
                    currentUserEmail = useremail
                }
//                
//                let newFollowed: Dictionary<String, AnyObject> = ["userId": currentUserID]
//                let refFollowedPath = BASE_URL.child("/Followed")
//                let refFollowed = refFollowedPath.childByAutoId()
//                refFollowed.setValue(newFollowed)
            }
            else {
                print(error?.description)
                self.showAlert("Login Failed. Please try again.", title: "Login Error")
                completionClosure(success: false)
            }
        }
    }
    
    func logout() {
        try! FIRAuth.auth()!.signOut()
        print ("Logging user Out")
        UserDefaults.removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
        UserDefaults.synchronize()
        ApplicationDelegate.showLoginViewController()
    }
    
    func isInternetConnectionNotActive() -> Bool {
        let networkStatus = reachability.currentReachabilityStatus()
        
        if networkStatus == NetworkStatus.NotReachable {
            showAlert("Please check your internet connection and try again", title: "No Internet connection")
            return true
        }
        else {
            return false
        }
    }
}
