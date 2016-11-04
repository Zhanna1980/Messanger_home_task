//
//  ServerConnectionHelper.swift
//  Lesson 15 - Messanger
//
//  Created by Zhanna Libman on 07/09/2016.
//  Copyright © 2016 Zhanna Libman. All rights reserved.
//

import Foundation

protocol RequestResultReceivedDelegate {
    func requestResultReceived (_ result: Result);
}

enum RequestAction: String {
    
    case login, signup, getUsers, getMessages, sendMessage;
    
}


class ServerConnectionHelper: NSObject, URLSessionDelegate{
    fileprivate var session: Foundation.URLSession!;
    fileprivate var receivedData: NSMutableData!;
    fileprivate var requestAction: RequestAction!;
    var delegate: RequestResultReceivedDelegate?;
    
    func sendingRequest(_ action: RequestAction, userName: String, password: String, message: String?, recipient: String?){
        requestAction = action;
        let configuration = URLSessionConfiguration.default;
        configuration.timeoutIntervalForRequest = 15.0;
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () -> Void in
                        
            var dict:[NSString : AnyObject] =
                [
                    "action" : action.rawValue as AnyObject,
                    "userName" : userName as AnyObject,
                    "password" : password as AnyObject,
            ]
            
            if message != nil && recipient != nil {
                dict ["text"] = message! as AnyObject?;
                dict ["recipient"] = recipient! as AnyObject?;
            }
            do{
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted);
                self.receivedData = NSMutableData();
                self.session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil);
                /*let url = URL(string: "http://localhost:8080/MainServlet");*/
                let url = URL(string: "http://146.148.28.47/SimpleChatHttpServer/ChatServlet");
                let request = NSMutableURLRequest(url: url!);
                request.httpMethod = "POST";
                let task = self.session.uploadTask(with: request as URLRequest, from: jsonData);
                task.resume();
            }catch{
                self.handleError();
            }
        });
    }
    
    func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        if error == nil{
            do{
                let jsonObject = try JSONSerialization.jsonObject(with: receivedData as Data, options: .allowFragments) as! NSDictionary;
                
                receivedData = nil;
                let result = jsonObject["result"];
                
                if let theResult = result{
                    
                    var list: [AnyObject] = [AnyObject]();
                                        
                    if let users = jsonObject["users"]{
                        list = users as! [NSString];
                    }
                    else {
                        if let messages = jsonObject["messages"] {
                            let newMessages = messages as! NSArray;
                            for message in newMessages
                            {
                                if let data = message as? NSDictionary
                                {
                                    let sender = data["sender"] as! String;
                                    let text = data["text"] as! String;
                                    let newMessage = Message(text: text, sender: sender);
                                    list.append(newMessage);

                                }
                            }

                            
                           /* for message in newMessages{
                                let sender = message["sender"] as! String;
                                let text = message["text"] as! String;
                                let newMessage = Message(text: text, sender: sender);
                                list.append(newMessage);
                            }*/
                        }
                    }
                    
                    let requestResult = Result(result: ReceivedResult(rawValue: theResult as! String)!, list: list);
                    
                    if let theDelegate = delegate{
                        DispatchQueue.main.async(execute: { 
                            theDelegate.requestResultReceived(requestResult);
                        });
                    }
                }
                
            }catch{
                handleError();
            }
        }
        else{
           handleError(); 
        }
    }
    
    func URLSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didReceiveData data: Data) {
        receivedData.append(data);
    }
    
    func handleError(){
        
        let requestResult = Result(result: ReceivedResult.error, list: nil);
        
        if let theDelegate = delegate{
            DispatchQueue.main.async(execute: {
                theDelegate.requestResultReceived(requestResult);
            });
        }
    }
}


