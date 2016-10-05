//
//  RecViewController.swift
//  imageIt
//
//  Created by Suresh on 7/14/16.
//  Copyright © 2016 Esbee ventures. All rights reserved.
//

import Foundation
import UIKit

class recViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    //TavleView protocols
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        

        if let cell = tableView.dequeueReusableCellWithIdentifier("recViewCellIdentifier") as? recViewControllerCell {
            
        return cell
        
    }
        
        else {
        
        return recViewControllerCell()
        
        }
    
    
    }


}
