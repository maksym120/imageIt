//
//  Constants.swift
//  imageIt
//
//  Created by Suresh on 7/16/16.
//  Copyright © 2016 Esbee ventures. All rights reserved.
//

import Foundation
import Firebase

let BASE_URL = FIRDatabase.database().reference()
let UserDefaults = NSUserDefaults.standardUserDefaults() as NSUserDefaults
let NotificationCenter = NSNotificationCenter.defaultCenter() as NSNotificationCenter
let ApplicationDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

let COLOR_BLUE = UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1.0)

let USER_EMAIL = "userEmail"
let USER_PASS = "userPassword"
let FB_TOKEN = "FBToken"
let GOOGLE_TOKEN = "GoogleToken"
let ACCESS_TOKEN = "AccessToken"
let TWITTER_TOKEN = "TwitterToken"
let TWITTER_SECRET = "TwitterSecret"

var userName = ""
var currentUserID = ""
var currentUser: User! = User()
var isComplete = false
