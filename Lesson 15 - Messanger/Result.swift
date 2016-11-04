//
//  Result.swift
//  Lesson 15 - Messanger
//
//  Created by Zhanna Libman on 05/09/2016.
//  Copyright © 2016 Zhanna Libman. All rights reserved.
//

import Foundation

enum ReceivedResult : String {
    
    case success, failure, error;
    
}


class Result{
    
    fileprivate var _result: ReceivedResult;
    fileprivate var _list: [AnyObject]?;
    
    init(result: ReceivedResult, list: [AnyObject]?){
        self._result = result;
        if let theList = list{
            self._list = theList;
        }
    }
    
    var result: ReceivedResult{
        get{
            return self._result;
        }
        set{
            self._result = newValue;
        }
    }
    
    var list: [AnyObject]{
        get{
            return _list!;
        }
    }
    
    
}
