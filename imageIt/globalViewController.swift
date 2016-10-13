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
    
    var commentLimit: UInt = 2
    var loadNum: UInt = 0
    
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
    
    //MARK: add Comment
    @IBAction func addComment(sender: UIButton) {
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0) // This defines what indexPath is which is used later to define a cell. Look in cellforrowatindexpath for additional line to detect the clicked cell.
        let customCell = tableView.cellForRowAtIndexPath(indexPath) as! globalFeedTableViewCell! // This is where the magic happens - reference to the cell
        let selectedComment = globalPost[sender.tag]
        
    //addup all comments here.
        if ( customCell.globalTextField.text != "") {
            
            let addComment =  customCell.globalTextField.text!
            customCell.globalTextField.text = ""
            
            //Every new comment has 0 likes and dislikes.
            globalCommentsDict["userName"] = currentUser.userName
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
    
    //MARK: UpVote
    @IBAction func choice1Liked (sender: UIButton) {
        
        if sender.selected {
            return
        }
        
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0) // This defines what indexPath is which is used later to define a cell
        let customCell = tableView.cellForRowAtIndexPath(indexPath) as! globalFeedTableViewCell! // This is where the magic happens - reference to the cell
        
        // Now search the comments and if there is a match, update the Like option.
        if customCell.choice1Label.text! == "Choice 1" {
            return
        }
        self.updateSelectedChoice(customCell.choice1Label.text!, tag: sender.tag)
        sender.selected = !sender.selected
        
    }

    @IBAction func choice2Liked (sender: UIButton) {
        if sender.selected {
            return
        }
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0) // This defines what indexPath is which is used later to define a cell
        let customCell = tableView.cellForRowAtIndexPath(indexPath) as! globalFeedTableViewCell! // This is where the magic happens - reference to the cell
        if customCell.choice2Label.text! == "Choice 2" {
            return
        }
        self.updateSelectedChoice(customCell.choice2Label.text!, tag: sender.tag)
        
        sender.selected = !sender.selected
    }
    
    func updateSelectedChoice(selectedChoice:String, tag:Int) {
        let indexPath = NSIndexPath(forRow: tag, inSection: 0) // This defines what indexPath is which is used later to define a cell
        let customCell = tableView.cellForRowAtIndexPath(indexPath) as! globalFeedTableViewCell! // This is where the magic happens - reference to the cell
        let selectedComment = globalPost[tag]
        
        for each in customCell.globalPost.tempDict {
            
            if ( each.1["userComment"]  as! String == selectedChoice) {
                let newLike = ["userId": currentUserID]
                let refLikePath = BASE_URL.child("/Posts/\(selectedComment.commentKey)/comments/\(each.0)/likes")
                let refLikes = refLikePath.childByAutoId()
                refLikes.setValue(newLike)
                
                // This transaction just updates the Like number in Firebase.
                DataService.dataService.POST_REF.child(selectedComment.commentKey).child("comments").child(each.0).child("Like").runTransactionBlock({ (currentData:FIRMutableData) -> FIRTransactionResult in
                    currentData.value = currentData.value  as! Int + 1
                    return FIRTransactionResult.successWithValue(currentData)
                })
            }
        }
    }

    //MARK: Follow Post
    func followPost (sender: UIButton) {
        let selectedComment = globalPost[sender.tag]
        
        if !sender.selected {
            let newFavorite = ["userId": currentUserID]
            let refFavoritePath = BASE_URL.child("/Posts/\(selectedComment.commentKey)/favorites")
            let refFavorites = refFavoritePath.childByAutoId()
            refFavorites.setValue(newFavorite)
            sender.selected = !sender.selected
        }
        else {
            let favorite = ["userId": currentUserID]
            let keys = (selectedComment.favoriteDict as NSDictionary).allKeysForObject(favorite)
            
            for key in keys {
                let refFollowPath = BASE_URL.child("/Posts/\(selectedComment.commentKey)/favorites/\(key as! String)")
                refFollowPath.removeValue()
                sender.selected = !sender.selected
            }
        }
    }
    
    //MARK: Follow User
    func followUser(sender: UIButton) {
        let selectedComment = globalPost[sender.tag]
        if sender.selected {
            let follow = ["userId": currentUserID]
            let keys = (selectedComment.followDict as NSDictionary).allKeysForObject(follow)
            
            for key in keys {
                let refFollowPath = BASE_URL.child("/Posts/\(selectedComment.commentKey)/followers/\(key as! String)")
                refFollowPath.removeValue()
                sender.selected = !sender.selected            }
        }
        else {
            let newFollow = ["userId": currentUserID]
            let refFollowPath = BASE_URL.child("/Posts/\(selectedComment.commentKey)/followers")
            let refFollows = refFollowPath.childByAutoId()
            refFollows.setValue(newFollow)
            sender.selected = !sender.selected
        }
    }
    
    //MARK: Select Buy Button
    func choice1Buy(sender: UIButton) {
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0) // This defines what indexPath is which is used later to define a cell
        let customCell = tableView.cellForRowAtIndexPath(indexPath) as! globalFeedTableViewCell! // This is where the magic happens - reference to the cell
        if customCell.choice1Label.text! == "Choice 1" {
            return
        }
        
        self.performSegueWithIdentifier("showBuy", sender: nil)
    }
    
    func choice2Buy(sender: UIButton) {
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0) // This defines what indexPath is which is used later to define a cell
        let customCell = tableView.cellForRowAtIndexPath(indexPath) as! globalFeedTableViewCell! // This is where the magic happens - reference to the cell
        if customCell.choice2Label.text! == "Choice 2" {
            return
        }
        self.performSegueWithIdentifier("showBuy", sender: nil)
    }
    
    //MARK: TableView Protocol
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return globalPost.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
        print(comment.favoriteDict)
        let favorite = ["userId": currentUserID]
        let keys = (comment.favoriteDict as NSDictionary).allKeysForObject(favorite)
        
        let followKeys = (comment.followDict as NSDictionary).allKeysForObject(favorite)
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("globalViewCell") as? globalFeedTableViewCell {
            
            cell.configureCell(comment)
            
            if (cellViewImage != "") {
                if UIImage.isCached(cellViewImage) {
                    let image = UIImage.cachedImageWithURL(cellViewImage)
                    if (image != nil) {
                        cell.globalImageView.image = image
                    }
                }
                else {
                    cell.globalImageView.sd_setImageWithURL(NSURL(string: cellViewImage))
                }
            }
            if (comment.profileImage != "") {
                if UIImage.isCached(comment.profileImage) {
                    let image = UIImage.cachedImageWithURL(comment.profileImage)
                    if (image != nil) {
                        cell.profileImageView.image = image
                    }
                }
                else {
                    cell.profileImageView.sd_setImageWithURL(NSURL(string: comment.profileImage))
                }
            }
            cell.globalTextField.delegate = self  // return key dismisses keyboard
            
            cell.geoLocationLabel.text = comment.location
            
            // this code is for selecting a choice and incrementing the Likes and Dislikes in a given cell.
            cell.globalSendButton.tag = indexPath.row  // detect row the click came from
            cell.globalSendButton.addTarget(self, action: #selector(globalViewController.addComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.choice1LikeButton.tag = indexPath.row // detect row the click came from
            cell.choice1LikeButton.addTarget(self, action: #selector(globalViewController.choice1Liked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.choice2LikeButton.tag = indexPath.row // detect row the click came from
            cell.choice2LikeButton.addTarget(self, action: #selector(globalViewController.choice2Liked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.likeButton.tag = indexPath.row
            cell.likeButton.addTarget(self, action: #selector(globalViewController.followPost(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.commentButton.tag = indexPath.row
            
            cell.followButton.tag = indexPath.row
            cell.followButton.addTarget(self, action: #selector(globalViewController.followUser(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.choice1BuyButton.tag = indexPath.row
            cell.choice1BuyButton.addTarget(self, action: #selector(globalViewController.choice1Buy(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.choice2BuyButton.tag = indexPath.row
            cell.choice2BuyButton.addTarget(self, action: #selector(globalViewController.choice2Buy(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            if comment.userId == currentUserID {
                cell.followButton.hidden = true
            }
            
            if (followKeys.count > 0) {
                cell.followButton.selected = true
            }
            else {
                cell.followButton.selected = false
            }
            
            if keys.count > 0 {
                cell.likeButton.selected = true
            }
            //Update choise labels here after they have been sorted.
            
            if (self.choicePost.count > 0 ) {
                cell.choice1Label.text = self.choicePost[0]["userComment"] as? String
                cell.voteNum1.text = "\(self.choicePost[0]["Like"] as! Int)"
                cell.voteNum2.text = "0"
                
                if (self.choicePost[0]["likes"] != nil) {
                    var likesDict: Dictionary = Dictionary <String, AnyObject>()
                    likesDict = (self.choicePost[0]["likes"] as? Dictionary <String, AnyObject>)!
                    print(likesDict)
                    let like = ["userId": currentUserID]
                    let likeKeys = (likesDict as NSDictionary).allKeysForObject(like)
                    if (likeKeys.count > 0) {
                        cell.choice1LikeButton.selected = true
                    }
                    else {
                        cell.choice1LikeButton.selected = false
                    }
                }
            }
            if (self.choicePost.count > 1) {
                cell.choice2Label.text = self.choicePost[1]["userComment"] as? String

                cell.voteNum2.text = "\(self.choicePost[1]["Like"] as! Int)"
                
                if (self.choicePost[1]["likes"] != nil) {
                    let likesDict = self.choicePost[1]["likes"] as? Dictionary <String, AnyObject>
                    print(likesDict)
                    let like = ["userId": currentUserID]
                    let likeKeys = (likesDict! as NSDictionary).allKeysForObject(like)

                    if (likeKeys.count > 0) {
                        cell.choice2LikeButton.selected = true
                    }
                    else {
                        cell.choice2LikeButton.selected = false
                    }
                }
            }
            
            cell.lblComments.text = "\(comment.tempDict.count - 1)"
            cell.favoriteNum.text = "\(comment.favoriteDict.count - 1)"

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
        if (segue.identifier == "showMoreComment") {
            let index = (sender as! UIButton).tag
            if segue.destinationViewController.isKindOfClass(MoreCommentViewController) {
                (segue.destinationViewController as! MoreCommentViewController).globalPost = globalPost[index]
            }
        }
        else if (segue.identifier == "showBuy") {
            print("BUY 2 Button pressed")
        }
    }
    
    
    //MARK: Load Data from Firebase
    func loadDataFromFirebase() {
        print("Global: Loading data from Firebase")
        if loadNum == 0 {
            AppUtility.showActivityOverlay("")
        }
        commentLimit = commentLimit + (2 * loadNum)
        let lastestComments = DataService.dataService.POST_REF.queryLimitedToLast(commentLimit)
        
        lastestComments.observeEventType(.Value, withBlock: { snapshot in
            AppUtility.hideActivityOverlay()
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
                        self.preLoadImage(userPost.profileImage)
                    }
                }
            }
            // Be sure that the tableView updates when there is new data.
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
            if UInt(self.globalPost.count) == self.commentLimit {
                self.loadNum = self.loadNum + 1
                self.loadDataFromFirebase()
            }
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

