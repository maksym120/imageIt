//
//  loginViewController.swift
//  imageIt
//
//  Created by Suresh on 7/15/16.
//  Copyright © 2016 Esbee ventures. All rights reserved.
//

import Foundation
import Firebase
import UIKit
import FBSDKLoginKit
import GoogleSignIn
import TwitterKit
import TwitterCore

class loginViewController: UIViewController,GIDSignInDelegate, GIDSignInUIDelegate /*,FBSDKLoginButtonDelegate */{
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var userEmailField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
//        
//        signInButton.style = .Wide
//        signInButton.frame = CGRectMake(0, 0, 200, 50)
//        self.view.addSubview(signInButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: Action
    // Pressing Enter after entering password triggers this action.
    @IBAction func passwordFieldActionTriggered(sender: AnyObject) {
        
        // Login function goes here.
        AppUtility.loginWithEmail(userEmailField.text!, password: passwordField.text!, compleionClosure: { (success) in
            if success {
                ApplicationDelegate.showTabBarController()
            }
        })
    }
    
    //separate button to log in already registered user for UI simplicity.
    @IBAction func logInAccount(sender: AnyObject) {
        
        if isInputValid() {
            AppUtility.loginWithEmail(userEmailField.text!, password: passwordField.text!, compleionClosure: { (success) in
                if success {
                    ApplicationDelegate.showTabBarController()
                }
            })
        }
    }
    
    @IBAction func facebookLogin(sender: AnyObject) {
        AppUtility.loginWithFacebook { (success) in
            if success {
                ApplicationDelegate.showTabBarController()
            }
        }
    }

    @IBAction func googleLogin(sender: AnyObject) {
        if googleIsSetup() {
            print("Google Is OK")
            GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
            GIDSignIn.sharedInstance().delegate = self
            GIDSignIn.sharedInstance().uiDelegate = self
            GIDSignIn.sharedInstance().signIn()
        }
    }

    @IBAction func twitterLogin(sender: UIButton) {
        Twitter.sharedInstance().logInWithCompletion { (session, error) in
            if let session = session {
                print("Twitter Login Ok.")
                let twitterToken = session.authToken
                let twitterSecret = session.authTokenSecret
                let credential = FIRTwitterAuthProvider.credentialWithToken(twitterToken, secret: twitterSecret)
                AppUtility.firebaseAuth(credential, completionClosure: { (success) in
                    if success {
                        ApplicationDelegate.showTabBarController()
                    }
                })
            }
        }
    }
    
    func googleIsSetup() -> Bool {
        let path = NSBundle.mainBundle().pathForResource("GoogleService-Info", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)
        let reversedClientId = dict?.objectForKey("REVERSED_CLIENT_ID") as! String
        let clientIdExists: Bool = dict?.objectForKey("CLIENT_ID") != nil
        let reversedClientIdExists: Bool = reversedClientId != ""
        let canOpenGoogle: Bool = UIApplication.sharedApplication().canOpenURL(NSURL(string: "\(reversedClientId)://")!)
        if clientIdExists {
            if reversedClientIdExists {
                if canOpenGoogle {
                    return true
                }
            }
        }
        
        return false
    }
    
    //MARK: Google Sign Protocol
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if let error = error {
            AppUtility.showAlert(error.localizedDescription, title: "Login Error")
        }
        
        let authentication = user.authentication
        let googleToken = authentication.idToken
        let accessToken = authentication.accessToken
        let credential = FIRGoogleAuthProvider.credentialWithIDToken(googleToken, accessToken: accessToken)
        AppUtility.firebaseAuth(credential) { (success) in
            if success {
                ApplicationDelegate.showTabBarController()
            }
        }
    }
    
    //MARK: Validation
    func isInputValid() -> Bool {
        if userEmailField.text == "" {
            AppUtility.showAlert("Email field is empty", title: "Notice")
            return false
        }
        if passwordField.text == "" {
            AppUtility.showAlert("Password field is empty", title: "Notice")
            return false
        }
//        if !isEmailValid(passwordField.text!) {
//            return false
//        }
        
        self.view.endEditing(true)
        return true
    }
    
    func isEmailValid(emailString: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if (emailTest.evaluateWithObject(emailString)) {
            return true
        }else {
            AppUtility.showAlert("Check your email and try again", title: "Email not valid")
            return false
        }
    }
}
