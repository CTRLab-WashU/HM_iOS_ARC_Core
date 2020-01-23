//
// ArcManager.swift
// Arc
//
//  Created by Philip Hayes on 9/26/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import Foundation
import UIKit
import HMMarkup
public protocol ArcApi {
	
}
public enum SurveyAvailabilityStatus {
    case available, laterToday, tomorrow, startingTomorrow(String), later(String, String), finished
}
open class Arc : ArcApi {
	
	var ARC_VERSION_INFO_KEY = "MH_VERSION"
	var APP_VERSION_INFO_KEY = "CFBundleShortVersionString"
    public var APP_PRIVACY_POLICY_URL = ""
    public var WELCOME_LOGO:UIImage? = nil
    public var WELCOME_TEXT = ""
	public var TEST_TIMEOUT:TimeInterval = 300; // 5 minute timeout if the application is closed
	public var TEST_START_ALLOWANCE:TimeInterval = -300; // 5 minute window before actual start time
	var STORE_DATA = false
	var FORGET_ON_RESTART = false
    lazy var arcInfo: NSDictionary? = {
        if let path = Bundle(for: Arc.self).path(forResource: "Info", ofType: "plist") {
            return NSDictionary(contentsOfFile: path)
            
        }
        return nil
    }()
	lazy var info: NSDictionary? = {
		if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
			return NSDictionary(contentsOfFile: path)
			
		}
		return nil
	}()
    lazy public var translation:ArcTranslation? = {
        do {
            guard let asset = NSDataAsset(name: "translation") else {
                return nil
            }
            let translation:ArcTranslation = try JSONDecoder().decode(ArcTranslation.self, from: asset.data)
        
            return translation
        } catch {
            dump(error)
        }
        return nil
    }()
    public var translationIndex = 1
	lazy public var deviceString = {deviceInfo();}()
	lazy public var deviceId = AppController().deviceId
	lazy public var versionString = {info?[APP_VERSION_INFO_KEY] as? String ?? ""}()
	lazy public var arcVersion:Int = {arcInfo?[ARC_VERSION_INFO_KEY] as? Int ?? 0;}()
    //A map of all of the possible states in the application
	
    static public let shared = Arc()
	
	public var appController:AppController = AppController()
	
	public var authController:AuthController = AuthController()
	
	public var sessionController:SessionController = SessionController()
	
	public var surveyController:SurveyController = SurveyController()
        
	public var scheduleController:ScheduleController = ScheduleController()
    
	public var gridTestController:GridTestController = GridTestController()
    
	public var pricesTestController:PricesTestController = PricesTestController()
    
	public var symbolsTestController:SymbolsTestController = SymbolsTestController()
	
	public var studyController:StudyController = StudyController()
	
	public var notificationController:NotificationController = NotificationController()
	
	public var appNavigation:AppNavigationController = BaseAppNavigationController()
	
	public var controllerRegistry:ArcControllerRegistry = ArcControllerRegistry()
	//Back this value up with local storage.
	//When the app terminates this value is released,
	//This will cause background processes to crash when fired.
	public var participantId:Int? {
		get {
			return appController.participantId
		}
		set {
			appController.participantId = newValue
		}
	}
    
    public var finishedPart:Int? {
        get {
            return appController.finishedPart
        }
        set {
            appController.finishedPart = newValue
        }
    }
    
    public var showMindfulness:Bool? {
        get {
            return appController.showMindfulness
        }
        set {
            appController.showMindfulness = newValue
        }
    }
    
    
	public var currentStudy:Int?
	public var availableTestSession:Int?
	public var currentTestSession:Int?
    static public var environment:ArcEnvironment?
	
	public init() {
		controllerRegistry.registerControllers()
	}
    static public func configureWithEnvironment(environment:ArcEnvironment) {
        self.environment = environment
        
        HMAPI.baseUrl = environment.baseUrl ?? ""
        
        _ = MHController.dataContext
        
        _ = HMAPI.shared
        CoreDataStack.useMockContainer = environment.mockData
        HMRestAPI.shared.blackHole = environment.blockApiRequests
        Arc.shared.appNavigation = environment.appNavigation
        Arc.shared.studyController = environment.studyController
        Arc.shared.authController = environment.authController
        Arc.shared.appController = environment.appController
        
        Arc.shared.surveyController = environment.surveyController
        Arc.shared.notificationController = environment.notificationController
        Arc.shared.scheduleController = environment.scheduleController
        Arc.shared.sessionController = environment.sessionController
        Arc.shared.gridTestController = environment.gridTestController
        Arc.shared.pricesTestController = environment.pricesTestController
        Arc.shared.symbolsTestController = environment.symbolsTestController
        
        let locale = Locale.current

        
        Arc.shared.setLocalization(country: Arc.shared.appController.country ?? locale.regionCode,
                                   language: Arc.shared.appController.language ?? locale.languageCode)

        
        
        Arc.shared.WELCOME_LOGO =  UIImage(named: environment.welcomeLogo ?? "")
        Arc.shared.WELCOME_TEXT = environment.welcomeText ?? ""
        Arc.shared.APP_PRIVACY_POLICY_URL = environment.privacyPolicyUrl ?? ""
      
        
        if let arcStartDays = environment.arcStartDays {
            Arc.shared.studyController.ArcStartDays = arcStartDays
        }
        environment.configure()
    }
    public func nextAvailableState(runPeriodicBackgroundTask:Bool = false, direction:UIWindow.TransitionOptions.Direction = .toRight) {
        appNavigation.navigate(state: appNavigation.nextAvailableState(runPeriodicBackgroundTask: runPeriodicBackgroundTask), direction: direction)
	}
	public func nextAvailableSurveyState() {
		appNavigation.navigate(state: appNavigation.nextAvailableSurveyState() ?? appNavigation.defaultState(), direction: .toRight)
	}
	
	
	
    
    public func displayAlert(message:String, options:[MHAlertView.ButtonType], isScrolling:Bool = false){
        let view:MHAlertView = (isScrolling) ? .get(nib: "MHScrollingAlertView") : .get()
        view.alpha = 0
        
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        guard let _ = window.rootViewController else {
            
            return
        }
        window.constrain(view: view)
        view.set(message: message, buttons: options)
        UIView.animate(withDuration: 0.35, delay: 0.1, options: .curveEaseOut, animations: {
            view.alpha = 1
        }) { (_) in
            
        }
    }
    public func setCountry(key:String?) {
        appController.country = key
    }
    public func setLanguage(key:String?) {
        appController.language = key
    }
	public func setLocalization(country:String?, language:String?, shouldTranslate:Bool = true) {
        
        let matchesBoth = Arc.shared.translation?.versions.filter {
            $0.map?["country_key"] == country && $0.map?["language_key"] == language
        }
        let matchesCountry = Arc.shared.translation?.versions.filter {
            $0.map?["country_key"] == country
        }
        let matchesLanguage = Arc.shared.translation?.versions.filter {
            $0.map?["language_key"] == language
        }
        
        var config = HMMarkupRenderer.Config()
        config.shouldTranslate = shouldTranslate
        switch (country, language) {
        
        case (nil, let l):
			
            config.translation = matchesLanguage?.first?.map

            break

        case (let c, nil):
            config.translation = matchesCountry?.first?.map

            break
        case (let c, let l):
            
            config.translation = matchesBoth?.first?.map

            break
        
        }
        HMMarkupRenderer.config = config

    }
    public func setLocalization(index:Int = 1) {
       
            var config = HMMarkupRenderer.Config()
            config.shouldTranslate = true
            config.translation = Arc.shared.translation?.versions[index].map
            HMMarkupRenderer.config = config
      
    }
	public func deviceInfo() -> String
	{
		let deviceString = " \(UIDevice.current.systemName)|\(deviceIdentifier())|\(UIDevice.current.systemVersion)";
		return deviceString;
	}
    
    public func uploadTestData() {
		sessionController.sendFinishedSessions()
		sessionController.sendMissedSessions()
		sessionController.sendSignatures()
		if !appController.testScheduleUploaded && !appController.testScheduleUploading{
			appController.testScheduleUploading = true
			let studies = Arc.shared.studyController.getAllStudyPeriods().sorted(by: {$0.studyID < $1.studyID})
			Arc.shared.sessionController.uploadSchedule(studyPeriods: studies)
		}
		if !appController.wakeSleepUploaded && !appController.wakeSleepUploading{
			appController.wakeSleepUploading = true
			if let study = Arc.shared.studyController.getAllStudyPeriods().sorted(by: {$0.studyID < $1.studyID}).first {
				Arc.shared.scheduleController.upload(confirmedSchedule: Int(study.studyID));
			}

		}
		
	}
	
	public func sendHeartBeat() {
		HMAPI.deviceHeartbeat.execute(data: HeartbeatRequestData()) { (response, data, _) in
			HMLog("Participant: \(self.participantId ?? -1), received response \(data?.toString() ?? "") on \(Date())")

		}
	}
  
	public func periodicBackgroundTask(timeout:TimeInterval = 20, completion: @escaping()->Void)
	{
		let now = Date();
		// check to see if we need to schedule any notifications for upcoming Arcs
		// If the participant hasn't confirmed their start date, we should send notifications periodically in the weeks leading up
		// to the Arc.
        let app = Arc.shared
        
        //Check for participant setup
        if app.participantId == nil {
            
            //If none set up go to auth
            guard let id = app.authController.checkAuth() else {
                completion();
                return
            }
            
            //set the id we can skip past this once set
            app.participantId = Int(id)
        }
        MHController.dataContext.performAndWait {

            HMAPI.deviceHeartbeat.execute(data: HeartbeatRequestData())
            uploadTestData()
		
        }
		
        if let study = studyController.getCurrentStudyPeriod()
        {
            let studyId = Int(study.studyID)
            MHController.dataContext.performAndWait {
                self.studyController.markMissedSessions(studyId: studyId)
                // we don't want to fire off the missed test notification while the app is open,
                // so we have to check to make sure it's in the background
                let isInBackground = UIApplication.shared.applicationState == .background
                if isInBackground {
                    print("Background Check")
                } else {
                    
                }
                let testMissed = studyController.get(consecutiveMissedSessionCount: studyId)
                let lastFlaggedMissedTestCount = app.appController.lastFlaggedMissedTestCount
                let hasPostedMissedTestNotification = app.notificationController.has(ScheduledMissedTestsNotification: studyId)
                let shouldPostNotification = testMissed - lastFlaggedMissedTestCount >= 4 && !hasPostedMissedTestNotification
            
                if isInBackground && shouldPostNotification
                {
                    app.appController.lastFlaggedMissedTestCount = testMissed
                    self.notificationController.schedule(missedTestsNotification: studyId)
                    
                    
                }
                Arc.shared.notificationController.save()
            }
  
        }
        
		if let study = studyController.getCurrentStudyPeriod()
		{
			let studyId = Int(study.studyID)
			MHController.dataContext.performAndWait {
                Arc.shared.notificationController.clear(sessionNotifications: Int(studyId))
                Arc.shared.notificationController.schedule(upcomingSessionNotificationsWithLimit: 32)
				Arc.shared.notificationController.save()
			}

		}
		
		
		if let study = studyController.getUpcomingStudyPeriod()
		{
			let studyId = Int(study.studyID)
            if Arc.environment?.shouldDisplayDateReminderNotifications ?? false {
                _ = Arc.shared.notificationController.scheduleDateConfirmationsForUpcomingStudy()
            }
			if  let startDate = study.userStartDate as Date?
			{
				if study.hasConfirmedDate == false
				{

					if notificationController.has(scheduledDateReminder: studyId) == false
					{
//						notificationController.schedule(dateRemdinderNotification: study);
					}

					if notificationController.has(scheduledConfirmationReminders: studyId) == false
					{
//						study.scheduleConfirmationReminders();

					}
				}
				else
				{
					
//					study.clearConfirmationReminders();
//					study.clearDateReminderNotification();
				}

				// if we're one day away, and we haven't scheduled sessions yet, do so now.
				if startDate.daysSince(date: now) == 1 &&
					study.hasScheduledNotifications == false
				{
//					study.createTestSessions();
//					study.scheduleSessionNotifications();
					notificationController.schedule(sessionNotifications: studyId)
				}
			}
		}
		
		
		// Now check if we have any past visits  that need to be marked as missed
		
		let studies  = studyController.getPastStudyPeriods()
		
		for study in studies
		{
			MHController.dataContext.performAndWait {
				self.studyController.markMissedSessions(studyId: Int(study.studyID));

			}
			if STORE_DATA == false
			{
				// delete any past Arcs that have had all of their data uploaded successfully
				let sessions = studyController.get(allSessionsForStudy: Int(study.studyID));
				
				var hasUploadedAll:Bool = true;
				for session in sessions
				{
					if session.uploaded == false
					{
						hasUploadedAll = false;
						break;
					}
				}
				
				if hasUploadedAll
				{
					MHController.dataContext.performAndWait {
						
						HMLog("Deleting Visit \(study.studyID)");
						for session in sessions
						{
                            session.clearData()
						}
						
						self.studyController.save();
					}
				}
			}
		}
		uploadTestData()
	
		
		completion();
		
	}
	public func startTestIfAvailable() -> Bool {
		let app = Arc.shared
		
		guard let study = app.studyController.getCurrentStudyPeriod() else {
			return false
		}
		//If we have a current session store it here.
		guard let id = app.studyController.get(availableTestSession: Int(study.studyID))?.sessionID else {
			app.availableTestSession = nil
			return false
		}
		app.currentStudy = Int(study.studyID)
		app.currentTestSession = Int(id)
		app.studyController.mark(started: Int(id), studyId: Int(study.studyID))
		Arc.shared.appController.lastClosedDate = nil;
		
		return true
		
			
		
	}
    
   
    open func getSurveyStatus() -> SurveyAvailabilityStatus {
        var upcoming:Session?
        var session:Int?
        if let s = currentStudy {
            
            upcoming = studyController.get(upcomingSessions: Int(s)).first
            
            if let sess = availableTestSession {
                session = sess
            }
        }
        if upcoming == nil, let nextCycle = studyController.getUpcomingStudyPeriod()?.sessions?.firstObject as? Session {
            upcoming = nextCycle
        }
        // Do any additional setup after loading the view.
        if let _ = session {
            
            return .available
        } else {
            
            if let upcoming = upcoming {
                let d = DateFormatter()
                let date = upcoming.sessionDate ?? Date()
                
                if date.isToday() {
                    
                    return .laterToday
                } else if date.isTomorrow() {
                    if Arc.shared.studyController.getCurrentStudyPeriod() == nil {
                        let dateString = date.localizedFormat(template: ACDateStyle.longWeekdayMonthDay.rawValue, options: 0, locale: nil)
                        return .startingTomorrow(dateString)
                    }
                    return .tomorrow
                } else {
                    let dateString = date.localizedFormat(template: ACDateStyle.longWeekdayMonthDay.rawValue, options: 0, locale: nil)
                    let endDateString = date.addingDays(days: 6).localizedFormat(template: ACDateStyle.longWeekdayMonthDay.rawValue, options: 0, locale: nil)
                    return .later(dateString, endDateString)
                }
            } else {
                
                return .finished
            }
            
            
        }
    }
    public func debugSchedule() {
        let dateFrame = studyController.getCurrentStudyPeriod()?.userStartDate ?? Date()
        let lastFetch = appController.lastBackgroundFetch?.localizedFormat()
        let list = studyController.getUpcomingSessions(withLimit: 332, startDate: dateFrame as NSDate)
            .map({
                " \($0.study?.studyID ?? -1)-\($0.sessionID): \($0.sessionDate?.localizedString() ?? "") \(($0.finishedSession) ? "√" : "\(($0.missedSession) ? "x" : "\(($0.startTime == nil) ? "-" : "o")")")"
                
            }).joined(separator: "\n")
        
        print(list)
        
        displayAlert(message:  """
            Study: \(currentStudy ?? -1)
            
            Test: \(availableTestSession ?? -1)
            
            Last background Fetch:
            \(String(describing: (lastFetch != nil) ? lastFetch : "None"))
            
            Last flagged missed test count: \(appController.lastFlaggedMissedTestCount)
            
            \(list)
            """, options:  [.default("Notifications", {[weak self] in self?.debugNotifications()}),
                            .cancel("Close", {})],
                 isScrolling: true)
    }
    public func debugNotifications() {
        
        let list = notificationController.getNotifications(withIdentifierPrefix: "TestSession").map({"\($0.studyID)-\($0.sessionID): \($0.scheduledAt!.localizedString())\n"}).joined()
        let preTestNotifications = notificationController.getNotifications(withIdentifierPrefix: "DateReminder").map({"\($0.studyID)-\($0.sessionID): \($0.scheduledAt!.localizedString())\n"}).joined()
        
        displayAlert(message:  """
            Study: \(currentStudy ?? -1)
            
            Test: \(availableTestSession ?? -1)
            
            \(list)
            Date Reminders:
            \(preTestNotifications)
            """, options:  [.default("Schedule", {[weak self] in self?.debugSchedule()}),
                            .cancel("Close", {})],
                 isScrolling: true)
    }
}

