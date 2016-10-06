//
//  localContainerView.swift
//  imageIt
//
//  Created by Suresh B on 9/23/16.
//  Copyright © 2016 Esbee ventures. All rights reserved.
//

import UIKit


class localContainerViewController: UIViewController {
    
    
    
    @IBOutlet weak var containerFavView: UIView!
    @IBOutlet weak var conateinerMyPostsView: UIView!
    
    @IBOutlet weak var myPostBorder: UIView!
    @IBOutlet weak var favoriteBorder: UIView!
    var gLocal = true
    var kColor : UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        kColor = myPostBorder.backgroundColor
        favoriteBorder.backgroundColor = UIColor.whiteColor()
    }

    
    
    @IBAction func loadMyPostsView(sender: AnyObject) {

        if (gLocal) {
            return
        }
        var fromFrame = self.containerFavView.frame
        var toFrame = self.conateinerMyPostsView.frame
        
        fromFrame.origin.x = self.view.frame.size.width + 20
        toFrame.origin.x = -self.view.frame.size.width - 20
        
        self.conateinerMyPostsView.frame = toFrame
        
        toFrame.origin.x = 0
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.conateinerMyPostsView.frame = toFrame
            self.containerFavView.frame = fromFrame
            
        })
        
        favoriteBorder.backgroundColor = UIColor.whiteColor()
        myPostBorder.backgroundColor = kColor
        gLocal = true
    }
    
    
    @IBAction func loadFavView(sender: AnyObject) {
        
        if (!gLocal) {
            return
        }
        
        var fromFrame = self.conateinerMyPostsView.frame
        var toFrame = self.containerFavView.frame
        
        fromFrame.origin.x = -self.view.frame.size.width - 20
        toFrame.origin.x = self.view.frame.size.width + 20
        
        self.containerFavView.frame = toFrame
        
        toFrame.origin.x = 0
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            
            self.conateinerMyPostsView.frame = fromFrame
            self.containerFavView.frame = toFrame
            
        })
    
        myPostBorder.backgroundColor = UIColor.whiteColor()
        myPostBorder.backgroundColor = kColor
        gLocal = false
    }
    
}
