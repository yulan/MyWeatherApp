//
//  LanguageManager.swift
//  MyWeatherApp
//
//  Created by Lan on 27/07/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import Foundation

// MARK: - Language Manager

/**
Manage the languages.
*/
class LanguageManager {
    
    // MARK: Languages Supported

    enum Language {
        case chineseSimplified
        case chineseTraditional
        case english
        case french
        
        /**
        Initialize a Language with a Apple Language code.
        If this code doesn't match directly, to try to match with a smaller part.
        If nothing matchs, .English is returned.
        */
        init(appleLanguageCode code: String) {
            if let fallbackCode = Language.fallbackCode(forAppleLanguageCode: code), let language = Language.fallbackDictionary[fallbackCode] {
                self = language
            } else {
                self = .english
            }
        }
        
        init(identifier: String) {
            switch identifier {
            case Language.chineseSimplified.identifier:
                self = .chineseSimplified
            case Language.chineseTraditional.identifier:
                self = .chineseTraditional
            case Language.english.identifier:
                self = .english
            case Language.french.identifier:
                self = .french
            default:
                self = .english
            }
        }
        
        /**
        Code used to write the NSUserDefaults with key `AppleLanguage`.
        */
        var appleCode: String {
            return self.appleCodeGreaterOrEqualToIOS9
        }
        
        /**
        Code used to write the NSUserDefaults with key `AppleLanguage`.
        Used on device less than iOS 9.
        */
        var appleCodeLessThanIOS9: String {
            switch self {
            case .chineseSimplified:
                return "zh-Hans"
            case .chineseTraditional:
                return "zh-Hant"
            case .english:
                return "en-GB"
            case .french:
                return "fr"
            }
        }
        
        /**
        Code used to write the NSUserDefaults with key `AppleLanguage`.
        Used on iOS 9 and higher.
        */
        var appleCodeGreaterOrEqualToIOS9: String {
            switch self {
            case .chineseSimplified:
                return "zh-Hans-FR"
            case .chineseTraditional:
                return "zh-HK"
            case .english:
                return "en-GB"
            case .french:
                return "fr-FR"
            }
        }
        
        
        
        
        /**
        The fallback dictionary.
        */
        static var fallbackDictionary: [String: Language] {
            return ["zh": .chineseSimplified,
                    "zh-HK": .chineseTraditional,
                    "zh-Hant": .chineseTraditional,
                    "zh-TW": .chineseTraditional,
                    "en": .english,
                    "fr": .french]
        }
        
        /**
        Trys to return a fallback code for Apple Language code. If it cannot, return `nil`.
        
        For example:
        - fr-FR => fr
        - fr-CA => fr
        - fr => fr
        */
        static func fallbackCode(forAppleLanguageCode code: String) -> String? {
            let dict: [String: Language] = Language.fallbackDictionary
            var languageIdentifier = code
            
            if dict[languageIdentifier] != nil {
                return languageIdentifier
            } else {
                var currentLanguageIdentifierSplitted: [String] = code.components(separatedBy: "-")
                currentLanguageIdentifierSplitted.removeLast()
                
                let currentLanguageIdentifierSplittedCount: Int = currentLanguageIdentifierSplitted.count
                
                for _ in (0 ..< currentLanguageIdentifierSplittedCount).reversed() {
                    languageIdentifier = currentLanguageIdentifierSplitted.joined(separator: "-")
                    
                    if dict[languageIdentifier] != nil {
                        return languageIdentifier
                    }
                    
                    currentLanguageIdentifierSplitted.removeLast()
                }
            }
            
            return nil
        }
        
        /**
        The language identifier.
        */
        var identifier: String {
            switch self {
            case .chineseSimplified:
                return "zh-Hans"
            case .chineseTraditional:
                return "zh-Hant"
            case .english:
                return "en"
            case .french:
                return "fr"
            }
        }
        
        /**
        The language's locale.
        */
        var locale: Locale {
            switch self {
            case .chineseSimplified:
                return Locale(identifier: "zh_CN")
            case .chineseTraditional:
                return Locale(identifier: "zh_HK")
            case .english:
                return Locale(identifier: "en_GB")
            case .french:
                return Locale(identifier: "fr_FR")
            }
        }
        
        /**
        The language name.
        */
        var name: String {
            switch self {
            case .chineseSimplified:
                return localizedString("language_chinese_simplified")
            case .chineseTraditional:
                return localizedString("language_chinese_traditional")
            case .english:
                return localizedString("language_english")
            case .french:
                return localizedString("language_french")
            }
        }
        
        /**
        The name of the file resource (*.strings).
        */
        var resourceName: String {
            switch self {
            case .chineseSimplified:
                return "zh-Hans"
            case .chineseTraditional:
                return "zh-Hant"
            case .english:
                return "en"
            case .french:
                return "fr"
            }
        }
        
        /**
         The language code returned to webservices.
         */
        public var LanguageCode: String {
            switch self {
            case .chineseSimplified:
                return "zh_cn"
            case .chineseTraditional:
                return "zh_tw"
            case .english:
                return "en"
            case .french:
                return "fr"
            }
        }
    }
    
    // MARK: Constants
    
    /**
    The class constants.
    */
    struct Constants {
        static let appLanguageDidChangedNotification: String    = "appLanguageDidChangedNotification"
        static let languagesUserDefaultKey: String              = "AppleLanguages"
    }
    
    // MARK: Get Instance
    
    /*
    Singleton
    */
    static let sharedInstance: LanguageManager = LanguageManager()
    
    // MARK: Manage Languages
    
    fileprivate var appleLanguageCode: String {
        get {
            return UserDefaults.standard.array(forKey: Constants.languagesUserDefaultKey)?.first as? String ?? "en-GB"
        }
        
        set {
            UserDefaults.standard.set([newValue], forKey: Constants.languagesUserDefaultKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    /**
    Returns a language from a apple language code (code used in `NSUserDefaults` with key "AppleLanguages").
     
    - parameter userDefaultId: The apple language code.
     
    - returns: The language. If no language is associated to the identifier, returns `.English`.
    */
    func language(fromAppleLanguageCode appleLanguageCode: String) -> Language {
        return Language(appleLanguageCode: appleLanguageCode)
    }
    
    /**
    The application language.
    */
    var language: Language {
        get {
            return self.language(fromAppleLanguageCode: self.appleLanguageCode)
        }
        
        set(newLanguage) {
            self.appleLanguageCode = newLanguage.appleCode
            resetLocalizationCache()
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.appLanguageDidChangedNotification), object: nil)
        }
    }
    
    /**
    Locks the application language.
    When the application's language has never been changed, a change of OS' language leads to a change of the app's language. This method avoid this behavior.
    */
    static func lockApplicationLanguage() {
        if let languages = UserDefaults.standard.array(forKey: Constants.languagesUserDefaultKey) as? [String], let currentLanguage = languages.first {
            UserDefaults.standard.set([currentLanguage], forKey: Constants.languagesUserDefaultKey)
            UserDefaults.standard.synchronize()
        }
    }
}

extension LanguageManager {
    
    // MARK: Shortcuts
    
    /**
     Shortcut to get the language.
     */
    class var language: Language {
        get {
            return self.sharedInstance.language
        }
        
        set {
            self.sharedInstance.language = newValue
        }
    }
    
    /**
     Returns a language from a apple language code (code used in `NSUserDefaults` with key "AppleLanguages").
     
     - parameter userDefaultId: The apple language code.
     
     - returns: The language. If no language is associated to the identifier, returns `.English`.
     */
    class func language(fromAppleLanguageCode appleLanguageCode: String) -> Language {
        return self.sharedInstance.language(fromAppleLanguageCode: appleLanguageCode)
    }
    
    /**
     Shortcut to get the language name.
     */
    class var languageName: String {
        return self.sharedInstance.language.name
    }
    
    /*
     Shortcut to get the locale.
     */
    class var locale: Locale {
        return self.sharedInstance.language.locale as Locale
    }
}

