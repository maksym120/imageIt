//
//  completeProfileViewController.swift
//  imageIt
//
//  Created by JCB on 10/12/16.
//  Copyright © 2016 Esbee ventures. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class completeProfileViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtBirthday: UITextField!
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var profileTopSpaceConstraint: NSLayoutConstraint!
    
    var currentTextFeild:UITextField!
    let locationManager = CLLocationManager()
    let imagePicker = UIImagePickerController()
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtUserName.text = userName
        txtUserName.userInteractionEnabled = false
        txtLocation.userInteractionEnabled = false
        
        txtUserName.delegate = self
        txtEmail.delegate = self
        
        imgProfilePic.clipsToBounds = true
        imgProfilePic.layer.cornerRadius = imgProfilePic.frame.size.width / 2
        
        locationManager.delegate = self
        imagePicker.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
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
        let textY = self.view.bounds.size.height - currentTextFeild.frame.origin.y
        
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
        currentTextFeild = textField
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == txtUserName {
            txtEmail.becomeFirstResponder()
        }
        else if textField == txtEmail {
            txtEmail.resignFirstResponder()
        }
        return true
    }
    
    //MARK: location manager protocol
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
                    self.txtLocation.text = "\(city) \(pm.postalCode! as String)"
                }
            }
            else {
                print("Problem with the data received from geocoder")
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
    
    //MARK: ImagePicker Controller Protocol
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("Got an image")
        
        if let pickedImage:UIImage = (info[UIImagePickerControllerOriginalImage]) as? UIImage {
            imgProfilePic.image = pickedImage
        }
        
        imagePicker.dismissViewControllerAnimated(true, completion: {
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("User canceled image")
        dismissViewControllerAnimated(true, completion: {
            // Anything you want to happen when the user selects cancel
            
        })
    }
    
    //MARK: Date Picker
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        txtBirthday.text = dateFormatter.stringFromDate(sender.date)
        
    }
    
    func donePicker() {
        txtBirthday.resignFirstResponder()
    }

    func openLibrary() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: Action
    @IBAction func birthDayEditing(sender: UITextField) {
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
    
    @IBAction func onProfilePicBtnClick(sender: AnyObject) {
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
    @IBAction func onCompleteBtnClick(sender: AnyObject) {
        if !isInputValid() {
            return
        }
        
        var data: NSData = NSData()
        var downloadURL:String = ""
        
        data = UIImageJPEGRepresentation(imgProfilePic.image!,0.1)!
        
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
                    "userEmail": self.txtEmail.text!,
                    "userName": self.txtUserName.text!,
                    "userImage": downloadURL,
                    "userBirth": self.txtBirthday.text!,
                    "userLocation": self.txtLocation.text!,
                    "userId": currentUserID
                ]
                
                let userKey = DataService.dataService.createNewUser(newUser)
                print(userKey)
                UserDefaults.setObject(userKey, forKey: "userKey")
                isComplete = true
                ApplicationDelegate.showTabBarController()
            }
        }

    }
    
    //MARK: Validation
    func isInputValid() -> Bool {
        if txtEmail.text == "" {
            AppUtility.showAlert("Password field is empty", title: "Notice")
            txtEmail.becomeFirstResponder()
            return false
        }
        if txtBirthday.text == "" {
            AppUtility.showAlert("Email field is empty", title: "Notice")
            txtBirthday.becomeFirstResponder()
            return false
        }
        
        self.view.endEditing(true)
        return true
    }

}
