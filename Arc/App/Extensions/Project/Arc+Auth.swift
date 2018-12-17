//
// ArcManager+Auth.swift
// Arc
//
//  Created by Philip Hayes on 9/26/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import Foundation

public extension Arc {
    
    public func isAuthorized() -> Bool {
        return authController.isAuthorized()
    }
    public func clearAuth() {
        authController.clear()
    }
    
    public func setAuth(userName:String) {
        _ = authController.set(username: userName)
    }
    public func setAuth(password:String) {
        _ = authController.set(password: password)
    }
    public func setAuth(username:String, password:String) {
        setAuth(userName: username)
        setAuth(password: password)
    }
	public func authenticate(completion:@escaping ((Int64?, String?)->())) {
        authController.authenticate(completion: completion)
    }
}
