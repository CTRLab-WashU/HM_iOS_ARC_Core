//
//  CompletedTestsDefaultsReport.swift
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

import BridgeApp
import Research
import Foundation
import UIKit

open class CompletedTestsDefaultsReport: UserDefaultsSingletonReport {

    var _current: CompletedTestList?
    var current: CompletedTestList? {
        if _current != nil { return _current }
        guard let jsonStr = self.defaults.data(forKey: "\(identifier)JsonValue") else { return nil }
        do {
            _current = try TaskListScheduleManager.shared.jsonDecoder.decode(CompletedTestList.self, from: jsonStr)
            return _current
        } catch {
            debugPrint("Error decoding reminders json \(error)")
        }
        return nil
    }
    func setCurrent(_ item: CompletedTestList) {
        _current = item
        do {
            let jsonData = try TaskListScheduleManager.shared.jsonEncoder.encode(item)
            self.defaults.set(jsonData, forKey: "\(identifier)JsonValue")
        } catch {
            print("Error converting reminders to JSON \(error)")
        }
    }
    
    public override init(identifier: RSDIdentifier) {
        super.init(identifier: RSDIdentifier.completedTests)
    }
    
    public init() {
        super.init(identifier: RSDIdentifier.completedTests)
    }
    
    open func append(session: FullTestSession) {
        guard let week = session.week,
              let day = session.day,
              let sesssionNum = session.session else {
            debugPrint("Completed test session has invalid details")
            return
        }
        
        let test = CompletedTest(week: Int(week),
                                 day: Int(day),
                                 session: Int(sesssionNum),
                                 completedOn: Date().timeIntervalSince1970)
        
        self.append(completedTest: test)
    }
    
    open func append(completedTest: CompletedTest) {
        var newArray = self.current?.completed ?? []
        newArray.append(completedTest)
        self.setCurrent(CompletedTestList(completed: newArray))
        
        self.syncToBridge()
    }
    
    open override func loadFromBridge(completion: @escaping ((String?) -> Void)) {
        
        guard !self.isSyncingWithBridge else { return }
        self.isSyncingWithBridge = true
        TaskListScheduleManager.shared.getSingletonReport(reportId: self.identifier) { (report, error) in
            
            self.isSyncingWithBridge = false
            
            guard error == nil else {
                let errorStr = "Error getting most recent completed tests \(String(describing: error))"
                completion(errorStr)
                print(errorStr)
                return
            }
            
            // If clientData/report is nil, this is the first time we are loading it
            guard let clientData = report?.clientData else {
                completion(nil)
                return
            }
            
            guard let bridgeJsonData = (clientData as? String)?.data(using: .utf8) else {
                let errorStr = "Error parsing clientData for completed tests report"
                print(errorStr)
                completion(errorStr)
                return
            }

            do {
                let bridgeItem = try TaskListScheduleManager.shared.jsonDecoder.decode(CompletedTestList.self, from: bridgeJsonData)
                
                if let cached = self.current {
                    // Merge the cached list with the server list
                    let bridgeItemsNotInCache = bridgeItem.completed.filter { (test1) -> Bool in
                        return !cached.completed.contains { (test2) -> Bool in
                            return test1.week == test2.week &&
                                test1.day == test2.day &&
                                test1.session == test2.session
                        }
                    }
                    var newArray = cached.completed
                    newArray.append(contentsOf: bridgeItemsNotInCache)
                    self.setCurrent(CompletedTestList(completed: newArray))
                } else {
                    self.setCurrent(bridgeItem)
                }
                
                // Let's sync our cached version with bridge if our local was out of sync
                if !self.isSyncedWithBridge {
                    self.syncToBridge()
                }
                
                completion(nil)
            } catch {
                let errorStr = "CompletedTestList invalid data format"
                completion(errorStr)
                print("\(errorStr)\(error.localizedDescription)")
            }
        }
    }
            
    override open func syncToBridge() {
        guard let item = self.current else { return }
        do {
            let jsonData = try TaskListScheduleManager.shared.jsonEncoder.encode(item)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            let report = SBAReport(reportKey: self.identifier, date: SBAReportSingletonDate, clientData: jsonString as NSString)
            TaskListScheduleManager.shared.saveReport(report)
        } catch {
            print(error)
        }
    }
}

public struct CompletedTestList: Codable {
    var completed: Array<CompletedTest>
}

public struct CompletedTest: Codable {
    var week: Int
    var day: Int
    var session: Int
    var completedOn: TimeInterval
}
