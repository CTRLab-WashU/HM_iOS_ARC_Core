//
//  Session+Extensions.swift
// Arc
//
//  Created by Philip Hayes on 10/15/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import Foundation
import CoreData
public extension Session {
	
	public func isAvailableForState(state:State) -> Bool {
		
		let surveyType = state.surveyTypeForState()
		guard let survey = surveyFor(surveyType: surveyType) else {
			return false
		}
		
		return !survey.isFilledOut

	}
	
	public func isLastSession() -> Bool
	{
		if self.study == nil || self.study!.sessions == nil
		{
			return false;
		}
		
		return self.study!.sessions!.index(of: self) == self.study!.sessions!.count - 1;
	}
	
	public func isFirstSession() -> Bool
	{
		if self.study == nil || self.study!.sessions == nil
		{
			return false;
		}
		
		return self.study!.sessions!.index(of: self) == 0;
	}
	
	public func hasTakenWakeSurvey() -> Bool
	{
		return true
	}
	public func typeNamesForSession() -> [String] {
		let data = sessionData as! Set<JSONData>
		var set:Set<String> = []
		for obj in data {
			if ["gridTest","symbolsTest","priceTest","context", "chronotype","wake"].contains(obj.type) {
				set.insert(SurveyType.cognitive.rawValue)
			} else {
				set.insert( obj.type!)
			}
		}
		
		
		return Array(set)
	}
	
	public func surveyFor(surveyType:SurveyType) -> JSONData? {
		let data = sessionData as! Set<JSONData>
		let obj = data.filter { (data) -> Bool in
			return data.type == surveyType.rawValue
		}
		return obj.first
	}
	// clears all useful data from the Session. It only keeps data related to start date, which Arc it's part of,
	// and whether or not it was finished or missed.
	
	public func clearData()
	{
		let relationships = self.entity.relationshipsByName;
		
		// delete all of the relationships
		for (name, _) in relationships
		{
			if name == "study"
			{
				continue;
			}
			
			if let v = self.value(forKey: name) as? NSManagedObject
			{
				CoreDataStack.shared.persistentContainer.newBackgroundContext().delete(v)
			}
		}
		
		// and now clear out any data we don't absolutely need to keep the app running
		self.completeTime = nil;
		self.endSignature = nil;
		self.startSignature = nil;
		self.startTime = nil;
		self.willUpgradePhone = false;
		self.interrupted = false;
		
		CoreDataStack.shared.saveContext()
		
		// and now, delete any notifications
		
//		NotificationEntry.clearPastNotifications();
		
	}
	
	public func createSurveyFor(surveyType:SurveyType) {
		switch surveyType {
		case .edna, .ema, .context, .mindfulness, .chronotype, .wake:
			let surveyController = Arc.shared.surveyController
			let survey = surveyController.create(type: surveyType)
			let data = surveyController.fetch(id: survey)
			data?.type = surveyType.rawValue
			self.addToSessionData(data!)
			
		case .gridTest:
			let controller = Arc.shared.gridTestController
			let test = controller.createResponse(numSections: 2)
			let data = controller.fetch(id: test)
			data?.type = surveyType.rawValue
            self.addToSessionData(data!)
            
		case .priceTest:
			let controller =  Arc.shared.pricesTestController
			let priceTest = controller.loadTest(index: Int(sessionID), file: PricesTestViewController.testVersion)
			let response = controller.createResponse(withTest: priceTest)
			let data = controller.fetch(id: response)
			data?.type = surveyType.rawValue
			self.addToSessionData(data!)
            
		case .symbolsTest:
			let controller = Arc.shared.symbolsTestController
			let test = controller.generateTest(numSections: 12, numSymbols: 8)
			let response = controller.createResponse(withTest: test)
			let data = controller.fetch(id: response)
			data?.type = surveyType.rawValue
			self.addToSessionData(data!)
            
		default:
			break
		}
	}
    
    
    public func createGridTest() -> GridTestResponse
    {
        let controller = Arc.shared.gridTestController
        let test = controller.createGridTestResponse(numSections: 2)
        return test;
    }
    
    public func createPriceTest() -> PriceTestResponse
    {
        let controller =  Arc.shared.pricesTestController
        let priceTest = controller.loadTest(index: Int(sessionID), file: PricesTestViewController.testVersion)
        let response = controller.createPriceTestResponse(withTest: priceTest)
        return response;
    }
    
    public func createSymbolsTest() -> SymbolsTestResponse
    {
        let controller = Arc.shared.symbolsTestController
        let test = controller.generateTest(numSections: 12, numSymbols: 8)
        let response = controller.createSymbolsTestResponse(withTest: test)
        return response;
    }
    
    public func createSurveyTest(surveyType:SurveyType) -> SurveyResponse
    {
        let surveyController = Arc.shared.surveyController
        let survey = surveyController.createSurveyResponse(type: surveyType)
        return survey
    }
    
    
    
	public func getSurveyFor(surveyType:SurveyType) -> JSONData?
	{
		let data = sessionData as! Set<JSONData>
		return data.first(where: { (obj) -> Bool in
			return obj.type == surveyType.rawValue
		})
	}


}
