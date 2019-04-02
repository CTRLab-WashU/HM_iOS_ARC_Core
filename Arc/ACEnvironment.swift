//
//  Environment.swift
//  Arc
//
//  Created by Philip Hayes on 12/11/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import Foundation

public protocol ArcEnvironment {
    var mockData:Bool {get}
    var blockApiRequests:Bool {get}
    var baseUrl:String? {get}
    var welcomeLogo:String? {get}
    var welcomeText:String? {get}
    var privacyPolicyUrl:String? {get}
    var arcStartDays:Dictionary<Int, Int>? {get}
    var shouldDisplayDateReminderNotifications:Bool {get}
    
    var appController:AppController {get}
    
    var authController:AuthController {get}
    
    var sessionController:SessionController {get}
    
    var surveyController:SurveyController {get}
    
    var scheduleController:ScheduleController {get}
    
    var gridTestController:GridTestController {get}
    
    var pricesTestController:PricesTestController {get}
    
    var symbolsTestController:SymbolsTestController {get}
    
    var studyController:StudyController {get}
    
    var notificationController:NotificationController {get}
    
    var appNavigation:AppNavigationController {get}
    
    var controllerRegistry:ArcControllerRegistry {get}
    
    func configure()

}

public extension ArcEnvironment {
    
    //This will trigger a flag that causes coredata to use a mock
    //persistent store, an in-memory database. 
    public var mockData:Bool {return false}
    public var shouldDisplayDateReminderNotifications:Bool {return false}

    public var appController:AppController {return AppController()}
    
    public var authController:AuthController {return AuthController()}
    
    public var sessionController:SessionController {return SessionController()}
    
    public var surveyController:SurveyController {return SurveyController()}
    
    public var scheduleController:ScheduleController {return ScheduleController()}
    
    public var gridTestController:GridTestController {return GridTestController()}
    
    public var pricesTestController:PricesTestController {return PricesTestController()}
    
    public var symbolsTestController:SymbolsTestController {return SymbolsTestController()}
    
    public var studyController:StudyController {return StudyController()}
    
    public var notificationController:NotificationController {return NotificationController()}
    
    
    public var controllerRegistry:ArcControllerRegistry {return ArcControllerRegistry()}


    public func configure() {}
}
