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
        return cell
    }
    
    @IBAction func choiceLiked (sender: UIButton) {
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0) // This defines what indexPath is which is used later to define a cell
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! CommentCell // This is where the magic happens - reference to the cell
        cell.lblVoteNum.text = "\(Int(cell.lblVoteNum.text!)! + 1)"
        self.updateSelectedChoice(cell.lblComment.text!)
    }

    func updateSelectedChoice(selectedChoice:String) {
        
        for each in globalPost.tempDict {
            
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
