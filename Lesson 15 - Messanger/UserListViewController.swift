//
//  UserListViewController.swift
//  Lesson 15 - Messanger
//
//  Created by Zhanna Libman on 03/09/2016.
//  Copyright © 2016 Zhanna Libman. All rights reserved.
//

import UIKit

class UserListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UpdatesReceivedDelegate {
    
    var btnBack: UIButton!;
    var lblUserList: UILabel!;
    var userListTableView: UITableView!;
    
    
    var messagesList: MessagesListViewController!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        
        
        
        view.backgroundColor = UIColor.white;
        
        btnBack = UIButton(type: .system);
        btnBack.frame = CGRect(x: 5, y: 30, width: 100, height: 50);
        btnBack.setTitle("<<Back", for: UIControlState());
        btnBack.addTarget(self, action: #selector(UserListViewController.btnBackClicked(_:)), for: .touchUpInside);
        view.addSubview(btnBack);
        
        lblUserList = UILabel(frame: CGRect(x: 5, y: btnBack.frame.maxY + 5, width: view.frame.width - 10, height: 50));
        lblUserList.text = "Welcome";
        lblUserList.textColor = UIColor.blue;
        lblUserList.textAlignment = .center;
        lblUserList.lineBreakMode = .byWordWrapping;
        lblUserList.numberOfLines = 2;
        view.addSubview(lblUserList);
        
        userListTableView = UITableView(frame: CGRect(x: 5, y: lblUserList.frame.maxY + 5, width: view.frame.width - 10, height: view.frame.height - lblUserList.frame.maxY - 5), style: .plain);
        userListTableView.rowHeight = 60;
        userListTableView.dataSource = self;
        userListTableView.delegate = self;
        view.addSubview(userListTableView);
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UpdatesChecker.sharedChecker.delegate = self;
        
        
        if let theCurrentUser = User.currentUser["userName"]{
            lblUserList.text = "Welcome, \(theCurrentUser). Here are all users.";
        }
        userListTableView.reloadData();
    }
    override func viewWillDisappear(_ animated: Bool) {
        UpdatesChecker.sharedChecker.delegate = nil;
    }
    
    func btnBackClicked (_ sender: UIButton){
        User.allUsers.removeAll(keepingCapacity: true);
        User.friendsList.removeAll(keepingCapacity: true);
        UpdatesChecker.sharedChecker.checkingUpdates = false;
        dismiss(animated: true, completion: nil);
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return User.friendsList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "identifier");
        
        if cell == nil{
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "identifier");
            cell?.showsReorderControl = true;
        }
        
        cell!.textLabel?.text = User.friendsList[(indexPath as NSIndexPath).row].name;
        if let lastMessage = User.friendsList[(indexPath as NSIndexPath).row].ConversationWithUser.last{
            cell!.detailTextLabel?.text = lastMessage.text;
            if !lastMessage.isRead{
                cell!.detailTextLabel?.textColor = UIColor.blue;
            }
            else{
                cell!.detailTextLabel?.textColor = UIColor.black;
            }
        }
        else{
           cell!.detailTextLabel?.text = "";
        }
        if (indexPath as NSIndexPath).row%2 == 0{
            cell!.backgroundColor = UIColor.lightGray;
        }
        else{
            cell!.backgroundColor = UIColor.white;
        }
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if messagesList == nil{
            messagesList = MessagesListViewController();
        }
        messagesList.currentConversation = User.friendsList[(indexPath as NSIndexPath).row];
        present(messagesList, animated: true, completion: nil);
    }
    
    func receivedUpdates() {
        userListTableView.reloadData();
    }
    
    
    
}
