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
    
//    @IBOutlet weak var globalCommentLabel: UILabel!
    
    @IBOutlet weak var globalTextField: UITextField!
    
    @IBOutlet weak var globalSendButton: UIButton!
    
    
    @IBOutlet weak var choice1Label: UILabel!
    
    @IBOutlet weak var choice2Label: UILabel!
    
//    @IBOutlet weak var choice3Label: UILabel!
    
    
    @IBOutlet weak var choice1LikeButton: UIButton!
    
    @IBOutlet weak var choice2LikeButton: UIButton!
    
    @IBOutlet weak var choice3LikeButton: UIButton!
    
    @IBOutlet weak var choice1disLikeButton: UIButton!
    
    @IBOutlet weak var choice2disLikeButton: UIButton!
    
//    @IBOutlet weak var choice3disLikeButton: UIButton!
    
    
    @IBOutlet weak var geoLocationLabel: UILabel!
    
    @IBOutlet weak var globalSponsorButton: UIButton!
    
    @IBOutlet weak var nearbyQButton: UIButton!
    
    @IBOutlet weak var globalPosterNameLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var lblComments: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell ( globalPost: Posts ) {
        
        self.globalPost = globalPost

        globalPosterNameLabel.text = globalPost.userName + " posted"

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
        
        UIGraphicsEndImageContext()
    }
}