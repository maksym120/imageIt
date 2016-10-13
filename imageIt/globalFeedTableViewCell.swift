//
//  globalFeedTableViewCell.swift
//  imageIt
//
//  Created by Suresh on 7/26/16.
//  Copyright © 2016 Esbee ventures. All rights reserved.
//

import Foundation
import UIKit
import Firebase


class globalFeedTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    var globalPost: Posts!
    
    var currentPostComment: String!  // use this to get the comments for a particular post.
    
    @IBOutlet weak var globalImageView: UIImageView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var globalTextField: UITextField!
    
    @IBOutlet weak var globalSendButton: UIButton!
    
    
    @IBOutlet weak var choice1Label: UILabel!
    
    @IBOutlet weak var choice2Label: UILabel!
    
    
    @IBOutlet weak var choice1LikeButton: UIButton!
    
    @IBOutlet weak var choice2LikeButton: UIButton!
    
    @IBOutlet weak var choice1BuyButton: UIButton!
    
    @IBOutlet weak var choice2BuyButton: UIButton!
    
    @IBOutlet weak var geoLocationLabel: UILabel!
    
    @IBOutlet weak var globalSponsorButton: UIButton!
    
    @IBOutlet weak var nearbyQButton: UIButton!
    
    @IBOutlet weak var globalPosterNameLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var lblComments: UILabel!
    @IBOutlet weak var voteNum1: UILabel!
    @IBOutlet weak var voteNum2: UILabel!
    @IBOutlet weak var favoriteNum: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell ( globalPost: Posts ) {
        
        self.globalPost = globalPost

        if globalPost.userName == "nil"
        {
            globalPosterNameLabel.text = globalPost.useremail + " posted"
        }
        else {
            globalPosterNameLabel.text = globalPost.userName + " posted"
        }

        // fix image size in the cell.
        let itemSize = CGSizeMake(500, 500);

        
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.mainScreen().scale);
        let imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        
        if ( globalImageView.image != nil) {
        
            globalImageView.image!.drawInRect(imageRect)
            globalImageView.image = UIGraphicsGetImageFromCurrentImageContext();
            globalImageView.contentMode = .ScaleAspectFill  // scales image to fit correctly
            globalImageView.clipsToBounds = true
        
        }
        else {
            print ("Image not found")
            let imageNotFound:UIImage = UIImage(named:"placeholder.png")!
            globalImageView.image = imageNotFound
            globalImageView.image!.drawInRect(imageRect)
            globalImageView.image = UIGraphicsGetImageFromCurrentImageContext();
            globalImageView.contentMode = .ScaleAspectFill  // scales image to fit correctly
            globalImageView.clipsToBounds = true
        
        }
        
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        
        // this rounds the label corners
        geoLocationLabel.layer.masksToBounds = true
        geoLocationLabel.layer.cornerRadius = 8.0
        
        // this rounds UIButton
//        globalSponsorButton.backgroundColor = UIColor.blueColor()
        globalSponsorButton.layer.cornerRadius = 5
        globalSponsorButton.layer.borderWidth = 0.5
        globalSponsorButton.layer.borderColor = UIColor.blueColor().CGColor

        nearbyQButton.layer.cornerRadius = 5
        nearbyQButton.layer.borderWidth = 0.5
        nearbyQButton.layer.borderColor = UIColor.blueColor().CGColor
        
        followButton.setImage(UIImage(named: "follow.png"), forState: UIControlState.Normal)
        followButton.setImage(UIImage(named: "following.png"), forState: UIControlState.Selected)
        
        likeButton.setImage(UIImage(named: "Favorite-default.png"), forState: UIControlState.Normal)
        likeButton.setImage(UIImage(named: "Favorite.png"), forState: UIControlState.Selected)
        
        choice1LikeButton.setImage(UIImage(named: "like-neutral.png"), forState: UIControlState.Normal)
        choice1LikeButton.setImage(UIImage(named: "liked.png"), forState: UIControlState.Selected)
        
        choice2LikeButton.setImage(UIImage(named: "like-neutral.png"), forState: UIControlState.Normal)
        choice2LikeButton.setImage(UIImage(named: "liked.png"), forState: UIControlState.Selected)
        
        lblComments.text = "0"
        favoriteNum.text = "0"
        voteNum1.text = "0"
        voteNum2.text = "0"
        choice1Label.text = "Choice 1"
        choice2Label.text = "Choice 2"
        choice1LikeButton.selected = false
        choice2LikeButton.selected = false
        followButton.hidden = false
        followButton.selected = false
        likeButton.selected = false
        
        UIGraphicsEndImageContext()
    }
}
