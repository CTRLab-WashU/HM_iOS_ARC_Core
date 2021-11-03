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
            
            TaskListScheduleManager.shared.loadHistoryFromBridge { (wakeSleep, testSchedule, error) in
                if let errorUnwrapped = error {
                    completion(nil, errorUnwrapped)
                    return
                }
                
                // Save the ARC ID
                self.saveArcId(arcIdInt: arcIdInt)
                
                // Start with no commitment, unless the two responses below are non-nil
                Arc.shared.appController.commitment = .none
                
                // We need both to consider the user as previously setup
                guard let wakeSleepUnwrapped = wakeSleep,
                      let testScheduleUnwrapped = testSchedule else {
                    completion(arcIdInt, nil)
                    return
                }
                
                Arc.shared.appController.commitment = .committed
                Arc.shared.notificationController.authenticateNotifications { (didAuthenticate, error) in
                    DispatchQueue.main.async {
                        if self.createTestSessions(schedule: testScheduleUnwrapped) {
                            Arc.shared.studyController.save()
                        } else {
                            print("Error creating sessions from schedule")
                        }
                    }
                }
                
                let sortedSessions = testScheduleUnwrapped.sessions.sorted { (test1, test2) -> Bool in
                    return test1.session_date < test2.session_date
                }
                
                if let firstTest = sortedSessions.first {
                    Arc.shared.studyController.firstTest = self.convertToTestState(test: firstTest)
                }
                
                // Get the latest test, which is the most recent test we have past
                let now = Date().timeIntervalSince1970
                if let latestTest = sortedSessions.filter({ (test) -> Bool in
                    return now > test.session_date
                }).last {
                    Arc.shared.studyController.latestTest = self.convertToTestState(test: latestTest)
                    Arc.apply(forVersion: "2.0.0")
                }
                
                NotificationCenter.default.post(name: .ACStartEarningsRefresh, object: nil)
                
                // Save wake sleep schedule
                Arc.shared.appController.commitment = .committed
                MHController.dataContext.performAndWait {
                    let controller = Arc.shared.scheduleController
                    for entry in wakeSleepUnwrapped.wake_sleep_data {
                        let _ = controller.create(entry: entry.wake,
                                          endTime: entry.bed,
                                          weekDay: WeekDay.fromString(day: entry.weekday),
                                          participantId: Int(arcIdInt))
                    }
                    controller.save()
                }
                
                completion(arcIdInt, nil)
            }
        })
    }
    
    open func createTestSessions(schedule: TestScheduleRequestData) -> Bool {
        // Needs to be implemented by sub-class
        assertionFailure("createTestSessions needs to be implemented by sub-class")
        return false
    }
    
    fileprivate func convertToTestState(test: TestScheduleRequestData.Entry) -> SessionInfoResponse.TestState {
        return SessionInfoResponse.TestState(session_date: test.session_date, week: Int(test.week), day: Int(test.day), session: Int(test.session), session_id: test.session_id)
    }
    
    fileprivate func saveArcId(arcIdInt: Int64) {
        // Save the user's Arc ID info
        MHController.dataContext.perform {
            let entry:AuthEntry = self.new()
            entry.authDate = Date()
            entry.participantID = arcIdInt
            Arc.shared.participantId = Int(arcIdInt)
            self.save()
        }
    }
}
