//
//  ViewController.swift
//  Lesson 15 - Messanger
//
//  Created by Zhanna Libman on 31/08/2016.
//  Copyright © 2016 Zhanna Libman. All rights reserved.
//

import UIKit

class ViewController: UIViewController, RequestResultReceivedDelegate {
    
    var userList: UserListViewController!;
    var lblUserInfo: UILabel!;
    var enterUserName: UITextField!;
    var enterPassword: UITextField!;
    var userName: String!;
    var password: String!;
    var action: RequestAction!;
    
    var btnSignIn: UIButton!;
    var btnSignUp: UIButton!;
    
    
    var serverConnectionHelper: ServerConnectionHelper?;
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serverConnectionHelper = ServerConnectionHelper();
        
        lblUserInfo = UILabel(frame: CGRect(x: 0, y: 50, width: 200, height: 100));
        lblUserInfo.center.x = view.center.x;
        lblUserInfo.lineBreakMode = .byWordWrapping;
        lblUserInfo.numberOfLines = 2;
        lblUserInfo.text = "Please enter your username and password";
        lblUserInfo.textAlignment = .center;
        view.addSubview(lblUserInfo);
        
        enterUserName = UITextField(frame: CGRect(x: 0, y: lblUserInfo.frame.maxY + 10, width: 200, height: 50));
        enterUserName.borderStyle = .roundedRect;
        enterUserName.placeholder = "username";
        enterUserName.center.x = view.center.x;
        view.addSubview(enterUserName);
        
        enterPassword = UITextField(frame: CGRect(x: 0, y: enterUserName.frame.maxY + 10, width: 200, height: 50));
        enterPassword.borderStyle = .roundedRect;
        enterPassword.placeholder = "password";
        enterPassword.center.x = view.center.x;
        enterPassword.isSecureTextEntry = true;
        view.addSubview(enterPassword);
        
        btnSignIn = UIButton(type: .system);
        btnSignIn.frame = CGRect(x: enterPassword.frame.origin.x, y: enterPassword.frame.maxY + 10, width: 95, height: 50);
        btnSignIn.setTitle("Sign In", for: UIControlState());
        btnSignIn.addTarget(self, action:
            #selector(ViewController.signInUp(_:)), for: .touchUpInside);
        view.addSubview(btnSignIn);
        
        btnSignUp = UIButton(type: .system);
        btnSignUp.frame = CGRect(x: btnSignIn.frame.maxX + 10, y: enterPassword.frame.maxY + 10, width: 95, height: 50);
        btnSignUp.setTitle("Sign Up", for: UIControlState());
        btnSignUp.addTarget(self, action:
            #selector(ViewController.signInUp(_:)), for: .touchUpInside);
        view.addSubview(btnSignUp);
    }
    
    func signInUp (_ sender: UIButton){
        userName = enterUserName.text;
        password = enterPassword.text;
        if !userName.isEmpty && !password.isEmpty{
            btnSignUp.isEnabled = false;
            btnSignIn.isEnabled = false;
            lblUserInfo.text = "Sending";
            if sender === btnSignIn{
                action = RequestAction.login;
            }
            else{
                action = RequestAction.signup;
            }
            serverConnectionHelper!.delegate = self;
            serverConnectionHelper?.sendingRequest(action, userName: userName, password: password, message: nil, recipient: nil);
            
        }
        else{
            lblUserInfo.text = "You need to enter both username and password";
        }
    }
    
    
    func showUserListViewController(){
        if userList == nil{
            userList = UserListViewController();
        }
        UpdatesChecker.sharedChecker.checkingUpdates = true;
        UpdatesChecker.sharedChecker.checkForUpdates();
        present(userList, animated: true, completion: nil);
    }
    
    func requestResultReceived (_ result: Result) {
        if action == RequestAction.login || action == RequestAction.signup{
            lblUserInfo.text = result.result.rawValue;
            btnSignIn.isEnabled = true;
            btnSignUp.isEnabled = true;
            User.currentUser["userName"] = userName;
            User.currentUser["password"] = password;
            if result.result == ReceivedResult.success{
                showUserListViewController();
            }
            serverConnectionHelper?.delegate = nil;
 
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

