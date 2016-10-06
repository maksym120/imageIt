//
//  globalViewContainer.swift
//  imageIt
//
//  Created by Suresh B on 9/25/16.
//  Copyright © 2016 Esbee ventures. All rights reserved.
//


import UIKit


class globalContainerViewController: UIViewController {
    
    
    @IBOutlet weak var globalViewContainer: UIView!
    
    @IBOutlet weak var followedViewContainer: UIView!
    
    var bGlobal = true
    var kColor: UIColor!
    
    @IBOutlet weak var followingBorder: UIView!
    @IBOutlet weak var globalBorder: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kColor = globalBorder.backgroundColor
        followingBorder.backgroundColor = UIColor.whiteColor()
    }
    

    
    @IBAction func loadGlobaklFeedView(sender: AnyObject) {
        
        if (bGlobal) {
            return
        }
        var fromFrame = self.followedViewContainer.frame
        var toFrame = self.globalViewContainer.frame
        
        fromFrame.origin.x = self.view.frame.size.width + 20
        toFrame.origin.x = -self.view.frame.size.width - 20
        
        self.globalViewContainer.frame = toFrame
        
        toFrame.origin.x = 0
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.globalViewContainer.frame = toFrame
            self.followedViewContainer.frame = fromFrame
            
        })
        
        followingBorder.backgroundColor = UIColor.whiteColor()
        globalBorder.backgroundColor = kColor
        bGlobal = true
    }
    
    
    @IBAction func loadFollowingView(sender: AnyObject) {
   
        if !bGlobal {
            return
        }
        
        var fromFrame = self.globalViewContainer.frame
        var toFrame = self.followedViewContainer.frame
        
        fromFrame.origin.x = -self.view.frame.size.width - 20
        toFrame.origin.x = self.view.frame.size.width + 20
        
        self.followedViewContainer.frame = toFrame
        
        toFrame.origin.x = 0
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            
            self.globalViewContainer.frame = fromFrame
            self.followedViewContainer.frame = toFrame
            
        })
        
        globalBorder.backgroundColor = UIColor.whiteColor()
        followingBorder.backgroundColor = kColor
        bGlobal = false
    }
    
        
}
