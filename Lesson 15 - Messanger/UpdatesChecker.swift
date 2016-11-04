//
//  UpdatesChecker.swift
//  Lesson 15 - Messanger
//
//  Created by Zhanna Libman on 13/09/2016.
//  Copyright © 2016 Zhanna Libman. All rights reserved.
//

import Foundation

protocol UpdatesReceivedDelegate {
    func receivedUpdates();
}

class UpdatesChecker: NSObject, RequestResultReceivedDelegate {
    fileprivate var _checkingUpdates: Bool = true;
    fileprivate var serverConnectionHelper = ServerConnectionHelper();
    fileprivate var action: RequestAction = RequestAction.getUsers;
    var delegate: UpdatesReceivedDelegate?;
    static let sharedChecker = UpdatesChecker();
    
    override fileprivate init(){
        super.init();
    }
   
    
    var checkingUpdates: Bool{
        get{
            return _checkingUpdates;
        }
        set{
            self._checkingUpdates = newValue;
        }
    }
    
    func checkForUpdates(){

        serverConnectionHelper.delegate = self;
        let checkingInterval = DispatchTime.now() + Double(Int64(1 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC);
        let queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default);
        
        queue.asyncAfter(deadline: checkingInterval) { [weak self]() -> Void in
            self!.serverConnectionHelper.sendingRequest(self!.action, userName: User.currentUser["userName"]!, password: User.currentUser["password"]!, message: nil, recipient: nil);

        };
    }
    
    func requestResultReceived(_ result: Result) {
        
        var hasUpdates: Bool = false;
        
        if action == RequestAction.getUsers {
            if result.result == ReceivedResult.success{
                var userList = result.list as! [String];
                for var i in 0..<userList.count{
                    if !User.allUsers.keys.contains(userList[i]){
                        let newUser = User(senderName: userList[i]);
                        User.allUsers[userList[i]] = newUser;
                        User.friendsList.append(newUser);
                        hasUpdates = true;
                    }
                }
                
            }
            
            action = RequestAction.getMessages;
            
        }
        else if action == RequestAction.getMessages{
            if result.result == ReceivedResult.success{
                let newMessages = result.list as! [Message];
                if newMessages.count > 0{
                    for var i in 0..<newMessages.count{
                        User.allUsers[newMessages[i].sender]?.ConversationWithUser.append(newMessages[i]);
                    
                    }
                    hasUpdates = true;
                }
            }
            action = RequestAction.getUsers;
        }
        if hasUpdates{
            if let theDelegate = delegate{
                DispatchQueue.main.async(execute: {
                    theDelegate.receivedUpdates();
                });
            }
        }
        if (self.checkingUpdates){
            self.checkForUpdates();
        }
        else{
            self.serverConnectionHelper.delegate = nil;
        }
        
    }
    
}
