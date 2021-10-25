//
//  TaskListScheduleManager.swift
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

import UIKit
import CoreData
import Research
import BridgeApp
import BridgeAppUI
import BridgeSDK
import ArcUIKit
import JsonModel

extension RSDIdentifier {
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
    
    let SHARING_SCOPE_ALL = "all_qualified_researchers"
    let PARTICIPANT_ATTRIBUTES = "attributes"
    let PARTICIPANT_STUDY_IDS = "studyIds"
    let PARTICIPANT_EXTERNAL_IDS = "externalIds"
    
    let ATTRIBUTE_VERIFICATION_CODE = "VERIFICATION_CODE"
    let ATTRIBUTE_IS_MIGRATED = "IS_MIGRATED"
    let ATTRIBUTE_VALUE_TRUE = "true"
    
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
        
        let reportIds: [RSDIdentifier] = [.availability, .testSchedule]
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
    
    open func uploadSignature(signature: Signature) {
        self.uploadData(identifier:"Signature", data: signature.data, dataName: "data.png")
    }
    
    private func uploadData(identifier: String, data: Data?, dataName: String = "data.json", answersMap: [String: Any] = [:]) {
        guard let dataUnwrapped = data else {
            debugPrint("Error: Invalid data for \(identifier).")
            return
        }
        
        print("Uploading archive \(identifier)")
        let archive = SBBDataArchive(reference: identifier, jsonValidationMapping: nil)        
        
        do {
            let archiveFilename = dataName
            archive.insertData(intoArchive: dataUnwrapped, filename: archiveFilename, createdOn: Date())
            
            var metadata = [String: Any]()
            
            // Add answers dictionary data
            var mutableMap = [String: Any]()
                                    
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
                metadata[kDataGroups] = dataGroups.joined(separator:",")
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
        
        print("Saving report \(reportIdentifier) with clientData:\n\(report.clientData as? String)")
        
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
        
        // ClientData is a String when uploaded by the iOS/Android app
        var serializable = reportData.toJSONSerializable()
        // However, if edited through Bridge, ClientData shows up as a Dictionary
        if let dictionary = serializable as? [AnyHashable: Any] {
            // Client data was edited on Bridge
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dictionary)
                if let jsonStr = String(data: jsonData, encoding: .utf8) {
                    serializable = jsonStr
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        switch category {
        case .timestamp, .groupByDay:
            return SBAReport.init(identifier: reportKey.rawValue, date: date, json: serializable, timeZone: TimeZone.current)
            
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
            return SBAReport.init(identifier: reportKey.rawValue, date: reportDate, json: serializable, timeZone: timeZone)
        }
    }
    
    public static let migrationDataKey = "migrationDataKey"
    public static let migrationSteps = 11

    public func userNeedsToMigrate(participantId: String?, externalId: String?) -> Bool {
        if (participantId == nil) {
            return false
        }
        // A user needs to migrate, if they have previously been assigned an Arc ID,
        // But they are not signed into Bridge with their External ID equal to their Arc ID.
        return participantId != externalId
    }
    
    public func arcIdString() -> String? {
        guard let arcIdInt = Arc.shared.participantId else {
            return nil
        }
        return String(format: "%06d", arcIdInt)
    }
    
    public func saveMigrationStateImmediately(data: MigrationData) {
        do {
            let jsonData = try jsonEncoder.encode(data)
            Arc.shared.appController.defaults.set(
                jsonData, forKey: TaskListScheduleManager.migrationDataKey)
        } catch {
            print("Error encoding migration data to json")
        }
    }
    
    public func removeMigrationStateImmediately() {
        Arc.shared.appController.defaults.removeObject(
            forKey: TaskListScheduleManager.migrationDataKey)
    }
    
    public func loadMigrationState() -> MigrationData? {
        guard let jsonData = Arc.shared.appController.defaults.data(
            forKey: TaskListScheduleManager.migrationDataKey) else {
            return nil
        }
        do {
            return try jsonDecoder.decode(MigrationData.self, from: jsonData)
        } catch {
            print("Error decoding migration data from json")
        }
        return nil
    }
    
    var TODO_REMOVE = 0
    /**
     * @return true if the user needs to migrate from HM to Sage bridge server, false otherwise
     */
    public func userNeedsToMigrate() -> Bool {
        let dataMigration = loadMigrationState()
        // We were in the middle of a migration, when something went wrong, continue
        if (dataMigration != nil) {
            return true
        }
        let arcID = arcIdString()
        let externalId = SBAParticipantManager.shared.studyParticipant?.externalId
        return userNeedsToMigrate(participantId: arcID, externalId: externalId)
    }
    
    public func migrateUserToSageBridge(completionListener: MigrationCompletedListener) {
        guard let arcId = arcIdString() else {
            completionListener.failure(errorString: ("Could not migrate user without Arc ID"))
            return
        }
        let deviceId = Arc.shared.deviceId
        let dataMigration = loadMigrationState() ??
            MigrationData.initial(arcId: arcId, deviceId: deviceId)
        
        migrateUser(completionListener: completionListener,
                    migration: dataMigration)
    }
    
    private func saveAndContinueMigration(completionListener: MigrationCompletedListener,
                                          newMigration: MigrationData) {
        // Wait a 100 milliseconds for Bridge SDK to finish its moves
        DispatchQueue.main.asyncAfter(deadline: (.now() + 0.1), execute: { [weak self] in
            self?.saveMigrationStateImmediately(data: newMigration)
            self?.migrateUser(completionListener: completionListener,
                             migration: newMigration)
        })
    }

    private func migrationError(completionListener: MigrationCompletedListener, errorStr: String) {
        DispatchQueue.main.async {
            let arcID = self.arcIdString() ?? ""
            let deviceId = Arc.shared.deviceId
            print(errorStr)
            completionListener.failure(errorString: "\(errorStr)\n\(arcID)\n\(deviceId)")
        }
    }
    
    /**
     * Migrating existing users
     * A user is existing if they have an Arc ID, a site location, and a Device ID.
     *
     * When the HM user opens the app after updating to Sage's app,
     * they will not have their account created yet with their Arc ID as their External ID.
     * Instead, the migration code will have created an External ID that is their Device ID
     * and the password for this account will also be their Device ID.
     *
     * The migration code marks this user with the test_user data group,
     * has their user attribute IS_MIGRATED set to false,
     * and has populated the account with that user’s data.
     */
    public func migrateUser(completionListener: MigrationCompletedListener,
                            migration: MigrationData) {
        
        var progressCtr = 0

        // First step of migration, sign-in to using device-id and save user attributes
        progressCtr += 1
        if (migration.studyId == nil || migration.attributes == nil) {
            completionListener.progressUpdate(progress: progressCtr)
            let what = "signing in with device-id "
            print(what)
            BridgeSDK.authManager.signIn(withExternalId: migration.deviceId,
                                         password:migration.deviceId) { Session, result, error in
                if let errorStr = error?.localizedDescription {
                    self.migrationError(completionListener: completionListener,
                                        errorStr: "Error \(what) \(errorStr)")
                    return
                }
                guard let respDict = result as? [String: Any],
                      let attributes = respDict[self.PARTICIPANT_ATTRIBUTES] as? [String: String],
                      let studyId = (respDict[self.PARTICIPANT_STUDY_IDS] as? [String])?.first else {
                    self.migrationError(completionListener: completionListener,
                                        errorStr: "Error \(what) parsing error")
                    return
                }

                let newMigration = migration.copy(studyId: studyId, attributes: attributes)
                self.saveAndContinueMigration(completionListener: completionListener,
                                              newMigration: newMigration)
            }
            return
        }

        // Next step of migration, load the Completed Tests user report
        progressCtr += 1
        if (migration.completedTestJson == nil) {
            completionListener.progressUpdate(progress: progressCtr)
            let what = "getting CompletedTestsIdentifier report "
            print(what)
            getSingletonReport(reportId: .completedTests) { report, error in
                if let errorStr = error {
                    self.migrationError(completionListener: completionListener,
                                        errorStr: "Error \(what) \(errorStr)")
                    return
                }
                let json = report?.clientData.toJSONSerializable() as? String
                let newMigration = migration.copy(completedTestJson: json ?? "")
                self.saveAndContinueMigration(completionListener: completionListener,
                                              newMigration: newMigration)
            }
            return
        }

        // Next step of migration, load the test sessions schedules user report
        progressCtr += 1
        if (migration.sessionScheduleJson == nil) {
            completionListener.progressUpdate(progress: progressCtr)
            let what = "getting TestScheduleIdentifier report "
            print(what)
            getSingletonReport(reportId: .testSchedule) { report, error in
                if let errorStr = error {
                    self.migrationError(completionListener: completionListener,
                                        errorStr: "Error \(what) \(errorStr)")
                    return
                }
                let json = report?.clientData.toJSONSerializable() as? String
                let newMigration = migration.copy(sessionScheduleJson: json ?? "")
                self.saveAndContinueMigration(completionListener: completionListener,
                                              newMigration: newMigration)
            }
            return
        }

        // Next step of migration, load the wake sleep schedule user report
        progressCtr += 1
        if (migration.wakeSleepScheduleJson == nil) {
            completionListener.progressUpdate(progress: progressCtr)
            let what = "getting AvailabilityIdentifier report "
            print(what)
            getSingletonReport(reportId: .availability) { report, error in
                if let errorStr = error {
                    self.migrationError(completionListener: completionListener,
                                        errorStr: "Error \(what) \(errorStr)")
                    return
                }
                let json = report?.clientData.toJSONSerializable() as? String
                let newMigration = migration.copy(wakeSleepScheduleJson: json ?? "")
                self.saveAndContinueMigration(completionListener: completionListener,
                                              newMigration: newMigration)
            }
            return
        }

        // Next step is to mark the device-id user as migrated
        progressCtr += 1
        if (migration.isMigrated == nil) {
            completionListener.progressUpdate(progress: progressCtr)
            let what = "marking Device ID user as migrated "
            print(what)
            
            var newAttributes = migration.attributes ?? [String: String]()
            newAttributes[ATTRIBUTE_IS_MIGRATED] = ATTRIBUTE_VALUE_TRUE
            var participant = [String: [String: Any]]()
            participant[PARTICIPANT_ATTRIBUTES] = newAttributes
            
            BridgeSDK.participantManager.updateParticipantRecord(withRecord: participant) { response, error in
                if let errorStr = error?.localizedDescription {
                    self.migrationError(completionListener: completionListener,
                                        errorStr: "Error \(what) \(errorStr)")
                    return
                }
                let newMigration = migration.copy(isMigrated: true)
                self.saveAndContinueMigration(completionListener: completionListener,
                                              newMigration: newMigration)
            }
            return
        }

        // Next step is to sign out of Bridge
        progressCtr += 1
        if (migration.isSignedOutOfDeviceId == nil) {
            completionListener.progressUpdate(progress: progressCtr)
            let what = "signing out of Device ID user "
            print(what)
            BridgeSDK.authManager.signOut { Session, Response, error in
                if let errorStr = error?.localizedDescription {
                    if (!errorStr.contains("Not signed in")) {
                        self.migrationError(completionListener: completionListener,
                                            errorStr: "Error \(what) \(errorStr)")
                    }
                }
                let newMigration = migration.copy(isSignedOutOfDeviceId: true)
                self.saveAndContinueMigration(completionListener: completionListener,
                                              newMigration: newMigration)
            }
            return
        }

        // Next step is to create a new user on Bridge with Arc ID, and a secure random password
        progressCtr += 1
        if (migration.newUserPassword == nil) {
            completionListener.progressUpdate(progress: progressCtr)
            let what = "signing up Arc ID user "
            print(what)
            
            let arcId = migration.arcId
            var signUpDictionary = [AnyHashable: Any]()
            var externalIds = [String: String]()
            externalIds[migration.studyId ?? ""] = arcId
            signUpDictionary[self.PARTICIPANT_EXTERNAL_IDS] = externalIds
            
            // ExternalIds is get-only, so we need to feed it into the constructor as a dictionary
            guard let signUp = SBBSignUp(dictionaryRepresentation: signUpDictionary) else {
                migrationError(completionListener: completionListener,
                               errorStr: "Error \(what) creating SBBSignUp")
                return
            }
            guard let password = SecureTokenGenerator.BRIDGE_PASSWORD.nextBridgePassword() else {
                migrationError(completionListener: completionListener,
                               errorStr: "Error \(what) creating password")
                return
            }
            
            signUp.password = password
            signUp.sharingScope = self.SHARING_SCOPE_ALL
            
            // Here on Android, we add the attributes to the sign up; however,
            // the iOS SDK is out-dated in the way it handles attributes (Obj-C) properties
            // So we will need to do another API call for that after this step
            
            BridgeSDK.authManager.signUpStudyParticipant(signUp) { session, result, error in
                if let errorStr = error?.localizedDescription {
                    self.migrationError(completionListener: completionListener,
                                        errorStr: "Error \(what) \(errorStr)")
                    return
                }
                let newMigration = migration.copy(newUserPassword: password)
                self.saveAndContinueMigration(completionListener: completionListener,
                                              newMigration: newMigration)
            }
            return
        }

        // First step of migration, sign-in to using device-id and save user attributes
        progressCtr += 1
        if (migration.isNewUserAuthenticated == nil) {
            completionListener.progressUpdate(progress: progressCtr)
            let what = "signing in with Arc ID "
            print(what)
            
            let arcId = migration.arcId
            guard let password = migration.newUserPassword else {
                migrationError(completionListener: completionListener,
                               errorStr: "Error \(what) accessing password")
                return
            }
            BridgeSDK.authManager.signIn(withExternalId: arcId,
                                         password:password) { Session, result, error in
                if let errorStr = error?.localizedDescription {
                    self.migrationError(completionListener: completionListener,
                                        errorStr: "Error \(what) \(errorStr)")
                    return
                }
                let newMigration = migration.copy(isNewUserAuthenticated: true)
                self.saveAndContinueMigration(completionListener: completionListener,
                                              newMigration: newMigration)
            }
            return
        }
        
        // Next step is to mark the device-id user as migrated
        progressCtr += 1
        if (migration.isNewUserAttributesUpdated == nil) {
            completionListener.progressUpdate(progress: progressCtr)
            let what = "updating attributes for Arc ID user "
            print(what)
            
            var newAttributes = migration.attributes ?? [String: String]()
            newAttributes[self.ATTRIBUTE_VERIFICATION_CODE] = migration.newUserPassword ?? ""
            newAttributes[self.ATTRIBUTE_IS_MIGRATED] = "" // Remove migration status
            var participant = [String: [String: Any]]()
            participant[PARTICIPANT_ATTRIBUTES] = newAttributes
            
            BridgeSDK.participantManager.updateParticipantRecord(withRecord: participant) { response, error in
                if let errorStr = error?.localizedDescription {
                    self.migrationError(completionListener: completionListener,
                                        errorStr: "Error \(what) \(errorStr)")
                    return
                }
                let newMigration = migration.copy(isNewUserAttributesUpdated: true)
                self.saveAndContinueMigration(completionListener: completionListener,
                                              newMigration: newMigration)
            }
            return
        }

        // Next step is to upload the completed test user report
        progressCtr += 1
        if (migration.completedTestUploaded == nil) {
            completionListener.progressUpdate(progress: progressCtr)
            let what = "uploading CompletedTestsIdentifier report "
            print(what)
            
            let jsonStr = (migration.completedTestJson ?? "")
            let report = self.newReport(reportIdentifier: RSDIdentifier.completedTests.rawValue,
                                        date: SBAReportSingletonDate,
                                        clientData: jsonStr as NSString)
            self.saveReport(report) { response, error in
                if let errorStr = error?.localizedDescription {
                    self.migrationError(completionListener: completionListener,
                                        errorStr: "Error \(what) \(errorStr)")
                    return
                }
                // If there is data we should parse it and send it to the earnings controller
                if jsonStr.count > 0 {
                    do {
                        let jsonData = jsonStr.data(using: .utf8)!
                        let completedTestList = try self.jsonDecoder
                            .decode(CompletedTestList.self, from: jsonData)
                        self.completedTests.setCurrent(completedTestList)
                        // Removing this key will force an earnings reload
                        Arc.shared.appController.delete(forKey: EarningsController.overviewKey)
                    } catch {
                        self.migrationError(completionListener: completionListener,
                                            errorStr: "Error \(what) decoding completed tests")
                        return
                    }
                }
                let newMigration = migration.copy(completedTestUploaded: true)
                self.saveAndContinueMigration(completionListener: completionListener,
                                              newMigration: newMigration)
            }
            return
        }

        // Next step is to upload the test session schedule report
        progressCtr += 1
        if (migration.sessionScheduleUploaded == nil) {
            completionListener.progressUpdate(progress: progressCtr)
            let what = "uploading TestScheduleIdentifier report "
            print(what)
            
            let jsonStr = (migration.sessionScheduleJson ?? "")
            let report = self.newReport(reportIdentifier: RSDIdentifier.testSchedule.rawValue,
                                        date: SBAReportSingletonDate,
                                        clientData: jsonStr as NSString)
            self.saveReport(report) { response, error in
                if let errorStr = error?.localizedDescription {
                    self.migrationError(completionListener: completionListener,
                                        errorStr: "Error \(what) \(errorStr)")
                    return
                }
                let newMigration = migration.copy(sessionScheduleUploaded: true)
                self.saveAndContinueMigration(completionListener: completionListener,
                                              newMigration: newMigration)
            }
            return
        }

        // Last step is to upload the test session schedule report
        progressCtr += 1
        if (migration.wakeSleepScheduleUploaded == nil) {
            completionListener.progressUpdate(progress: progressCtr)
            let what = "uploading AvailabilityIdentifier report "
            print(what)
            
            let jsonStr = (migration.wakeSleepScheduleJson ?? "")
            let report = self.newReport(reportIdentifier: RSDIdentifier.availability.rawValue,
                                        date: SBAReportSingletonDate,
                                        clientData: jsonStr as NSString)
            self.saveReport(report) { response, error in
                if let errorStr = error?.localizedDescription {
                    self.migrationError(completionListener: completionListener,
                                        errorStr: "Error \(what) \(errorStr)")
                    return
                }
                let newMigration = migration.copy(wakeSleepScheduleUploaded: true)
                self.saveAndContinueMigration(completionListener: completionListener,
                                              newMigration: newMigration)
            }
            return
        }

        // Remove traces of successful migrations
        self.removeMigrationStateImmediately()
        // We are done with migration!
        DispatchQueue.main
        completionListener.success()
    }
}

public protocol MigrationCompletedListener: AnyObject {
    func progressUpdate(progress: Int)
    func success()
    func failure(errorString: String)
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

public struct MigrationData: Codable {
    var arcId: String
    var deviceId: String
    var studyId: String? = nil
    var attributes: [String: String]?  = nil
    var completedTestJson: String? = nil
    var sessionScheduleJson: String? = nil
    var wakeSleepScheduleJson: String? = nil
    var isMigrated: Bool? = nil
    var isSignedOutOfDeviceId: Bool? = nil
    var newUserPassword: String? = nil
    var isNewUserAuthenticated: Bool? = nil
    var isNewUserAttributesUpdated: Bool? = nil
    var completedTestUploaded: Bool? = nil
    var sessionScheduleUploaded: Bool? = nil
    var wakeSleepScheduleUploaded: Bool? = nil
    
    public static func initial(arcId: String, deviceId: String) -> MigrationData {
        return MigrationData(arcId: arcId, deviceId: deviceId)
    }
    
    public func copy(studyId: String? = nil,
                     attributes: [String: String]?  = nil,
                     completedTestJson: String? = nil,
                     sessionScheduleJson: String? = nil,
                     wakeSleepScheduleJson: String? = nil,
                     isMigrated: Bool? = nil,
                     isSignedOutOfDeviceId: Bool? = nil,
                     newUserPassword: String? = nil,
                     isNewUserAuthenticated: Bool? = nil,
                     isNewUserAttributesUpdated: Bool? = nil,
                     completedTestUploaded: Bool? = nil,
                     sessionScheduleUploaded: Bool? = nil,
                     wakeSleepScheduleUploaded: Bool? = nil) -> MigrationData {
        
        return MigrationData(
            arcId: self.arcId,
            deviceId: self.deviceId,
            studyId: studyId ?? self.studyId,
            attributes: attributes ?? self.attributes,
            completedTestJson: completedTestJson ?? self.completedTestJson,
            sessionScheduleJson: sessionScheduleJson ?? self.sessionScheduleJson,
            wakeSleepScheduleJson: wakeSleepScheduleJson ?? self.wakeSleepScheduleJson,
            isMigrated: isMigrated ?? self.isMigrated,
            isSignedOutOfDeviceId: isSignedOutOfDeviceId ?? self.isSignedOutOfDeviceId,
            newUserPassword: newUserPassword ?? self.newUserPassword,
            isNewUserAuthenticated: isNewUserAuthenticated ?? self.isNewUserAuthenticated,
            isNewUserAttributesUpdated: isNewUserAttributesUpdated ?? self.isNewUserAttributesUpdated,
            completedTestUploaded: completedTestUploaded ?? self.completedTestUploaded,
            sessionScheduleUploaded: sessionScheduleUploaded ?? self.sessionScheduleUploaded,
            wakeSleepScheduleUploaded: wakeSleepScheduleUploaded ?? self.wakeSleepScheduleUploaded)
    }
}
