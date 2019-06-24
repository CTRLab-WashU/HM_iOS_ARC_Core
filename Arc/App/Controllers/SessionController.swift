//
//  File.swift
// Arc
//
//  Created by Philip Hayes on 10/11/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import Foundation
import CoreData

open class SessionController:MHController {
	
	@discardableResult
	open func create(sessionAt date:Date) -> Session
	{
		
		let newSession:Session = new();
		newSession.sessionDate = date;
		newSession.expirationDate = date.addingHours(hours: 2);
		
		
		return newSession;
	}
	
	
	open func getFinishedSessionsForUploading() -> [Session]
	{
		let predicate = NSPredicate(format: "uploaded == FALSE AND finishedSession == TRUE");
		let sortDescriptors = [NSSortDescriptor(key:"sessionDate", ascending:true)];
		
		let results:[Session] = fetch(predicate: predicate, sort: sortDescriptors) ?? []
		return results;
	
		
		
	}
	
	open func getMissedSessionsForUploading() -> [Session]
	{
		let predicate = NSPredicate(format: "uploaded == FALSE AND missedSession == TRUE");
		let sortDescriptors = [NSSortDescriptor(key:"sessionDate", ascending:true)];
		
		let results:[Session] = fetch(predicate: predicate, sort: sortDescriptors) ?? []
		return results;
		
	}
	

    open func getSignaturesForUploading() -> [Signature]
    {
        
        
        let results:[Signature] = fetch() ?? []
        return results;
        
    }
	open func sendFinishedSessions()
	{
		
		MHController.dataContext.perform {
			let sessions = self.getFinishedSessionsForUploading();
			
			for i in 0..<sessions.count
			{
				self.uploadSession(session: sessions[i])
				
			}
		}
	}
	
	open func sendMissedSessions()
	{
		MHController.dataContext.perform {
			
			let sessions = self.getMissedSessionsForUploading();
			
			for i in 0..<sessions.count
			{
				self.uploadSession(session: sessions[i])
				
			}
		}
	}
    open func sendSignatures() {
        MHController.dataContext.perform {
            let signatures = self.getSignaturesForUploading()
            for i in 0 ..< signatures.count {
                self.uploadSignature(signature: signatures[i])
            }
        }
    }
    open func uploadSignature(signature:Signature) {
        guard signature.isUploaded == false else {
            return
        }
        guard let data = signature.data else {
            return
        }
        //let md5 = data.encode()?.MD5()
        
        let r:HMAPIRequest<Data, HMResponse> = .post("/signature-data")
        r.executeMultipart(data:data ,
                           params: [
                            "participant_id":"\(Arc.shared.participantId ?? -1)",
                            "device_id": Arc.shared.deviceId,
                            "session_id": "\(signature.sessionId)"])
        { (response, data, _) in
            guard !HMRestAPI.shared.blackHole else {
                return
            }
            if data?.errors.count == 0 {
                //if md5 == data?.response?.md5 {
                    signature.isUploaded = true
                    
                    self.save()
                //} else {
                  //  HMLog("\(md5 ?? "") does not match \(data?.response?.md5 ?? "")")
                //}
            } else {
                print(data?.errors.toString())
            }
            
            
            
        }
        
        
    }
	open func uploadSession(session:Session) {
		guard session.uploaded == false else {
			return
		}
		let full:FullTestSession = .init(withSession: session)
		//HMLog(full.toString())
		let md5 = full.encode()?.MD5()
		let submitTest:HMAPIRequest<FullTestSession, HMResponse> = .post("submit-test")
		submitTest.execute(data: full) { (response, data, _) in
            guard !HMRestAPI.shared.blackHole else {
                return
            }
			MHController.dataContext.performAndWait {
				HMLog("Session: \(full.session_id ?? ""), received response \(data?.toString() ?? "") on \(Date())", silent: false)
				if data?.errors.count == 0 {
					session.uploaded = true
					if md5 == data?.response?.md5 {
						self.save()
					} else {
						HMLog("\(md5 ?? "") does not match \(data?.response?.md5 ?? "")")
					}
				} else {
					print(data?.errors.toString())
				}
				
			}
		}
	}
	open func uploadSchedule(studyPeriod:StudyPeriod) {
		guard studyPeriod.scheduleUploaded == false else {
			return
		}
		let data:TestScheduleRequestData = .init(withStudyPeriod: studyPeriod)
		
		let md5 = data.encode()?.MD5()
		let submitTestSchedule:HMAPIRequest<TestScheduleRequestData, HMResponse> = .post("submit-test-schedule")
		submitTestSchedule.execute(data: data) { (response, obj, _) in
			HMLog("Participant: \(data.participant_id ?? ""), received response \(obj?.toString() ?? "") on \(Date())", silent: false)
            guard !HMRestAPI.shared.blackHole else {
                Arc.shared.appController.testScheduleUploaded = true
                return
            }
			MHController.dataContext.performAndWait {
				
				if obj?.errors.count == 0 {
					studyPeriod.scheduleUploaded = true
					if md5 == obj?.response?.md5 {
						self.save()

						HMLog("\(md5 ?? "") does match \(obj?.response?.md5 ?? "")", silent: false)
						
					} else {
						HMLog("\(md5 ?? "") does not match \(obj?.response?.md5 ?? "")", silent: false)
					}
				} else {
					studyPeriod.scheduleUploaded = false
					//dump(obj?.errors)
//                    print(obj?.errors.toString())



				}
				
			}
		}
	}
	
	open func uploadSchedule(studyPeriods:[StudyPeriod]) {
		let data:TestScheduleRequestData = .init(withStudyPeriods: studyPeriods)
		
		let md5 = data.encode()?.MD5()
		let submitTestSchedule:HMAPIRequest<TestScheduleRequestData, HMResponse> = .post("submit-test-schedule")
		print(data.toString())
		submitTestSchedule.execute(data: data) { (response, obj, _) in
			HMLog("Participant: \(data.participant_id ?? ""), received response \(obj?.toString() ?? "") on \(Date())")
			MHController.dataContext.performAndWait {
                guard !HMRestAPI.shared.blackHole else {
                    Arc.shared.appController.testScheduleUploaded = true
                    return
                }
				if obj?.errors.count == 0 {
					studyPeriods.forEach({$0.scheduleUploaded = true})
					if md5 == obj?.response?.md5 {
						self.save()
						HMLog("\(md5 ?? "") does match \(obj?.response?.md5 ?? "")", silent: false)
						Arc.shared.appController.testScheduleUploaded = true

						
					} else {
						HMLog("\(md5 ?? "") does not match \(obj?.response?.md5 ?? "")", silent: false)
					}
				} else {
					studyPeriods.forEach({$0.scheduleUploaded = true})
					dump(obj?.errors)

				}
				
			}
		}
	}

	
}
