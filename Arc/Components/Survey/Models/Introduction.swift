//
//  Introduction.swift
// Arc
//
//  Created by Philip Hayes on 10/23/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import Foundation
public struct Introduction : Codable {

	public struct Instruction : Codable {
		var title : String
		var subtitle : String
		var preface : String
		var nextButtonTitle:String?
        var nextButtonImage:String?
		var style:String?
	}
	var instructions:Array<Instruction>?
	
}
