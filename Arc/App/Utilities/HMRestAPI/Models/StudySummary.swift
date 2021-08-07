//
//  StudySummary.swift
//  Arc
//
//  Created by Philip Hayes on 3/17/20.
//  Copyright © 2020 HealthyMedium. All rights reserved.
//
/*
{
  "response": {
    "success": true,
    "summary": {
      "total_earnings": "$0.00",
      "tests_taken": 0,
      "days_tested": 0,
      "goals_met": 0
    }
  },
  "errors": {}
}

*/
import Foundation
public struct StudySummary : Codable {
	static var test = try! JSONDecoder().decode(StudySummary.self, from: """
	{
	  "response": {
		"success": true,
		"summary": {
		  "total_earnings": "$80.00",
		  "tests_taken": 212,
		  "days_tested": 60,
		  "goals_met": 9000
		}
	  },
	  "errors": {}
	}
	""".data(using: .utf8)!)
	
	public struct Response : Codable {
        public var success:Bool
        public var summary:Summary?
        
        public init(success: Bool, summary: Summary?) {
            self.success = success
            self.summary = summary
        }

        public struct Summary : Codable {
            public var total_earnings:String
            public var tests_taken:Int
            public var days_tested:Int
            public var goals_met:Int
            
            public init(total_earnings: String, tests_taken: Int,
                        days_tested: Int, goals_met: Int) {
                self.total_earnings = total_earnings
                self.tests_taken = tests_taken
                self.days_tested = days_tested
                self.goals_met = goals_met
            }
        }
    }
	
	public var response:Response
    
    public init(response: Response) {
        self.response = response
    }
}
