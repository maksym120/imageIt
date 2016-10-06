//
//  imageitViewController.swift
//  imageIt
//
//  Created by Suresh on 7/14/16.
//  Copyright © 2016 Esbee ventures. All rights reserved.
//

import Foundation
import Firebase

class imageItViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var currentImage: UIImageView!
    @IBOutlet weak var catPickerOutlet: UIPickerView!
    
    
    var base64String : String?
    var selectedCat: String = "Other"  // defaut is set to Other unless selected
    
    //    var postKey: String?
    
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    
    //    var commentsDict = Dictionary<String, String>() // declare empty dictionary to store user comments
    
    
    var userComments = [Posts]()
    var pickerCatDataSource = ["Clothes", "Automobile", "Vegetables", "Fruits","Toys","Electronics","Other"];
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set this controller as the camera delegate
        imagePicker.delegate = self
        
        
        //PickerView related code
        
        self.catPickerOutlet.dataSource = self;
        self.catPickerOutlet.delegate = self;
        catPickerOutlet.selectRow(pickerCatDataSource.count - 1, inComponent: 0, animated: true)
        // Load camera here when the tab bar item is clicked.
        [self.takePicture(self)]
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func takePicture(sender: AnyObject) {
        
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .Camera
                imagePicker.cameraCaptureMode = .Photo
                presentViewController(imagePicker, animated: true, completion: {})
            } else {
                postAlert("Rear camera doesn't exist", message: "Application cannot access the camera.")
            }
        } else {
            postAlert("Camera inaccessable", message: "Application cannot access the camera.")
        }
        
        
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("Got an image")
        self.catPickerOutlet.hidden = false // UnHide the picker menu
        
        if let pickedImage:UIImage = (info[UIImagePickerControllerOriginalImage]) as? UIImage {
            //        let selectorToCall = Selector("imageWasSavedSuccessfully:didFinishSavingWithError:context:")
            let selectorToCall = #selector(imageItViewController.imageWasSavedSuccessfully(_:didFinishSavingWithError:context:))
            UIImageWriteToSavedPhotosAlbum(pickedImage, self, selectorToCall, nil)
        }
        
        imagePicker.dismissViewControllerAnimated(true, completion: {
            
            
            // Anything you want to happen when the user saves an image -- Upload to Firebase.
            
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("User canceled image")
        dismissViewControllerAnimated(true, completion: {
            // Anything you want to happen when the user selects cancel
            
            self.catPickerOutlet.hidden = true // Hide the picker menu
            
            
            
        })
    }
    
    func imageWasSavedSuccessfully(image: UIImage, didFinishSavingWithError error: NSError!, context: UnsafeMutablePointer<()>){
        print("Image saved")
        if let theError = error {
            print("An error happened while saving the image = \(theError)")
        } else {
            print("Displaying")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                
                self.currentImage.image = image
                
            })
        }
    }
    
    
    
    
    func postAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    // add text to image
    
    
    func addTextToImage(text: NSString, inImage: UIImage, atPoint:CGPoint)     -> UIImage{
        
        // Setup the font specific variables
        let textColor = UIColor.whiteColor()
        let textFont = UIFont(name: "Helvetica Bold", size: 140)!
        
        
        //Setups up the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            ]
        
        // Create bitmap based graphics context
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)
        
        //Put the image into a rectangle as large as the original image.
        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
        
        
        // Our drawing bounds
        let drawingBounds = CGRectMake(0.0, 0.0, inImage.size.width, inImage.size.height)
        
        print ("drawing bounds is \(drawingBounds)")
        
        
        let textSize = text.sizeWithAttributes([NSFontAttributeName:textFont])
        let textRect = CGRectMake(atPoint.x, atPoint.y, textSize.width, textSize.height)
        //              let textRect = CGRectMake(drawingBounds.size.width/2 - textSize.width/2, drawingBounds.size.height/2 - textSize.height/2,
        //                                  textSize.width, textSize.height)
        
        print ("textrect is\(textRect)")
        
        text.drawInRect(textRect, withAttributes: textFontAttributes)
        
        // Get the image from the graphics context
        let newImag = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImag!
        
        
        
        //        // Create a point within the space that is as bit as the image
        //        let rect = CGRectMake(atPoint.x, atPoint.y, inImage.size.width, inImage.size.height)
        //
        //        // Draw the text into an image
        //        text.drawInRect(rect, withAttributes: textFontAttributes)
        //
        //        // Create a new image out of the images we have created
        //        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //
        //        // End the context now that we have the image we need
        //        UIGraphicsEndImageContext()
        //
        //        //Pass the image back up to the caller
        //        return newImage!
        
    }
    
    
    
    
    
    //picked delegate methods
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerCatDataSource.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerCatDataSource[row]
    }
    
    // determine which row is selected
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        /*
         if(row == 0)
         {
         
         print("Selected \(pickerCatDataSource[row])")
         selectedCat = pickerCatDataSource[row]
         
         }
         */
        print("Selected \(pickerCatDataSource[row])")
        selectedCat = pickerCatDataSource[row]
        
        
    }
    
    
    
    // UPload post to Firebase when user clicks Share Button
    
    @IBAction func sharePost(sender: AnyObject) {
        print("Sharing Now")
        
        // Prepare the image for upload
        var data: NSData = NSData()
        var modImage:UIImage
        var downloadURL:String = ""

        AppUtility.showActivityOverlay("")
        //Overlay text on image before upload
        if let image = self.currentImage.image {
            modImage = self.addTextToImage("What is this", inImage: image, atPoint: CGPointMake(200,2800))
            data = UIImageJPEGRepresentation(modImage,0.1)!
            
            // using FIrebase Storage to upload pics -- new code
            let imageName = NSUUID().UUIDString
            let storageRef = FIRStorage.storage().reference().child("posts").child("\(imageName).jpeg")
            // Upload the file to the path "images/rivers.jpg"
            let uploadTask = storageRef.putData(data, metadata: nil) { metadata, error in
                if (error != nil) {
                    // Uh-oh, an error occurred!
                    AppUtility.hideActivityOverlay()
                } else {
                    // Metadata contains file metadata such as size, content-type, and download URL.
                     downloadURL = (metadata!.downloadURL()?.absoluteString)!
                    print ("inside download url is \(downloadURL)")
                    
                    // we have the url for the image now and its been uploaded to firebase storage.
                    
                    let newPost: Dictionary<String,AnyObject> = [
                        "userEmail": currentUserEmail,
                        "comments": "Updating..",
                        "userName": currentUserName,
                        "userImage": /*base64String*/ downloadURL,
                        "category": self.selectedCat,
                        "userId": currentUserID
                    ]
                    
                    let postKey = DataService.dataService.createNewComment(newPost)
                    print ("refloc is \(postKey)")
                    
                    //update comment here
                    let newComment: Dictionary <String,AnyObject> = [
                        "userName" : currentUserName,
                        "userComment" : "What is this",
                        "Like" :-1,
                        "Dislike" : -1
                    ]
                    
                    let refCommentsPath = BASE_URL.child("/Posts/\(postKey)/comments/")
                    let refComments = refCommentsPath.childByAutoId()
                    refComments.setValue(newComment)
                    
                    let newFavorite = ["userId": ""]
                    let refFavoritePath = BASE_URL.child("/Posts/\(postKey)/favorites")
                    let refFavorites = refFavoritePath.childByAutoId()
                    refFavorites.setValue(newFavorite)

                    // Display globalView after sharing.
                    AppUtility.hideActivityOverlay()
                    ApplicationDelegate.showTabBarController()

                }
            }
        }
    }
}
