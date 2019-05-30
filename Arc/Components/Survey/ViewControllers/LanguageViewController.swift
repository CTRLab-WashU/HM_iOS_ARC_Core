//
//  LanguageViewController.swift
//  Arc
//
//  Created by Philip Hayes on 2/20/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import Foundation
public enum ACLocale : String{
/*
     US - English    Nederland - Nederlands    France - Français    España - Español    Argentina - Español    Canada - Français    Deutschland - Deutsche    Italia - Italiano    日本 - 日本語    Brasil - Português    Columbia - Español    Mexico - Español    US - Español    中国 - 简体中文
     
     language_key    en    nl    fr    es    es    fr    de    it    ja    pt    es    es    es    zh
      country_key    US    NL    FR    ES    AR    CA    DE    IT    JP    BR    COL    MX    US    CN
*/
    case en_US
    case en_AU
    case en_UK
    case en_CA
    case nl_NL
    case fr_FR
    case es_ES
    case es_AR
    case fr_CA
    case de_DE
    case it_IT
    case ja_JP
    case pt_BR
    case es_COL
    case es_MX
    case es_US
    case zh_CN
    
    static func from(description:String) -> ACLocale {
        switch description {
            
        case "US - English": return .en_US
        case "Australia - English": return .en_AU
        case "UK - English": return .en_UK
        case "Canada - English": return .en_CA
        case "Nederland - Nederlands": return .nl_NL
        case "France - Français": return .fr_FR
        case "España - Español": return .es_ES
        case "Argentina - Español": return .es_AR
        case "Canada - Français": return .fr_CA
        case "Deutschland - Deutsche": return .de_DE
        case "Italia - Italiano": return .it_IT
        case "日本 - 日本語": return .ja_JP
        case "Brasil - Português": return .pt_BR
        case  "Columbia - Español": return .es_COL
        case "Mexico - Español": return .es_MX
        case "US - Español": return .es_US
        case "中国 - 简体中文": return .zh_CN
        default: return .en_US
            
        }
        
    }
    var string: String {
        return self.rawValue
    }
    var locale:(language:String, region:String) {
        let values = string.components(separatedBy: "_")
        return (values[0], values[1])
    }
    var availablePriceTest:String {
        switch self {
            
        case .en_AU: return "priceSets-en-AU"
        case .en_CA: return "priceSets-en-CA"
        case .en_UK: return "priceSets-en-UK"
        case .en_US: return "priceSets-en-US"
        case .es_ES: return "priceSets-es-ES"
        case .es_US, .es_MX: return "priceSets-es-US"
        case .fr_CA: return "priceSets-fr-CA"
        case .fr_FR: return "priceSets-fr-FR"
        default:
            return "priceSets-en-US"
            
        }
    }
}

open class ACLanguageViewController : SurveyNavigationViewController {
    open override func onValueSelected(value: QuestionResponse, index: String) {
        if index == "ac_language_1" {
            guard let value = value.text_value else {
                return
            }
            let locale = ACLocale.from(description: value)
            let components = locale.string.components(separatedBy: "_")
            let language = components[0]
            let country = components[1]
            Arc.shared.appController.language = language
            Arc.shared.appController.country = country

            Arc.shared.setLocalization(country:country,
                                       language: language)
            Arc.shared.WELCOME_TEXT = Arc.environment?.welcomeText ?? ""

        }
    }
}
