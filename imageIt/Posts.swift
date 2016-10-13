//
//  Posts.swift
//  imageIt
//
//  Created by Suresh on 7/16/16.
//  Copyright © 2016 Esbee ventures. All rights reserved.
//

import Foundation
import Firebase


class Posts {
    
    var _commentRef: FIRDatabaseReference!
    var _commentKey: String!
    
    // Every commentRef has a username,email and the comment text.
    //    var _username: String!
    var _useremail: String!
    var _usercomment: String!
    var _userImage: String!
    var _userName: String!
    var _postCat: String!
    var _userId: String!
    var _profileImage: String!
    var _location: String!
//    var commentsDict:tempCommentsDict!
    
    var _tempDict: Dictionary = Dictionary<String, AnyObject>()
    var _favoriteDict: Dictionary = Dictionary<String, AnyObject>()
    var _followDict: Dictionary = Dictionary<String, AnyObject>()
    
    var tempDict: Dictionary <String,AnyObject> {
    
        return _tempDict
    
    }
    
    var favoriteDict: Dictionary <String, AnyObject> {
        return _favoriteDict
    }
    
    var followDict: Dictionary <String, AnyObject> {
        return _followDict
    }
    
    var commentKey: String {
        
        return _commentKey
    }
    
    var postCat: String {

        return _postCat
    }
    
    
    
    var useremail:String {
        
        return _useremail
    }
    

    var userImage:String {
        
        return _userImage
        
    }
    
    var userName:String {
        
        return _userName
        
    }

    var userId: String {
        return _userId
    }
    
    var profileImage: String {
        return _profileImage
    }
    
    var location: String {
        return _location
    }
    
    //init the class here
    init ( key: String, dictionary: Dictionary<String,AnyObject>) {
        
        self._commentKey = key
        
        if let userEmail = dictionary["userEmail"] as? String {
            
            self._useremail = userEmail
            
        }
        
 
        if let  userImage = dictionary["userImage"] as? String {
            
            self._userImage = userImage
            
        }
        
        if let userName = dictionary["userName"] as? String {
            
            self._userName = userName
            
        }
        
        if let userId = dictionary["userId"] as? String {
            self._userId = userId
        }
        
        if let postCat = dictionary["category"] as? String {
            
            self._postCat = postCat
            
        }

        if let profileImage = dictionary["profileImage"] as? String {
            self._profileImage = profileImage
        }
        
        if let location = dictionary["location"] as? String {
            self._location = location
        }
        
        if let tempDict = dictionary["comments"] as? Dictionary <String,AnyObject> {
        
            
            self._tempDict = tempDict
        
        }
        
        if let favoriteDict = dictionary["favorites"] as? Dictionary <String, AnyObject> {
            
            self._favoriteDict = favoriteDict
        }
        
        if let followDict = dictionary["followers"] as? Dictionary <String, AnyObject> {
            self._followDict = followDict
        }
        
        self._commentRef = DataService.dataService.POST_REF.child(self._commentKey)
        
    }
    
    
}


/*
class CommentsDict {
    
    
    var globalCommentKey: String!
    var globalCommentUserName: String!
    var globalcomment: String!
    var globalLike: Int!
    var globalDisLike: Int!
    
    init ( key: String, dictionary: Dictionary<String,AnyObject>) {
        
        globalCommentKey = key
        
        globalCommentUserName = dictionary["userName"] as? String
        
        globalcomment = dictionary["userComment"] as? String
        
        globalLike = dictionary["like"] as? Int
        
        globalDisLike = dictionary["dislike"] as? Int
        
    }

    
    
}

*/
 
// this dict stores the choice and displays the labels and actions
class choiceDict {

    var Like: Int = 0
    var Dislike: Int = 0
    var _userComment: String!
    var userName: String!
    
    var userComment:String {
        
        return _userComment
        
    }
    
    init (dictionary: Dictionary<String,AnyObject>) {
        
        if let userComment = dictionary["userComment"] as? String {
            
            self._userComment = userComment
            
        }
    }
}




