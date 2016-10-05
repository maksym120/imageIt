//
//  BaseTabBarController.swift
//  imageIt
//
//  Created by Suresh on 8/8/16.
//  Copyright © 2016 Esbee ventures. All rights reserved.
//

import Foundation
import UIKit

class BaseTabBarController: UITabBarController {
    
    

    @IBInspectable var defaultIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = defaultIndex
    }
 
    
    
    /*
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        //  Set camera index to the index on your tabbar
        let cameraIndex = 2
        if item == (self.tabBar.items! as [UITabBarItem])[cameraIndex] {
            //  Call Camera
            print(" Camera Tab Bar here")

            
            
        
        }
    }
    
    */
    
    
    
}

//Obtained from here - http://stackoverflow.com/questions/13136699/setting-the-default-tab-when-using-storyboards
//Obtained from http://stackoverflow.com/questions/36628411/how-do-i-open-camera-from-tab-bar




