//
//  AuthController.swift
// Arc
//
//  Created by Philip Hayes on 9/25/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import Foundation

open class AuthController:MHController {
    private var _credential:AuthCredentials?
    private var _isAuthorized:Bool = false
	
    public func isAuthorized() -> Bool {
	
        return _isAuthorized
    }
    
    public func clear() {
        _isAuthorized = false
        _credential = nil
    }
    
    public func set(username:String, password:String) -> AuthCredentials? {
        let credential = AuthCredentials(userName: username, password: password)
        self._credential = credential
        return credential
    }
    
    public func set(username:String) -> AuthCredentials? {
        var credential = self._credential ?? AuthCredentials()
        
        credential.userName = username
        self._credential = credential
        
        return credential
        
    }
    
    public func set(password:String) -> AuthCredentials? {
        var credential = self._credential ?? AuthCredentials()
        
        credential.password = password
        self._credential = credential
        
        return credential
    }
	
	public func getPassword() -> String? {
		return self._credential?.password
	}
	public func getUserName() -> String? {
		return self._credential?.userName
	}
	public func checkAuth() -> Int64? {
		if let results:[AuthEntry] = fetch(), let entry = results.last {
			_isAuthorized = true
			return entry.participantID
		}
		return nil
	}
	open func authenticate(completion:@escaping ((Int64?, String?)->())) {
		if let id = checkAuth() {
			completion(id, nil)
			return
		}
        guard _credential?.userName != nil, _credential?.password != nil else {
			completion(nil, "No username.")
            return
        }
		
        
        _credential?.appVersion = Arc.shared.versionString
        _credential?.device_id = Arc.shared.deviceId
        _credential?.deviceInfo = Arc.shared.deviceInfo()
//		_credential?.override = true
//        print(_credential.toString())
        HMAPI.deviceRegistration.execute(data: _credential) { (response, obj, err) in
            if HMRestAPI.shared.blackHole {
                completion(00000000, nil)
                return
            }
			if obj?.errors.count == 0 {
                self._isAuthorized = true
//				DispatchQueue.main.async {

				HMAPI.getSessionInfo.execute(data: nil, completion: { (res, resObj, err) in
					guard  resObj?.errors.count == 0 else {
						HMLog(obj?.toString() ?? "")
						let r = response as? HTTPURLResponse
						let failureMessage = self.getAuthIssue(from: r?.statusCode)
						completion(nil, failureMessage)
						return
					}
					
					guard let value = self._credential?.userName, let id = Int64(value) else {
						
						completion(nil, "Sorry, our app is currently experiencing issues. Please try again later.".localized("error3"))
						return
					}
				
					MHController.dataContext.perform {
						Arc.shared.studyController.firstTest = resObj?.response.first_test
						Arc.shared.studyController.latestTest = resObj?.response.latest_test
						
						let entry:AuthEntry = self.new()
						entry.authDate = Date()
						
						
						entry.participantID = id
						//Set this value
						let value = Int(id)
						Arc.shared.participantId = value
						self.save()
						
						completion(id, nil)

						

					}
					
				})

			} else {
				HMLog(obj?.toString() ?? "")
                let r = response as? HTTPURLResponse
                let failureMessage = self.getAuthIssue(from: r?.statusCode)
				completion(nil, failureMessage)
			}
        }
		
		
        
    }
	open func pullData<T:Phase>(phaseType:T.Type, completion:@escaping (()->())) where T.PhasePeriod == T {
		guard let participantID = Arc.shared.participantId else {
			return completion()
		}
		HMAPI.getWakeSleep.execute(data: nil, completion: { (res, obj, err) in
			guard err == nil && obj?.errors.isEmpty ?? true else {
				return completion() //The closure returns Void so this is valid syntax because the function also returns Void
				
				
			}
			guard let data = obj?.response?.wake_sleep_schedule else {
				return completion()
			}
			
			MHController.dataContext.performAndWait {
				let controller = Arc.shared.scheduleController
				for entry in data.wake_sleep_data {
					
					controller.create(entry: entry.wake,
									  endTime: entry.bed,
									  weekDay: WeekDay.fromString(day: entry.weekday),
									  participantId: participantID)
					
					
				}
				controller.save()
				
				
				
			}
			
			HMAPI.getTestSchedule.execute(data: nil, completion: { (res, obj, err) in
				guard err == nil && obj?.errors.isEmpty ?? true else {
					
					return completion()
				}
				guard let data = obj?.response?.test_schedule else {
					return completion()
				}
				
				
				MHController.dataContext.performAndWait {
					let controller = Arc.shared.studyController
					if controller.create(testSessionsWithSchedule: data, with: phaseType) {
						controller.save()
					} else {
						print("Error creating sessions from schedule")
					}
					
				}
				completion()
			})
		})
		
	}
	
    open func getAuthIssue(from code:Int?) -> String {
        if let code = code {
            if code == 401 {
                return "Invalid Rater ID or ARC ID".localized("error1")
            }
            if code == 409 {
                return "Already enrolled on another device".localized("error2")
            }
        }
        return "Sorry, our app is currently experiencing issues. Please try again later.".localized("error3")
    }
    
}
