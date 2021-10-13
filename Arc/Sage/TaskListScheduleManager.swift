//
//  TaskListScheduleManager.swift
//  HASD
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

import UIKit
import CoreData
import Research
import BridgeApp
import BridgeAppUI
import BridgeSDK
import ArcUIKit
import JsonModel

extension RSDIdentifier {
    public static let migrated = RSDIdentifier("Migrated")
    public static let availability = RSDIdentifier("Availability")
    public static let testSchedule = RSDIdentifier("TestSchedule")
    public static let completedTests = RSDIdentifier("CompletedTests")
}

/// Subclass the schedule manager to set up a predicate to filter the schedules.
public class TaskListScheduleManager {
    
    public static let shared = TaskListScheduleManager()
    
    private let kDataGroups                       = "dataGroups"
    private let kSchemaRevisionKey                = "schemaRevision"
    private let kSurveyCreatedOnKey               = "surveyCreatedOn"
    private let kSurveyGuidKey                    = "surveyGuid"
    private let kExternalIdKey                    = "externalId"

    private let kMetadataFilename                 = "metadata.json"
    
    let kReportDateKey = "reportDate"
    let kReportTimeZoneIdentifierKey = "timeZoneIdentifier"
    let kReportClientDataKey = "clientData"
    
    open var appType: String {
        return "HASD"
    }
    
    /// For encoding report client data
    lazy var jsonEncoder: JSONEncoder = {
        return JSONEncoder()
    }()
    
    /// For decoding report client data
    lazy var jsonDecoder: JSONDecoder = {
        return JSONDecoder()
    }()
    
    var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    /// Pointer to the shared participant manager.
    public var participantManager: SBBParticipantManagerProtocol {
        return BridgeSDK.participantManager
    }
    
    /// Pointer to the default factory to use for serialization.
    open var factory: RSDFactory {
        return SBAFactory.shared
    }
    
    public let completedTests = CompletedTestsDefaultsReport()
    public var completedTestList: Array<CompletedTest> {
        return self.completedTests.current?.completed ?? []
    }
    
    /// This should only be called by the sign-in controller or when the app loads
    public func forceReloadCompletedTestData(completion: @escaping ((String?) -> Void)) {
        self.completedTests.loadFromBridge(completion: completion)
    }
    
    open func loadHistoryFromBridge(completed: @escaping ((WakeSleepScheduleRequestData?, TestScheduleRequestData?, String?) -> Void)) {
                
        var availabilityData: WakeSleepScheduleRequestData? = nil
        var testScheduleData: TestScheduleRequestData? = nil
        
        let reportIds: [RSDIdentifier] = [.availability, .testSchedule /*, .completedSessions */]
        var successCtr = reportIds.count
        
        reportIds.forEach { (identifier) in
            self.getSingletonReport(reportId: identifier) { (report, error) in
                if (error != nil) {
                    completed(nil, nil, error)
                }
                
                switch(identifier) {
                case .availability:
                    availabilityData = self.createWakeSleepScheduleRequestData(mostRecentReport: report)
                case .testSchedule:
                    testScheduleData = self.createTestScheduleRequestData(mostRecentReport: report)
                default:
                    debugPrint("Report id \(identifier) not supported in loadHistoryFromBridge")
                }
                
                successCtr -= 1
                if (successCtr <= 0) {  // Check for done state
                    self.forceReloadCompletedTestData { (errorStr) in
                        completed(availabilityData, testScheduleData, errorStr)
                    }
                }
            }
        }
    }
    
    func getSingletonReport(reportId: RSDIdentifier, completion: @escaping (_ report: SBAReport?, _ error: String?) -> Void) {
        // Make sure we cover the ReportSingletonDate no matter what time zone or BridgeApp version it was created in
        // and no matter what time zone it's being retrieved in:
        let fromDateComponents = Date(timeIntervalSince1970: -48 * 60 * 60).dateOnly()
        let toDateComponents = Date(timeIntervalSinceReferenceDate: 48 * 60 * 60).dateOnly()
        
        self.participantManager.getReport(reportId.rawValue, fromDate: fromDateComponents, toDate: toDateComponents) { (obj, error) in
            
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil, error?.localizedDescription)
                }
                return
            }
            
            if let sbbReport = (obj as? [SBBReportData])?.last,
               let report = self.transformReportData(sbbReport, reportKey: reportId, category: SBAReportCategory.singleton) {
                DispatchQueue.main.async {
                    completion(report, nil)
                }
                return
            }
                                    
            DispatchQueue.main.async {
                completion(nil, nil)
            }
        }
    }
    
    open func createWakeSleepScheduleRequestData(mostRecentReport: SBAReport?) -> WakeSleepScheduleRequestData? {
        
        guard let clientData = mostRecentReport?.clientData.toJSONSerializable() as? String,
              let data = clientData.data(using: String.Encoding.utf8) else {
            print("Could not get the WakeSleep client data from report")
            return nil
        }
        
        do {
            let wakeSleep = try jsonDecoder.decode(WakeSleepScheduleRequestData.self, from: data)
            return wakeSleep
        } catch let error as NSError {
            print("Error while converting client data to WakeSleep format \(error)")
        }
        
        return nil
    }
    
    open func createTestScheduleRequestData(mostRecentReport: SBAReport?) -> TestScheduleRequestData? {
        
        guard let clientData = mostRecentReport?.clientData.toJSONSerializable() as? String,
              let data = clientData.data(using: String.Encoding.utf8) else {
            print("Could not get the TestSchedule client data from report")
            return nil
        }
        
        do {
            let testSchedule = try jsonDecoder.decode(TestScheduleRequestData.self, from: data)
            return testSchedule
        } catch let error as NSError {
            print("Error while converting client data to TestSchedule format \(error)")
        }
        
        return nil
    }
    
    open func uploadFullTestSession(session: FullTestSession) {
        var answersMap = [String: Any]()
        
        let isSessionFinished = ((session.finished_session ?? 0) > 0)

        // This app uploads missed sessions, so make sure that the
        // test is finished before we add it as a completed test for earnings
        if isSessionFinished,
           let earningsController = Arc.shared.earningsController as? SageEarningsController {
            
            // If we haven't calculated earnings yet, calculate it so that
            // we can see if any new achievements were earned
            if earningsController.mostRecentEarnings == nil {
                earningsController.updateEarnings()
            }
            
            self.completedTests.append(session: session)
            
            let totalEarningsStr = earningsController.calculateTotalEarnings()
            answersMap["totalEarnings"] = totalEarningsStr
        }
        
        answersMap["finished"] = isSessionFinished
        answersMap["week"] = session.week
        answersMap["day"] = session.day
        answersMap["session"] = session.session
        
        self.uploadData(identifier: "TestSession", data: session.encode(outputFormatting: .none), answersMap: answersMap)
    }
    
    open func uploadWakeSleepSchedule(schedule: WakeSleepScheduleRequestData) {
        let identifier = RSDIdentifier.availability
        guard let data = schedule.encode(outputFormatting: .none) else {
            debugPrint("Error: Invalid data for \(identifier).")
            return
        }
        // Upload to Synapse
        self.uploadData(identifier: "WakeSleep", data: data)
        
        // Save report for wake sleep schedule
        DispatchQueue.global(qos: .background).async {
            if let jsonStr = String(data: data, encoding: .utf8) {
                let report = self.newReport(reportIdentifier: identifier.rawValue,
                                            date: SBAReportSingletonDate,
                                            clientData: jsonStr as NSString)
                self.saveReport(report)
            }
        }
    }
    
    open func uploadStudyPeriodSchedule(schedule: TestScheduleRequestData) {
        let identifier = RSDIdentifier.testSchedule
        guard let data = schedule.encode(outputFormatting: .none) else {
            debugPrint("Error: Invalid data for \(identifier).")
            return
        }
        self.uploadData(identifier: "StudyPeriodSchedule", data: data)
        
        // Save report for the study session schedule
        DispatchQueue.global(qos: .background).async {
            if let jsonStr = String(data: data, encoding: .utf8) {
                let report = self.newReport(reportIdentifier: identifier.rawValue,
                                            date: SBAReportSingletonDate,
                                            clientData: jsonStr as NSString)
                self.saveReport(report)
            }
        }
    }
    
    open func uploadMigratedSuccessfullyReport(completion: SBBParticipantManagerCompletionBlock?) {
        let identifier = RSDIdentifier.migrated
        guard let data = MigratedStatus(status: true).encode(outputFormatting: .none) else {
            debugPrint("Error: Invalid data for \(identifier).")
            return
        }
        // Save report to show the migration algorithm that the user has
        // already converted over to bridge server
        DispatchQueue.global(qos: .background).async {
            if let jsonStr = String(data: data, encoding: .utf8) {
                let report = self.newReport(reportIdentifier: identifier.rawValue,
                                            date: SBAReportSingletonDate,
                                            clientData: jsonStr as NSString)
                self.saveReport(report, completion: completion)
            }
        }
    }
    
    open func uploadSignature(signature: Signature) {
        self.uploadData(identifier:"Signature", data: signature.data, dataName: "data.png")
    }
    
    private func uploadData(identifier: String, data: Data?, dataName: String = "data.json", answersMap: [String: Any] = [:]) {
        guard let dataUnwrapped = data else {
            debugPrint("Error: Invalid data for \(identifier).")
            return
        }
        
        let archive = SBBDataArchive(reference: identifier, jsonValidationMapping: nil)        
        
        do {
            let archiveFilename = dataName
            archive.insertData(intoArchive: dataUnwrapped, filename: archiveFilename, createdOn: Date())
            
            var metadata = [String: Any]()
            
            // Add answers dictionary data
            var mutableMap = [String: Any]()
            mutableMap["app"] = self.appType
                                    
            if let arcIdInt = Arc.shared.participantId {
                metadata[kExternalIdKey] = String(format: "%06d", arcIdInt)
                mutableMap["arcId"] = String(format: "%06d", arcIdInt)
            }
            
            answersMap.forEach({
                mutableMap[$0.key] = $0.value
            })
            archive.insertAnswersDictionary(mutableMap)
            
            // Add the current data groups and the user's arc id
            if let dataGroups = SBAParticipantManager.shared.studyParticipant?.dataGroups {
                metadata[kDataGroups] = dataGroups
            }
            
            // Insert the metadata dictionary
            archive.insertDictionary(intoArchive: metadata, filename: kMetadataFilename, createdOn: Date())
            
            // Set the correct schema revision version, this is required
            // for bridge to know that this archive has a schema
            let schemaRevisionInfo = SBABridgeConfiguration.shared.schemaInfo(for: identifier) ?? RSDSchemaInfoObject(identifier: identifier, revision: 1)
            archive.setArchiveInfoObject(schemaRevisionInfo.schemaVersion, forKey: kSchemaRevisionKey)
            
            try archive.complete()
            archive.encryptAndUploadArchive()
        } catch let error as NSError {
          print("Error while converting test to upload format \(error)")
        }
    }
    
    
    
    public func saveReport(_ report: SBAReport, completion: SBBParticipantManagerCompletionBlock?) {
        
        let reportIdentifier = report.reportKey.stringValue
        let bridgeReport = SBBReportData()

        // For a singleton, always set the date to a dateString that is the singleton date
        // in UTC timezone. This way it will always write to the report using that date.
        bridgeReport.data = report.clientData
        let formatter = NSDate.iso8601DateOnlyformatter()!
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let reportDate = SBAReportSingletonDate
        
        bridgeReport.localDate = formatter.string(from: reportDate)
        
        // Before we save the newest report, set it to need synced if its the completed tests
        if (reportIdentifier == RSDIdentifier.completedTests) {
            self.completedTests.isSyncedWithBridge = false
        }
        
        self.participantManager.save(bridgeReport, forReport: reportIdentifier) { [weak self] (_, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("Failed to save report: \(String(describing: error?.localizedDescription))")
                    self?.failedToSaveReport(report)
                    completion?(nil, error)
                    return
                }
                self?.successfullySavedReport(report)
                completion?(nil, nil)
            }
        }
    }
    
    /// Save an individual report to Bridge.
    ///
    /// - parameter report: The report object to save to Bridge.
    public func saveReport(_ report: SBAReport) {
        self.saveReport(report, completion: nil)
    }
    
    open func failedToSaveReport(_ report: SBAReport) {
        if (report.reportKey == RSDIdentifier.completedTests) {
            self.completedTests.isSyncedWithBridge = false
        }
    }
    
    open func successfullySavedReport(_ report: SBAReport) {
        if (report.reportKey == RSDIdentifier.completedTests) {
            self.completedTests.isSyncedWithBridge = true
        }
    }
    
    open func newReport(reportIdentifier: String, date: Date, clientData: SBBJSONValue) -> SBAReport {
        let reportDate = SBAReportSingletonDate
        let timeZone = TimeZone(secondsFromGMT: 0)!
        let jsonClientData = clientData.toJSONSerializable()
        
        return SBAReport.init(identifier: reportIdentifier, date: reportDate, json: jsonClientData, timeZone: timeZone)
    }
    
    open func transformReportData(_ report: SBBReportData, reportKey: RSDIdentifier, category: SBAReportCategory) -> SBAReport? {
        guard let reportData = report.data, let date = report.date else { return nil }
        
        if let json = reportData as? [String : Any],
            let clientData = json[kReportClientDataKey] as? JsonSerializable,
            let dateString = json[kReportDateKey] as? String,
            let timeZoneIdentifier = json[kReportTimeZoneIdentifierKey] as? String {
            let reportDate = self.factory.decodeDate(from: dateString) ?? date
            let timeZone = TimeZone(identifier: timeZoneIdentifier) ??
                TimeZone(iso8601: dateString) ??
                TimeZone.current
            
            return SBAReport.init(identifier: reportKey.rawValue, date: reportDate, json: clientData, timeZone: timeZone)
        }
        else {
            switch category {
            case .timestamp, .groupByDay:
                return SBAReport.init(identifier: reportKey.rawValue, date: date, json: reportData as! JsonSerializable, timeZone: TimeZone.current)
                
            case .singleton:
                let timeZone = TimeZone(secondsFromGMT: 0)!
                let reportDate: Date = {
                    if let localDate = report.localDate {
                        let dateFormatter = NSDate.iso8601DateOnlyformatter()!
                        dateFormatter.timeZone = timeZone
                        return dateFormatter.date(from: localDate) ?? date
                    }
                    else {
                        return date
                    }
                }()
                return SBAReport.init(identifier: reportKey.rawValue, date: reportDate, json: reportData as! JsonSerializable, timeZone: timeZone)
            }
        }
    }
}

open class UserDefaultsSingletonReport {
    var defaults: UserDefaults {
        return TaskListScheduleManager.shared.defaults
    }
    
    var isSyncingWithBridge = false
    var identifier: RSDIdentifier
    
    var isSyncedWithBridge: Bool {
        get {
            let key = "\(identifier.rawValue)SyncedToBridge"
            if self.defaults.object(forKey: key) == nil {
                return true // defaults to synced with bridge
            }
            return self.defaults.bool(forKey: "\(identifier.rawValue)SyncedToBridge")
        }
        set {
            self.defaults.set(newValue, forKey: "\(identifier.rawValue)SyncedToBridge")
        }
    }
    
    public init(identifier: RSDIdentifier) {
        self.identifier = identifier
    }
    
    // String? is the error message
    open func loadFromBridge(completion: @escaping ((String?) -> Void)) {
        // to be implemented by sub-class
    }
    
    open func syncToBridge() {
        // to be implemented by sub-class
    }
}

/**
 * Used to mark the user as migrated (a.k.a signed into bridge and off HM server)
 */
public struct MigratedStatus: Codable {
    public var status: Bool = false
}
