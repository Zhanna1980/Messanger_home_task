//
//  Message.swift
//  Lesson 15 - Messanger
//
//  Created by Zhanna Libman on 03/09/2016.
//  Copyright © 2016 Zhanna Libman. All rights reserved.
//

import Foundation

class Message{
    fileprivate var _text: String;
    fileprivate var _sender: String;
    fileprivate var _isRead: Bool = false;
    
    init (text: String, sender: String){
        self._text = text;
        self._sender = sender;
    }
    
    var text: String{
        get{
            return _text;
        }
        set{
            if !newValue.isEmpty{
                _text = newValue;
            }
        }
    }
    
    var sender: String{
        get{
            return _sender;
        }
        set{
            if !newValue.isEmpty{
                _sender = newValue;
            }
        }
    }
    
    var isRead: Bool {
        get{
            return _isRead;
        }
        set{
            _isRead = newValue;
        }
    }
    
}
