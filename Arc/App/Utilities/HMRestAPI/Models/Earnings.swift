//
//  Earnings.swift
//  Arc
//
//  Created by Matt Gannon on 7/26/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import Foundation

public struct EarningOverview : Codable {
    
    public init(response: Response?, errors: [String:[String]]) {
        self.response = response
        self.errors = errors
    }
    
    public struct Response : Codable {
        public var success:Bool
        public var earnings:Earnings?
        
        public init(success: Bool, earnings:Earnings?) {
            self.success = success
            self.earnings = earnings
        }
        
        public struct Earnings : Codable {
            
            public var total_earnings:String
            public var cycle:Int
            public var day:Int
            public var cycle_earnings:String
            public var goals:Array<Goal>
            public var new_achievements:Array<Achievement>
            
            public init(total_earnings:String, cycle:Int, day:Int, cycle_earnings:String,
                        goals:Array<Goal>, new_achievements:Array<Achievement>) {
                self.total_earnings = total_earnings
                self.cycle = cycle
                self.day = day
                self.cycle_earnings = cycle_earnings
                self.goals = goals
                self.new_achievements = new_achievements
            }
            
            public struct Goal : Codable {
                
                public init (name: String, value: String, progress: Int,
                             amount_earned: String, completed: Bool,
                             completed_on: TimeInterval?, progress_components:Array<Int>) {
                    
                    self.name = name
                    self.value = value
                    self.progress = progress
                    self.amount_earned = amount_earned
                    self.completed = completed
                    self.completed_on = completed_on
                    self.progress_components = progress_components
                }
                
                public var name:String
                public var value:String
                public var progress:Int
                public var amount_earned:String
                public var completed:Bool
				public var completed_on:TimeInterval?
                public var progress_components:Array<Int>
            }
			
			public struct Achievement : Codable {
                
                public init(name: String, amount_earned: String) {
                    self.name = name
                    self.amount_earned = amount_earned
                }
                
				public var name:String
				public var amount_earned:String
			}
        }
    }
	
	public var response:Response?
	public var errors:[String:[String]]
}


public struct EarningDetail : Codable {
    
    public struct Response : Codable {
        public var success:Bool
        public var earnings:Earnings?

        public struct Earnings : Codable {
            public var total_earnings:String
            public var cycles:[Cycle]?
            
            public struct Cycle : Codable {
                public var cycle:Int
                public var total:String
                public var start_date:TimeInterval
                public var end_date:TimeInterval
                public var details:[Detail]
                
                public struct Detail : Codable {
                    public var name:String
                    public var value:String
                    public var count_completed:Int
                    public var amount_earned:String
                }
            }
        }
    }
	var response:Response?
	var errors:[String:[String]]
}

public struct EarningRequestData:Codable {
    
    var cycle:Int?   //index of the cycle to retrieve
    var day:Int?     //index of the day of the cycle
    
    init(cycle:Int?, day:Int?) {
        self.cycle = cycle
        self.day = day
    }
    
}
