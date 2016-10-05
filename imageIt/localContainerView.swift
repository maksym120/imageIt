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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    
    @IBAction func loadMyPostsView(sender: AnyObject) {
        
//        UIView.animatewithDuration(0.5, animations: {
//            self.conateinerMyPostsView.alpha = 1
//            self.containerFavView.alpha = 0
//        })
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            //changes to animate
            
            self.conateinerMyPostsView.alpha = 1
            self.containerFavView.alpha = 0

        })

        
    }
    
    
    @IBAction func loadFavView(sender: AnyObject) {
    

        UIView.animateWithDuration(1.0, animations: { () -> Void in
            //changes to animate
            
            self.conateinerMyPostsView.alpha = 0
            self.containerFavView.alpha = 1
            
        })

    
    }
    
}
