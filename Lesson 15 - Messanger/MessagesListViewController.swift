//
//  MessagesListViewController.swift
//  Lesson 15 - Messanger
//
//  Created by Zhanna Libman on 03/09/2016.
//  Copyright © 2016 Zhanna Libman. All rights reserved.
//

import UIKit
class MessagesListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UpdatesReceivedDelegate {
    
    var action: RequestAction!;
    var currentConversation: User!;
    var shouldReloadData: Bool = false;
    
    var btnBack: UIButton!;
    var lblMessagesList: UILabel!;
    var enterMessage: UITextView!;
    var btnSend: UIButton!;
    var conversationTableView: UITableView!;
    
    let serverConnectionHelper = ServerConnectionHelper();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        view.backgroundColor = UIColor.white;
        
        btnBack = UIButton(type: .system);
        btnBack.frame = CGRect(x: 5, y: 30, width: 100, height: 50);
        btnBack.setTitle("<<Back", for: UIControlState());
        btnBack.addTarget(self, action: #selector(MessagesListViewController.btnBackClicked(_:)), for: .touchUpInside);
        view.addSubview(btnBack);
        
        lblMessagesList = UILabel(frame: CGRect(x: 5, y: btnBack.frame.maxY + 5, width: view.frame.width - 10, height: 50));
        lblMessagesList.text = "Conversation with \(currentConversation.name)";
        lblMessagesList.textColor = UIColor.red;
        lblMessagesList.textAlignment = .center;
        lblMessagesList.lineBreakMode = .byWordWrapping;
        lblMessagesList.numberOfLines = 2;
        view.addSubview(lblMessagesList);
        
        conversationTableView = UITableView(frame: CGRect(x: 5, y: lblMessagesList.frame.maxY + 5, width: view.frame.width - 10, height: view.frame.height - lblMessagesList.frame.maxY - 110), style: .plain);
        conversationTableView.rowHeight = UITableViewAutomaticDimension;
        conversationTableView.estimatedRowHeight = 60;
        conversationTableView.dataSource = self;
        conversationTableView.delegate = self;
        
        view.addSubview(conversationTableView);
        
        enterMessage = UITextView(frame: CGRect(x: 5, y: conversationTableView.frame.maxY + 5, width: view.frame.width - 70, height: 95));
        enterMessage.font = UIFont.boldSystemFont(ofSize: 14);
        enterMessage.isEditable = true;
        enterMessage.backgroundColor = UIColor.lightGray;
        view.addSubview(enterMessage);
        
        btnSend = UIButton(type: .system);
        btnSend.frame = CGRect(x: enterMessage.frame.maxX, y: enterMessage.frame.origin.y, width: 50, height: enterMessage.frame.height);
        btnSend.addTarget(self, action: #selector(MessagesListViewController.btnSendClicked(_:)), for: .touchUpInside);
        btnSend.setTitle("Send", for: UIControlState());
        btnSend.backgroundColor = UIColor.darkGray;
        view.addSubview(btnSend);
        
        NotificationCenter.default.addObserver(self, selector: #selector(MessagesListViewController.handleKeyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(MessagesListViewController.handleKeyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil);
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UpdatesChecker.sharedChecker.delegate = self;
        if shouldReloadData{
            conversationTableView.reloadData();
            lblMessagesList.text = "Conversation with \(currentConversation.name)";
            shouldReloadData = false;
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UpdatesChecker.sharedChecker.delegate = nil;
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self);
    }
    
    
    func handleKeyboardDidShow(_ notification: Notification){
        
        let keyboardRectAsObject = (notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue;
        
        var keyboardRect = CGRect.zero;
        keyboardRectAsObject.getValue(&keyboardRect);
        
        enterMessage.frame = CGRect(x: 5, y: view.frame.height - 100 - keyboardRect.height, width: view.frame.width - 70, height: 95);
        btnSend.frame = CGRect(x: enterMessage.frame.maxX, y: enterMessage.frame.origin.y, width: 50, height: enterMessage.frame.height);
        
    }
    
    
    func handleKeyboardDidHide(_ notification: Notification){
        enterMessage.frame = CGRect(x: 5, y: conversationTableView.frame.maxY + 5, width: view.frame.width - 70, height: 95);
        btnSend.frame = CGRect(x: enterMessage.frame.maxX, y: enterMessage.frame.origin.y, width: 50, height: enterMessage.frame.height);
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentConversation.ConversationWithUser.count;
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "identifier");
        
        if cell == nil{
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "identifier");
            cell?.textLabel?.sizeToFit();
            cell?.textLabel?.lineBreakMode = .byWordWrapping;
            cell?.textLabel?.numberOfLines = 0;
            cell?.showsReorderControl = true;
            cell?.sizeToFit();
        }
        
        
        cell!.textLabel?.text = currentConversation.ConversationWithUser[(indexPath as NSIndexPath).row].text;
        if currentConversation.ConversationWithUser[(indexPath as NSIndexPath).row].sender == User.currentUser["userName"]{
            cell!.detailTextLabel?.text = "From me";
            cell!.backgroundColor = UIColor.cyan;
        }
        else{
            cell!.detailTextLabel?.text = "From \(currentConversation.ConversationWithUser[(indexPath as NSIndexPath).row].sender)";
            
            cell!.backgroundColor = UIColor.lightGray;
        }
        currentConversation.ConversationWithUser[(indexPath as NSIndexPath).row].isRead = true;
        
        return cell!;
    }

    
    func btnBackClicked (_ sender: UIButton){
        shouldReloadData =  true;
        dismiss(animated: true, completion: nil);
    }
    
    func btnSendClicked (_ sender: UIButton){
        enterMessage.resignFirstResponder();
        let message = enterMessage.text;
        if !(message?.isEmpty)! {
            action = RequestAction.sendMessage;
            serverConnectionHelper.sendingRequest(action, userName: User.currentUser["userName"]!, password: User.currentUser["password"]!, message: message, recipient: currentConversation.name);
            if User.currentUser["userName"]! != currentConversation.name{
                let newMessage = Message(text: message!, sender: User.currentUser["userName"]!);
                newMessage.isRead = true;
                currentConversation.ConversationWithUser.append(newMessage);
                let indexPath: [IndexPath] = [IndexPath(row: currentConversation.ConversationWithUser.count - 1, section: 0)];
                conversationTableView.insertRows(at: indexPath, with: .automatic);
            }
            enterMessage.text = "";
        }
    }
    
    func receivedUpdates() {
        conversationTableView.reloadData();
        conversationTableView.scrollToRow(at: IndexPath(row: currentConversation.ConversationWithUser.count - 1, section: 0), at: .bottom, animated: true);
    }
}
