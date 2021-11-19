//
//  SageAuthController.swift
//  Arc
//
//  Copyright © 2021 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import Foundation
import BridgeSDK

open class SageAuthController : AuthController {
    override open func getAuthIssue(from code:Int?) -> String {
        if let code = code {
            if code == 401 {
                return "Invalid  Rater ID or ARC ID".localized("error1")
            }
            if code == 409 {
                return "Already enrolled on another device".localized("error2")
            }
        }
        return "Sorry, our app is currently experiencing issues. Please try again later.".localized("error3")
    }
	
	open override func authenticate(completion: @escaping ((Int64?, String?) -> ())) {
        
        guard let password = self.getPassword(),
              let externalId = self.getUserName(),
              let arcIdInt = Int64(externalId) else {
            debugPrint("No user arc id entered")
            return
        }
        
        // There may be a scenario where we are already signed in,
        // If that is the guess, then sign out first before moving on.
        if BridgeSDK.authManager.isAuthenticated() {
            BridgeSDK.authManager.signOut { task, result, error in
                // Give BridgeSDK time to clean up
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.signIn(arcIdInt: arcIdInt, externalId: externalId, password: password, completion: completion)
                }
            }
            return
        }
        
        self.signIn(arcIdInt: arcIdInt, externalId: externalId, password: password, completion: completion)
	}
    
    fileprivate func signIn(arcIdInt: Int64, externalId: String, password: String, completion: @escaping ((Int64?, String?) -> ())) {
        BridgeSDK.authManager.signIn(withExternalId: externalId, password: password, completion: { (task, result, error) in
            
            guard error == nil else {
                if ((error?.localizedDescription ?? "").contains("404")) {
                    completion(nil, "Account not found.")
                } else {
                    completion(nil, error?.localizedDescription ?? "Auth sign in error")
                }
                return
            }
            
            TaskListScheduleManager.shared.loadAndSetupUserData(arcIdInt: arcIdInt, completion: completion)
        })
    }
    
    override open func createTestSessions(schedule: TestScheduleRequestData) -> Bool {
        // Needs to be implemented by sub-class
        assertionFailure("createTestSessions needs to be implemented by sub-class")
        return false
    }
}
