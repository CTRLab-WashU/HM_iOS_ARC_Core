//
//  ProgressFlag.swift
//  Arc
//
//  Created by Philip Hayes on 8/6/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import Foundation

public enum ProgressFlag : String {
	//0.1.0
	case tutorial_complete
	case tutorial_grats
	case first_test_begin
	case baseline_completed
	case baseline_onboarding

    case paid_test_completed
    case grids_tutorial_shown
    case symbols_tutorial_shown
    case prices_tutorial_shown
	case tutorial_optional

	
	//For every version add a new case that runs for that version specifically.
	static public func prefilledFlagsFor(major:Int, minor:Int, patch:Int) -> Set<ProgressFlag> {
		var flags:Set<ProgressFlag> = []
		switch (major, minor, patch) {
		case let (major, _, _) where major < 2:
			flags = flags.union([.tutorial_grats, .tutorial_complete, .first_test_begin, .baseline_completed, tutorial_optional])
			fallthrough
		case let (major, _, _) where major == 2:
			flags = flags.union([.tutorial_grats, .tutorial_complete, .first_test_begin, .baseline_completed, .baseline_onboarding, .paid_test_completed])
			
		default:
			break
		}
		return flags
		
	}
}
