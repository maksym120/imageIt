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
import CoreLocation


class newUserViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate {

    
    @IBOutlet weak var newUserPic: UIImageView!
    @IBOutlet weak var newUserNameField: UITextField!
    @IBOutlet weak var newUserPasswordField: UITextField!
    @IBOutlet weak var newUserEmailField: UITextField!
    @IBOutlet weak var newUserBirth: UITextField!
    @IBOutlet weak var newUserLocation: UITextField!
    @IBOutlet weak var profileTopSpaceConstraint: NSLayoutConstraint!
    
    var currentTextField:UITextField!
    
    let locationManager = CLLocationManager()
    
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        newUserNameField.delegate = self
        newUserPasswordField.delegate = self
        newUserEmailField.delegate = self
        
        newUserPic.clipsToBounds = true
        newUserPic.layer.cornerRadius = newUserPic.frame.size.width / 2
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        newUserLocation.userInteractionEnabled = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(completeProfileViewController.keyboardWillShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(completeProfileViewController.keyboardWillHide(_:)), name: UIKeyboardDidHideNotification, object: nil)
    }
    
    //MARK: Keyboard Show/Hide
    func keyboardWillShow(notification:NSNotification) {
        adjustingHeight(true, notification: notification)
    }
    
    func keyboardWillHide(notification:NSNotification) {
        adjustingHeight(false, notification: notification)
    }
    
    func adjustingHeight(show:Bool, notification:NSNotification) {
        var userInfo = (notification as NSNotification).userInfo!
        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let textY = self.view.bounds.size.height - currentTextField.frame.origin.y
        
        if show {
            if (textY > keyboardFrame.height + 30) {
                return
            }
            
            let changeHeight = (keyboardFrame.height + 30 - textY) * (show ? -1 : 1)
            
            UIView.animateWithDuration(animationDuration) {
                self.profileTopSpaceConstraint.constant += changeHeight
            }
        }
        else {
            UIView.animateWithDuration(animationDuration, animations: { 
                self.profileTopSpaceConstraint.constant = 15
            })
        }
    }
    
    //MARK: TextFeild Protocol.
    func textFieldDidBeginEditing(textField: UITextField) {
        currentTextField = textField
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == newUserNameField {
            newUserEmailField.becomeFirstResponder()
        }
        else if textField == newUserEmailField {
            newUserPasswordField.becomeFirstResponder()
        }
        else if textField == newUserPasswordField {
            newUserPasswordField.resignFirstResponder()
        }
        return true
    }
    
    //MARK: Location Manager Protocol
    func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError?) {
        print("Error while updating location " + error!.localizedDescription)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!) { (placemarks, error) in
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0] as CLPlacemark
                print(pm)
                if let city = pm.addressDictionary!["City"] as? NSString {
                    self.newUserLocation.text = "\(city) \(pm.postalCode! as String)"
                }
            }
            else {
                print("Problem with the data received from geocoder")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: Action
    @IBAction func onBackBtnClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
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
                
                self.addNewUser()
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("loginViewIdentifier") 
                self.presentViewController(vc, animated: true, completion: nil)

            }
            
        })
    }
    
    func addNewUser() {
        let user = FIRAuth.auth()?.currentUser
        currentUserID = (user?.uid)!
        var data: NSData = NSData()
        var downloadURL:String = ""
        
        data = UIImageJPEGRepresentation(newUserPic.image!,0.1)!
        
        AppUtility.showActivityOverlay("")
        let imageName = NSUUID().UUIDString
        let storageRef = FIRStorage.storage().reference().child("users").child("\(imageName).jpeg")

        let uploadTask = storageRef.putData(data, metadata: nil) { metadata, error in
            AppUtility.hideActivityOverlay()
            if (error != nil) {
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                downloadURL = (metadata!.downloadURL()?.absoluteString)!
                print ("inside download url is \(downloadURL)")
                
                // we have the url for the image now and its been uploaded to firebase storage.
                
                let newUser: Dictionary<String,AnyObject> = [
                    "userEmail": self.newUserEmailField.text!,
                    "userName": self.newUserNameField.text!,
                    "userImage": downloadURL,
                    "userBirth": self.newUserBirth.text!,
                    "userLocation": self.newUserLocation.text!,
                    "userId": currentUserID
                ]
                
                let userKey = DataService.dataService.createNewUser(newUser)
                print(userKey)
                UserDefaults.setObject(userKey, forKey: "userKey")
            }
        }
    }

    func takePicture() {
        
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .Camera
                imagePicker.cameraCaptureMode = .Photo
                presentViewController(imagePicker, animated: true, completion: {})
            } else {
                AppUtility.showAlert("Application cannot access the camera.", title: "Rear camera doesn't exist")
            }
        } else {
            AppUtility.showAlert("Application cannot access the camera.", title: "Camera inaccessable")
        }
    }

    func openLibrary() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func onBtnUserPicClick(sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let doCamera = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: { (alertButton:UIAlertAction) -> Void in
            self.takePicture()
        })
        doCamera.setValue(UIColor.redColor(), forKey: "titleTextColor")
        alertController.addAction(doCamera)
        
        let doLibrary = UIAlertAction(title: "Library", style: UIAlertActionStyle.Default, handler: { (alertButton:UIAlertAction) -> Void in
            self.openLibrary()
        })
        alertController.addAction(doLibrary)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil)
        alertController.addAction(cancelButton)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: ImagePicker Controller Protocol
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("Got an image")
        
        if let pickedImage:UIImage = (info[UIImagePickerControllerOriginalImage]) as? UIImage {
            //        let selectorToCall = Selector("imageWasSavedSuccessfully:didFinishSavingWithError:context:")
            newUserPic.image = pickedImage
        }
        
        imagePicker.dismissViewControllerAnimated(true, completion: {
            
            
            // Anything you want to happen when the user saves an image -- Upload to Firebase.
            
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("User canceled image")
        dismissViewControllerAnimated(true, completion: {
            // Anything you want to happen when the user selects cancel
            
        })
    }


    //MARK: BirthDay
    @IBAction func textFieldEditing(sender: UITextField) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePicker
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(donePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        sender.inputAccessoryView = toolBar
        
        datePicker.addTarget(self, action: #selector(newUserViewController.datePickerValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        newUserBirth.text = dateFormatter.stringFromDate(sender.date)
        
    }
    
    func donePicker() {
        newUserBirth.resignFirstResponder()
    }
    
    func updateUserInfo() {
    
        let user = FIRAuth.auth()?.currentUser
        
        if let user = user {
            let changeRequest = user.profileChangeRequest()
            
            changeRequest.displayName = newUserNameField.text
            
            changeRequest.commitChangesWithCompletion { error in
                if error != nil {
                   
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
            newUserNameField.becomeFirstResponder()
            return false
        }
        if newUserPasswordField.text == "" {
            AppUtility.showAlert("Password field is empty", title: "Notice")
            newUserPasswordField.becomeFirstResponder()
            return false
        }
        if newUserEmailField.text == "" {
            AppUtility.showAlert("Email field is empty", title: "Notice")
            newUserEmailField.becomeFirstResponder()
            return false
        }
        if newUserBirth.text == "" {
            AppUtility.showAlert("BirthDay field is empty", title: "Notice")
            newUserBirth.becomeFirstResponder()
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
