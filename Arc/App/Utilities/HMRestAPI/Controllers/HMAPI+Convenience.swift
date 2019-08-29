//
//  HMAPI+Convenience.swift
// Arc
//
//  Created by Philip Hayes on 9/25/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import Foundation

public extension HMAPI {
    
    static func defaultHeaders() -> [String:String] {
        return [
            "Accept":"application/json",
            "Content-Type":"application/json"
        ]
    }
    
    static func authHeaders() -> [String:String] {
        	var headers = defaultHeaders()
        headers["Authorization"] = ""
        return headers
    }
    
    static func auth(completion:(()->())?) {

        
        completion?()
      
    }
    
    static func placeholder(completion:(()->Void)?){
        completion?()
    }
    
}
