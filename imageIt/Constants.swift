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

let USER_EMAIL = "userEmail"
let USER_PASS = "userPassword"
let FB_TOKEN = "FBToken"
let GOOGLE_TOKEN = "GoogleToken"
let ACCESS_TOKEN = "AccessToken"
let TWITTER_TOKEN = "TwitterToken"
let TWITTER_SECRET = "TwitterSecret"

var currentUserEmail = "nil"
var currentUserName = "nil"
var currentUserID = ""
