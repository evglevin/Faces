//
//  Enum+String+Language.swift
//  Faces
//
//  Created by Евгений Левин on 22.05.2018.
//  Copyright © 2018 levin inc. All rights reserved.
//

import Foundation
import UIKit

private let appleLanguagesKey = "AppleLanguages"

enum Language: String {
    case english = "en"
    case russian = "ru"
    
    
    static var language: Language {
        get {
            if let languageCode = UserDefaults.standard.string(forKey: appleLanguagesKey),
                let language = Language(rawValue: languageCode) {
                return language
            } else {
                let preferredLanguage = NSLocale.preferredLanguages[0] as String
                let index = preferredLanguage.index(
                    preferredLanguage.startIndex,
                    offsetBy: 2
                )
                guard let localization = Language(
                    rawValue: preferredLanguage.substring(to: index)
                    ) else {
                        return Language.english
                }
                
                return localization
            }
        }
        set {
            guard language != newValue else {
                return
            }
            
            //change language in the app
            //the language will be changed after restart
            UserDefaults.standard.set([newValue.rawValue], forKey: appleLanguagesKey)
            UserDefaults.standard.synchronize()
        }
    }
}
