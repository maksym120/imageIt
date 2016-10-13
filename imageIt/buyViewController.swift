//
//  buyViewController.swift
//  imageIt
//
//  Created by Suresh B on 9/8/16.
//  Copyright © 2016 Esbee ventures. All rights reserved.
//

import Foundation
import UIKit


class buyViewController: UIViewController, UITableViewDelegate {

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func onBackBtnClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: TableView Protocol
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     
        print(" In buy custom cell")
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("buyCellViewIdentifier") as? buyViewControllerCell {

            
        return cell
        
        }
        else {
            
            return buyViewControllerCell()
            
        }
    }
}
