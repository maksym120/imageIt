//
//  localFeedTableViewCell.swift
//  imageIt
//
//  Created by Suresh on 7/25/16.
//  Copyright © 2016 Esbee ventures. All rights reserved.
//

import Foundation
import UIKit
import Firebase


class localFeedTableViewCell: UITableViewCell {

    var localUser: Posts!
    
    @IBOutlet weak var localCellImage: UIImageView!
    @IBOutlet weak var localCellComment: UILabel!
    
    
    @IBOutlet weak var choice1Label: UILabel!
    
    @IBOutlet weak var choice2Label: UILabel!
    
    @IBOutlet weak var choice3Label: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
    
    }
    
  
    
    
    func configureCell ( localUser: Posts ) {
    
        self.localUser = localUser
        
        localCellComment.numberOfLines = 0
        localCellComment.textColor = UIColor.darkGrayColor()
        localCellComment.font = localCellComment.font.fontWithSize(12)
//        localCellComment.text = localUser.userName + " says " + localUser.usercomment
        
        
//        let cellViewImage = localUser.userImage
//        let url = NSURL(string:cellViewImage)
//        
//        if ( url != nil) {
//            
//            let data = NSData(contentsOfURL: url!)
////            print ("ur; is \(url)")
//            localCellImage.image = UIImage ( data: data!)
//            
//            
//        }
//        else {
//            
//            let decodedData = NSData(base64EncodedString: cellViewImage, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
//            let decodedImage = UIImage(data: decodedData!)
//            localCellImage.image =  decodedImage
//            
//            
//        }
        

//        let decodedData = NSData(base64EncodedString: cellViewImage, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
//        let decodedImage = UIImage(data: decodedData!)
  
//        let itemSize = CGSizeApplyAffineTransform(decodedImage!.size, CGAffineTransformMakeScale(0.5, 0.5))
//        localCellImage.image =  decodedImage

        
        
        // fix image size in the cell.
        
        let itemSize = CGSizeMake(500, 500);
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.mainScreen().scale);
        let imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        localCellImage.image!.drawInRect(imageRect)
        localCellImage.image! = UIGraphicsGetImageFromCurrentImageContext()!;
        localCellImage.contentMode = .ScaleAspectFill  // scales image to fit correctly
        localCellImage.clipsToBounds = true
        
        UIGraphicsEndImageContext();
        

    }
    
    
    
}
