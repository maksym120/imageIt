//
//  newUserViewController.swift
//  imageIt
//
//  Created by Suresh on 7/16/16.
//  Copyright © 2016 Esbee ventures. All rights reserved.
//

import Foundation
import Firebase
import UIKit



class newUserViewController: UIViewController {

    
    @IBOutlet weak var newUserNameField: UITextField!
    
    @IBOutlet weak var newUserPasswordField: UITextField!
    @IBOutlet weak var newUserEmailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: Action
    @IBAction func createAccount(sender: AnyObject) {
        
        if !isInputValid() {
            return
        }
        
        AppUtility.showActivityOverlay("")
        //Returns nil if user does not exist.
        FIRAuth.auth()?.createUserWithEmail(newUserEmailField.text!, password: newUserPasswordField.text! , completion: { (user, error) in
            
            AppUtility.hideActivityOverlay()
            if error != nil {
                
                print (error)
                print ("User already Exists")
            }
            else {
                
                print (error)
                print ("Created User")
                
                self.updateUserInfo()
                
                
                // create my follow users field
//                let currentUID = user?.uid
//                let newFollowed: Dictionary<String, AnyObject> = ["userId": currentUID!]
//                let refFollowedPath = BASE_URL.child("/Followed")
//                let refFollowed = refFollowedPath.childByAutoId()
//                refFollowed.setValue(newFollowed)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("loginViewIdentifier") 
                self.presentViewController(vc, animated: true, completion: nil)

            }
            
        })
        
    }


    func updateUserInfo() {
    
        let user = FIRAuth.auth()?.currentUser
        
        if let user = user {
            let changeRequest = user.profileChangeRequest()
            
            changeRequest.displayName = newUserNameField.text

            
            changeRequest.commitChangesWithCompletion { error in
                if let error = error {
                   
                    // An error happened.
                    print ("error is /(error)")
                    
                } else {
                    // Profile updated.
                }
            }
        }
    
    }
    
    
    //MARK: Validation
    func isInputValid() -> Bool {
        if newUserNameField.text == "" {
            AppUtility.showAlert("UserName field is empty", title: "Notice")
            return false
        }
        if newUserPasswordField.text == "" {
            AppUtility.showAlert("Password field is empty", title: "Notice")
            return false
        }
        if newUserEmailField.text == "" {
            AppUtility.showAlert("Email field is empty", title: "Notice")
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
