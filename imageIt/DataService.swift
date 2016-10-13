//
//  DataService.swift
//  imageIt
//
//  Created by Suresh on 7/16/16.
//  Copyright © 2016 Esbee ventures. All rights reserved.
//



import Foundation
import Firebase


class DataService {
    
    static let dataService = DataService()
    
    private var _BASE_REF = BASE_URL
    private var _USEREMAIL_REF = BASE_URL.child("email")
    private var _POST_REF = BASE_URL.child("Posts")
    private var _USERCOMMENTS_REF = BASE_URL.child("comments")
    private var _FOLLOWERS_REF = BASE_URL.child("followers")
    private var _USER_REF = BASE_URL.child("Users")
    
    var BASE_REF: FIRDatabaseReference {
        return _BASE_REF
    }
    
    var USEREMAIL_REF: FIRDatabaseReference {
        return _USEREMAIL_REF
    }
    
    var CURRENT_USER_REF: FIRDatabaseReference {
        let userID = NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String
        
        let currentUser = BASE_REF.child("users").child(userID)
        
        return currentUser
    }
    
    var POST_REF: FIRDatabaseReference {
        return _POST_REF
    }
    
    var USER_REF: FIRDatabaseReference {
        return _USER_REF
    }
    
    var USERCOMMENTS_REF: FIRDatabaseReference {
        return _USERCOMMENTS_REF
    }

    var FOLLOWERS_REF: FIRDatabaseReference {
        return _FOLLOWERS_REF
    }
    
    func createNewAccount(uid: String, user: Dictionary<String, String>) {
        
        // A User is born.
        
        USEREMAIL_REF.child(uid).setValue(user)
    }
    
    func createNewUser(user: Dictionary<String, AnyObject>) -> String {
        let firebaseNewUser = USER_REF.childByAutoId()
        
        firebaseNewUser.setValue(user)
        
        return firebaseNewUser.key
    }
    
    func createNewComment(post: Dictionary<String, AnyObject>) -> String {
        
        // Save the Joke
        // COMMENT_REF is the parent of the new Joke: "jokes".
        // childByAutoId() saves the joke and gives it its own ID.
        
        let firebaseNewPost = POST_REF.childByAutoId()
        
        // setValue() saves to Firebase.
        
        firebaseNewPost.setValue(post)
        
        
        return firebaseNewPost.key
        
        
    }
}
