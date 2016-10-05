//
//  localViewController.swift
//  imageIt
//
//  Created by Suresh on 7/14/16.
//  Copyright © 2016 Esbee ventures. All rights reserved.
//

import Foundation
import Firebase
import UIKit


class localViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate  {
    
    var userComments = [Posts]()
    var localUserComments = [Posts]()  // use this to filter posts only posted by current user
    var localComment: String!
    var choicePost = [ Dictionary<String, AnyObject>() ] // use this to store comments sorted by Likes

    @IBOutlet weak var tableView: UITableView!
    
    var refresher: UIRefreshControl!
    
    // pull to refresh function
    func refresh() {
        print("Refreshed")
        self.loadDataFromFirebase()  // Load data from Firebase
        self.refresher.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Do any additional setup after loading the view, typically from a nib.
        print ("Logged in user is \(currentUserName)")
        dispatch_async(dispatch_get_main_queue(), {
            self.loadDataFromFirebase()
        })

        // This enables PUll to refresh.
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refresher.addTarget(self, action: #selector(localViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //TableView code
    
    //TavleView protocols
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userComments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let comment = userComments[indexPath.row]
        localComment = ""
        self.choicePost = []

        for each in comment.tempDict {
            let tempDict = each.1 as? Dictionary<String,AnyObject>
            
            localComment = localComment.stringByAppendingString( "\n" + (tempDict!["userName"]! as! String) + " says " + (tempDict!["userComment"]! as! String))
            
            // ignore "What is this" and dont add it to the choice array
            
            if (tempDict!["userComment"] as! String !=  "What is this") {
                
                self.choicePost.append(tempDict!)
            }
        }
        

        //Sort in place based on Likes for a given choice.
        self.choicePost.sortInPlace{ ($0["Like"]! as! Int) < ($1["Like"] as! Int) }
        self.choicePost = self.choicePost.reverse()
        
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("localTableViewCell") as? localFeedTableViewCell {

            //load image
            let cellViewImage = comment.userImage
            
            if (cellViewImage != "") {
                if UIImage.isCached(cellViewImage) {
                    let image = UIImage.cachedImageWithURL(cellViewImage)
                    if image != nil {
                        cell.localCellImage.image = image
                    }
                }
                else {
                    cell.localCellImage.setImageWithURL(NSURL(string: cellViewImage))
                }
            }
            
            //set up label for multilne mode.
            cell.localCellComment.sizeToFit()
            cell.localCellComment.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell.localCellComment.numberOfLines = 0
            
            cell.localCellComment.text = localComment
            
            if (self.choicePost.count == 1 ) {
                cell.choice1Label.text = self.choicePost[0]["userComment"] as? String
            }
            else if (self.choicePost.count == 2) {
                
                cell.choice1Label.text = self.choicePost[0]["userComment"] as? String
                cell.choice2Label.text = self.choicePost[1]["userComment"] as? String
            }
                
            else if (self.choicePost.count == 3) {
                
                cell.choice1Label.text = self.choicePost[0]["userComment"] as? String
                cell.choice2Label.text = self.choicePost[1]["userComment"] as? String
                cell.choice3Label.text = self.choicePost[2]["userComment"] as? String
            }

            cell.configureCell(comment)
            
            return cell
     
            
        }
        else {
            return localFeedTableViewCell()
        }
    }

    //DEBUG
    @IBAction func retrieveImage(sender: AnyObject) {
        self.tableView.reloadData()
    }

    //Load data from Firebase
    
    func loadDataFromFirebase() {
        
        print("Local: Loading data from Firebase")
        AppUtility.showActivityOverlay("")
        DataService.dataService.POST_REF.observeEventType(.Value, withBlock: { snapshot in
            self.userComments = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    // Make our comments array for the tableView.
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let userComment = Posts(key: key, dictionary: postDictionary)
                        
                        // Items are returned chronologically, but it's more fun with the newest comments first.
                        
                        // only add to the array if the username on the uploaded image matches current username
                        
                        if (userComment.userName == currentUserName) {
                            self.userComments.insert(userComment, atIndex: 0)
                        }
                        
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
}
