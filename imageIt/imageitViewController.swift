//
//  imageitViewController.swift
//  imageIt
//
//  Created by Suresh on 7/14/16.
//  Copyright © 2016 Esbee ventures. All rights reserved.
//

import Foundation
import Firebase

class imageItViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var currentImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    
    private var sideSize: CGFloat!
    
    var base64String : String?
    var selectedCat: String = "Other"  // defaut is set to Other unless selected
    
    var selectedImage: UIImage!
    
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    
    var userComments = [Posts]()
    var pickerCatDataSource = ["Toys", "Electronics", "Furniture", "Clothes", "Food", "Apple", "Android", "Audio", "Jewellry", "Footwear", "Cars", "Accessories","Hats","Wedding","Home", "Other"];
    
    var isRefresh = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideSize = (UIScreen.mainScreen().bounds.width - 43) / 4
        collectionViewLayout.itemSize = CGSize(width: sideSize, height: 50)
        collectionViewLayout.minimumLineSpacing = 1
        collectionViewLayout.minimumInteritemSpacing = 1
        
        imagePicker.delegate = self
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if isRefresh {
            self.collectionView.reloadData()
            let indexPath = NSIndexPath(forItem: pickerCatDataSource.count - 1, inSection: 0)
            self.collectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.None)
        }
    }
    
    @IBAction func openLibrary(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
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
        
        if let pickedImage:UIImage = (info[UIImagePickerControllerOriginalImage]) as? UIImage {
            //        let selectorToCall = Selector("imageWasSavedSuccessfully:didFinishSavingWithError:context:")
            let selectorToCall = #selector(imageItViewController.imageWasSavedSuccessfully(_:didFinishSavingWithError:context:))
            UIImageWriteToSavedPhotosAlbum(pickedImage, self, selectorToCall, nil)
        }
        self.isRefresh = false
        imagePicker.dismissViewControllerAnimated(true, completion: {
            
            self.isRefresh = true
            // Anything you want to happen when the user saves an image -- Upload to Firebase.
            
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("User canceled image")
        self.isRefresh = false
        dismissViewControllerAnimated(true, completion: {
            // Anything you want to happen when the user selects cancel
            self.isRefresh = true
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
                self.selectedImage = image
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
        
    }
    
    //MARK: CollectionView Protocol
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pickerCatDataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CatCell", forIndexPath: indexPath) as! CatCell
        cell.catlabel.text = pickerCatDataSource[indexPath.row]
        cell.contentView.backgroundColor = UIColor.whiteColor()
        cell.catlabel.textColor = UIColor.blackColor()
        if (indexPath.row == pickerCatDataSource.count - 1) {
            cell.contentView.backgroundColor = COLOR_BLUE
            cell.catlabel.textColor = UIColor.whiteColor()
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedCat = pickerCatDataSource[indexPath.row]
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CatCell
        cell.contentView.backgroundColor = COLOR_BLUE
        cell.catlabel.textColor = UIColor.whiteColor()
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CatCell
        cell.contentView.backgroundColor = UIColor.whiteColor()
        cell.catlabel.textColor = UIColor.blackColor()
    }
    // UPload post to Firebase when user clicks Share Button
    @IBAction func sharePost(sender: AnyObject) {
        print("Sharing Now")
        
        if (selectedImage == nil) {
            AppUtility.showAlert("Please select Image", title: "Error")
            return
        }
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
                    var location = currentUser.userLocation
                    if location == "" {
                        location = "Unknown"
                    }
                    
                    let newPost: Dictionary<String,AnyObject> = [
                        "userEmail": currentUser.userEmail,
                        "comments": "Updating..",
                        "userName": currentUser.userName,
                        "userImage": downloadURL,
                        "profileImage": currentUser.profileURL,
                        "category": self.selectedCat,
                        "userId": currentUserID,
                        "location": location
                    ]
                    
                    let postKey = DataService.dataService.createNewComment(newPost)
                    print ("refloc is \(postKey)")
                    
                    //update comment here
                    let newComment: Dictionary <String,AnyObject> = [
                        "userName" : currentUser.userName,
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

class CatCell: UICollectionViewCell {
    @IBOutlet weak var catlabel: UILabel!
}
