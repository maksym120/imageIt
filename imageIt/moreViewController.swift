//
//  moreViewController.swift
//  imageIt
//
//  Created by Suresh on 7/16/16.
//  Copyright © 2016 Esbee ventures. All rights reserved.
//

import Foundation
import Firebase
import UIKit

class moreViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{

    var moreViewArray = ["LogOut","Purchase Pro", "My Profile","Display Image", "CloudSync","Ranking"]
    
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //TableView code
    
    //TavleView protocols
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return moreViewArray.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("moreCell", forIndexPath: indexPath) /* as! UITableViewCell */

        let rowItem = moreViewArray[indexPath.row]
        
        cell.textLabel?.text = rowItem
        

        
        return cell
        
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        print("row clicked is \(indexPath.row)")
        
        if (indexPath.row == 0) {
        
        //Log out the user here
            AppUtility.logout()
        }
        
        
    }


}
