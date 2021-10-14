//
//  SageSessionController.swift
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

open class SageSessionController: SessionController {
    
    ///
    /// - returns: true if the session has been successfully finished
    ///
    open func isSessionFinished(sessionId: Int) -> Bool {
        return getFinishedSessions().contains(where: { Int($0.sessionID) == sessionId })
    }

    ///
    /// - returns: true if the session has been successfully uploaded
    ///
    open func isSessionUploaded(sessionId: Int) -> Bool {
        return getUploadedSessions().contains(where: { Int($0.sessionID) == sessionId })
    }
    
    open func getFinishedSessions() -> [Session] {
        let predicate = NSPredicate(format: "finishedSession == TRUE");
        let sortDescriptors = [NSSortDescriptor(key:"sessionDate", ascending:true)];
        let results:[Session] = fetch(predicate: predicate, sort: sortDescriptors) ?? []
        return results
    }
    
    override open func uploadSignature(signature:Signature) {
        guard signature.isUploaded == false else {
            return
        }
        
        TaskListScheduleManager.shared.uploadSignature(signature: signature)
        
        MHController.dataContext.performAndWait {
            signature.isUploaded = true
            self.save()
        }
    }
    
    override open func uploadSession(session: Session) {
        guard session.uploaded == false else {
            return
        }
        
        let full:FullTestSession = .init(withSession: session)
        TaskListScheduleManager.shared.uploadFullTestSession(session: full)                
        MHController.dataContext.performAndWait { [weak self] in
            session.uploaded = true
            self?.save()
            NotificationCenter.default.post(name: .ACSessionUploadComplete, object: self?.sessionUploads)
        }
    }
    
    override open func uploadSchedule(studyPeriods:[StudyPeriod]) {
        guard !studyPeriods.isEmpty else { return }
        
        let data: TestScheduleRequestData = .init(withStudyPeriods: studyPeriods)
        TaskListScheduleManager.shared.uploadStudyPeriodSchedule(schedule: data)
        
        MHController.dataContext.performAndWait {
            studyPeriods.forEach({$0.scheduleUploaded = true})
            self.save()
            Arc.shared.appController.testScheduleUploaded = true
        }
    }
}
