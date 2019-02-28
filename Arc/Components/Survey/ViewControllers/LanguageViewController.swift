//
//  LanguageViewController.swift
//  Arc
//
//  Created by Philip Hayes on 2/20/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import Foundation

public enum ACLanguage {
    case english
    case spanish
    case french
    case italian
    case japanese
    case german
    case simplifiedChinese
    case dutch
}

open class ACLanguageViewController : SurveyNavigationViewController {
    open override func onValueSelected(value: QuestionResponse, index: String) {
        
    }
}
