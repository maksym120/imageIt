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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    
    @IBAction func loadGlobaklFeedView(sender: AnyObject) {
        
        var fromFrame = self.followedViewContainer.frame
        var toFrame = self.globalViewContainer.frame
        
        fromFrame.origin.x = self.view.frame.size.width + 20
        toFrame.origin.x = -self.view.frame.size.width - 20
        
        self.globalViewContainer.frame = toFrame
        
        toFrame.origin.x = 0
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.globalViewContainer.frame = toFrame
            self.followedViewContainer.frame = fromFrame
            
                    })
    }
    
    
    @IBAction func loadFollowingView(sender: AnyObject) {
   
        var fromFrame = self.globalViewContainer.frame
        var toFrame = self.followedViewContainer.frame
        
        fromFrame.origin.x = -self.view.frame.size.width - 20
        toFrame.origin.x = self.view.frame.size.width + 20
        
        self.followedViewContainer.frame = toFrame
        
        toFrame.origin.x = 0
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            
            self.globalViewContainer.frame = fromFrame
            self.followedViewContainer.frame = toFrame
            
        })
    }
    
        
}
