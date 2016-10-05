//
//  globalViewController.swift
//  imageIt
//
//  Created by Suresh on 7/14/16.
//  Copyright © 2016 Esbee ventures. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class globalViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate  {
    

    var globalPost = [Posts]()
    
    var choicePost = [ Dictionary<String, AnyObject>() ] // use this to store comments sorted by Likes
    
    var globalComment : String!  // use this to store updated comment.
    var globalCommentsDict = Dictionary<String, AnyObject>() // declare empty dictionary to store user comments

    var cache:NSCache!
    
    @IBOutlet weak var tableView: UITableView!
    
    var refresher: UIRefreshControl!
    
    // pull to refresh function
    func refresh() {
        print("Refreshed")
        self.loadDataFromFirebase()
        self.refresher.endRefreshing()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dispatch_async(dispatch_get_main_queue(), {
                self.loadDataFromFirebase()
        })
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initiate cache
        self.cache = NSCache()
        
        //setup cell height here to auto size
        tableView.estimatedRowHeight = 330
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // This enables PUll to refresh.
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refresher.addTarget(self, action: #selector(globalViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // User adds comments to global feed.
    @IBAction func addComment(sender: UIButton) {
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0) // This defines what indexPath is which is used later to define a cell. Look in cellforrowatindexpath for additional line to detect the clicked cell.
        let customCell = tableView.cellForRowAtIndexPath(indexPath) as! globalFeedTableViewCell! // This is where the magic happens - reference to the cell
        let selectedComment = globalPost[sender.tag]
        
    //addup all comments here.
        if ( customCell.globalTextField.text != "") {
            
            var addComment =  customCell.globalTextField.text!
            
            //Every new comment has 0 likes and dislikes.
            globalCommentsDict["userName"] = currentUserName
            globalCommentsDict["userComment"] = addComment
            globalCommentsDict["Like"] = 0
            globalCommentsDict["Dislike"] = 0
            
            globalComment = globalComment.stringByAppendingString(addComment)
            print ("global comment is \(globalComment)")
            
            // this appends comments to the firebase database.
            let refCommentsPath = BASE_URL.child("/Posts/\(selectedComment.commentKey)/comments/")
            let refComments = refCommentsPath.childByAutoId()
            refComments.setValue(globalCommentsDict)
            
            //reload table with updated comments.
            self.tableView.reloadData()
            
        
        } else {
            print ("No text entered")
            
            let alert = UIAlertController(title: "Oops", message: "Please enter some text before hitting Send", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Understood", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func choice1Liked (sender: UIButton) {
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0) // This defines what indexPath is which is used later to define a cell
        let customCell = tableView.cellForRowAtIndexPath(indexPath) as! globalFeedTableViewCell! // This is where the magic happens - reference to the cell
        let selectedComment = globalPost[sender.tag]
        
        // Now search the comments and if there is a match, update the Like option.
        self.updateSelectedChoice(customCell.choice1Label.text!, tag: sender.tag)
     
        
    }

    @IBAction func choice2Liked (sender: UIButton) {
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0) // This defines what indexPath is which is used later to define a cell
        let customCell = tableView.cellForRowAtIndexPath(indexPath) as! globalFeedTableViewCell! // This is where the magic happens - reference to the cell
        self.updateSelectedChoice(customCell.choice2Label.text!, tag: sender.tag)
    }

    func followPost (sender: UIButton) {
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0) // This defines what indexPath is which is used later to define a cell
        let customCell = tableView.cellForRowAtIndexPath(indexPath) as! globalFeedTableViewCell! // This is where the magic happens - reference to the cell
        let selectedComment = globalPost[sender.tag]

        if !sender.selected {
            let newFollower = ["userId": currentUserID]
            let refFollowPath = BASE_URL.child("/Posts/\(selectedComment.commentKey)/followers")
            let refFollowers = refFollowPath.childByAutoId()
            refFollowers.setValue(newFollower)
            sender.selected = !sender.selected
        }
        else {
            let follower = ["userId": currentUserID]
            let keys = (selectedComment.followerDict as? NSDictionary)?.allKeysForObject(follower)
            
            for key in keys! {
                let refFollowPath = BASE_URL.child("/Posts/\(selectedComment.commentKey)/followers/\(key as! String)")
                print("/Posts/\(selectedComment.commentKey)/followers\(key as! String)")
                refFollowPath.removeValue()
                sender.selected = !sender.selected
            }
        }
        
        
    }
    
    func updateSelectedChoice(selectedChoice:String, tag:Int) {
        let indexPath = NSIndexPath(forRow: tag, inSection: 0) // This defines what indexPath is which is used later to define a cell
        let customCell = tableView.cellForRowAtIndexPath(indexPath) as! globalFeedTableViewCell! // This is where the magic happens - reference to the cell
        let selectedComment = globalPost[tag]
        
        for each in customCell.globalPost.tempDict {
            let tempDict = each.1 as? Dictionary<String,AnyObject>
            
            if ( each.1["userComment"]  as! String == selectedChoice) {
                // This transaction just updates the Like number in Firebase.
                DataService.dataService.POST_REF.child(selectedComment.commentKey).child("comments").child(each.0).child("Like").runTransactionBlock({ (currentData:FIRMutableData) -> FIRTransactionResult in
                    currentData.value = currentData.value  as! Int + 1
                    return FIRTransactionResult.successWithValue(currentData)
                })
            }
        }
    }

    //MARK: TableView Protocol
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return globalPost.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        globalComment = ""
        self.choicePost = []
        
        let comment = globalPost[indexPath.row]
        
        print(comment.tempDict)
        for each in comment.tempDict {
            print(each)
            let tempDict = each.1 as? Dictionary<String,AnyObject>
            globalComment = globalComment.stringByAppendingString( "\n" + (tempDict!["userName"]! as! String) + " says " + (tempDict!["userComment"]! as! String))
           
            // ignore "What is this" and dont add it to the choice array
            if (tempDict!["userComment"] as! String !=  "What is this") {
                self.choicePost.append(tempDict!)
            }
        }
        
        let cellViewImage = comment.userImage
        //Sort in place based on Likes for a given choice.
        self.choicePost.sortInPlace{ ($0["Like"]! as! Int) < ($1["Like"] as! Int) }
        self.choicePost = self.choicePost.reverse()
        
        // isFollowed by Me?
        let follower = ["userId": currentUserID]
        let keys = (comment.followerDict as? NSDictionary)?.allKeysForObject(follower)
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("globalViewCell") as? globalFeedTableViewCell {
            if (cellViewImage != "") {
                if UIImage.isCached(cellViewImage) {
                    let image = UIImage.cachedImageWithURL(cellViewImage)
                    if (image != nil) {
                        cell.globalImageView.image = image
                    }
                }
                else {
                    cell.globalImageView.setImageWithURL(NSURL(string: cellViewImage))
                }
            }
            cell.globalTextField.delegate = self  // return key dismisses keyboard

            // this code is for selecting a choice and incrementing the Likes and Dislikes in a given cell.
            cell.globalSendButton.tag = indexPath.row  // detect row the click came from
            cell.globalSendButton.addTarget(self, action: #selector(globalViewController.addComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.choice1LikeButton.tag = indexPath.row // detect row the click came from
            cell.choice1LikeButton.addTarget(self, action: #selector(globalViewController.choice1Liked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.choice2LikeButton.tag = indexPath.row // detect row the click came from
            cell.choice2LikeButton.addTarget(self, action: #selector(globalViewController.choice2Liked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.likeButton.tag = indexPath.row
            cell.likeButton.addTarget(self, action: #selector(globalViewController.followPost(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            if keys?.count > 0 {
                cell.likeButton.selected = true
            }
            //Update choise labels here after they have been sorted.
            if (self.choicePost.count == 1 ) {
                cell.choice1Label.text = self.choicePost[0]["userComment"] as? String
            }
            else if (self.choicePost.count == 2) {
                cell.choice1Label.text = self.choicePost[0]["userComment"] as? String
                cell.choice2Label.text = self.choicePost[1]["userComment"] as? String
            }
            
            cell.lblComments.text = "\(comment.tempDict.count - 1)"
            cell.configureCell(comment)
            
            return cell
        }
        else {
            return globalFeedTableViewCell()
        }
    }

    
    //MARK: TextField Protocol
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // override segue and determine whcih buy button was pressed.
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if (segue.identifier == "buy1Segue") {
            print("BUY 1 Button pressed")
        }
        else if (segue.identifier == "buy2Segue") {
            print("BUY 2 Button pressed")
        }
        else if (segue.identifier == "buy3Segue") {
        print("BUY 3 Button pressed")
        }
    }
    
    
    //Load data from Firebase
    func loadDataFromFirebase() {
        print("Global: Loading data from Firebase")
        AppUtility.showActivityOverlay("")
        DataService.dataService.POST_REF.observeEventType(.Value, withBlock: { snapshot in
            self.globalPost = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    
                    // Make our comments array for the tableView.
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let userPost = Posts(key: key, dictionary: postDictionary)
    
                        // Items are returned chronologically, but it's more fun with the newest comments first.
                        self.globalPost.insert(userPost, atIndex: 0)
                        self.preLoadImage(userPost.userImage)
                    }
                }
            }
            AppUtility.hideActivityOverlay()
            // Be sure that the tableView updates when there is new data.
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        })
    }

    func preLoadImage(image: String) {
        if (image != "") {
            dispatch_async(dispatch_get_main_queue(), {
                UIImage.cachedImageWithURL(image)
            })
        }
    }
}

