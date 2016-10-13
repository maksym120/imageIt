//
//  MoreCommentViewController.swift
//  imageIt
//
//  Created by JCB on 10/6/16.
//  Copyright © 2016 Esbee ventures. All rights reserved.
//

import UIKit
import Firebase

class MoreCommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var choicePost = [ Dictionary<String, AnyObject>() ]
    var globalPost: Posts!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.choicePost = []
        for each in globalPost.tempDict {
            print(each)
            let tempDict = each.1 as? Dictionary<String,AnyObject>
            
            if (tempDict!["userComment"] as! String !=  "What is this") {
                self.choicePost.append(tempDict!)
            }
        }

        self.choicePost.sortInPlace{ ($0["Like"]! as! Int) < ($1["Like"] as! Int) }
        self.choicePost = self.choicePost.reverse()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choicePost.count - 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
        
        cell.lblComment.text = choicePost[indexPath.row + 2]["userComment"] as? String
        cell.lblVoteNum.text = "\(choicePost[indexPath.row + 2]["Like"] as! Int)"
        cell.btnVote.tag = indexPath.row
        cell.btnVote.addTarget(self, action: #selector(MoreCommentViewController.choiceLiked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.btnVote.setImage(UIImage(named: "like-neutral.png"), forState: UIControlState.Normal)
        cell.btnVote.setImage(UIImage(named: "liked.png"), forState: UIControlState.Selected)
        
        if (choicePost[indexPath.row + 2]["likes"] != nil) {
            var likesDict: Dictionary = Dictionary <String, AnyObject>()
            likesDict = (self.choicePost[indexPath.row + 2]["likes"] as? Dictionary <String, AnyObject>)!
            print(likesDict)
            let like = ["userId": currentUserID]
            let likeKeys = (likesDict as NSDictionary).allKeysForObject(like)
            if (likeKeys.count > 0) {
                cell.btnVote.selected = true
            }
            else {
                cell.btnVote.selected = false
            }
        }
        return cell
    }
    
    @IBAction func choiceLiked (sender: UIButton) {
        if sender.selected {
            return
        }
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0) // This defines what indexPath is which is used later to define a cell
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! CommentCell // This is where the magic happens - reference to the cell
        cell.lblVoteNum.text = "\(Int(cell.lblVoteNum.text!)! + 1)"
        self.updateSelectedChoice(cell.lblComment.text!)
        sender.selected = !sender.selected
    }

    func updateSelectedChoice(selectedChoice:String) {
        
        for each in globalPost.tempDict {
            let newLike = ["userId": currentUserID]
            let refLikePath = BASE_URL.child("/Posts/\(globalPost.commentKey)/comments/\(each.0)/likes")
            let refLikes = refLikePath.childByAutoId()
            refLikes.setValue(newLike)
            
            if ( each.1["userComment"]  as! String == selectedChoice) {
                // This transaction just updates the Like number in Firebase.
                DataService.dataService.POST_REF.child(globalPost.commentKey).child("comments").child(each.0).child("Like").runTransactionBlock({ (currentData:FIRMutableData) -> FIRTransactionResult in
                    currentData.value = currentData.value  as! Int + 1
                    return FIRTransactionResult.successWithValue(currentData)
                })
            }
        }
    }
    @IBAction func onCloseBtnClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

class CommentCell: UITableViewCell {
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblVoteNum: UILabel!
    @IBOutlet weak var btnVote: UIButton!
}
