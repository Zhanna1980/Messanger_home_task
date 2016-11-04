//
//  User.swift
//  Lesson 15 - Messanger
//
//  Created by Zhanna Libman on 04/09/2016.
//  Copyright © 2016 Zhanna Libman. All rights reserved.
//

import Foundation
class User {
    fileprivate var _name: String;
    fileprivate var _ConversationWithUser:[Message];
    
    static var currentUser: [String : String] =
        [
        "userName" : "userName",
        "password" : "password"
    ]
    
    static var allUsers = [String : User]();
    
    static var friendsList: [User] = [User]();
    
    init (senderName: String){
        self._name = senderName;
        _ConversationWithUser = [Message]();
    }
    
    var name: String{
        get{
            return _name;
        }
        set{
            if !newValue.isEmpty{
                _name = newValue;
            }
        }
    }
    
    var ConversationWithUser: [Message]{
        get{
            return _ConversationWithUser;
        }
        set{
            _ConversationWithUser = newValue;
        }
    }
    
}
