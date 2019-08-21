//
//  Earnings.swift
//  Arc
//
//  Created by Matt Gannon on 7/26/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import Foundation

public struct EarningOverview : Codable {
    
    public struct Response : Codable {
        public var success:Bool
        public var earnings:Earnings?
        
        public struct Earnings : Codable {
            public var total_earnings:String
            public var cycle:Int
			public var day:Int
            public var cycle_earnings:String
            
            public var goals:Dictionary<String, Goal>
			public var sessions:Dictionary<String, Session>
            public struct Goal : Codable {
                public var name:String
                public var value:String
                public var progress:Int
                public var amount_earned:String
                public var completed:Bool
				public var completed_on:TimeInterval?
                public var progress_components:Dictionary<String, Int>
            }
			
			public struct Session : Codable {
				public var name:String
				public var value:String
				public var progress:Int
				public var amount_earned:String
				public var completed:Int
				public var completed_on:TimeInterval?
			}
        }
    }
}


public struct EarningDetail : Codable {
    
    public struct Response : Codable {
        public var success:Bool
        public var earnings:Earnings

        public struct Earnings : Codable {
            public var total_earnings:String
            public var cycles:[Cycle]
            
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
}

public struct EarningRequestData:Codable {
    
    var cycle:Int?   //index of the cycle to retrieve
    var day:Int?     //index of the day of the cycle
    
    init(cycle:Int?, day:Int?) {
        self.cycle = cycle
        self.day = day
    }
    
}
