//
//  LanguageManager+Localization.swift
//  MyWeatherApp
//
//  Created by Lan on 27/07/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import Foundation

// MARK: - String Localization

// MARK: Enum

/**
Localization options.

- Original:    The original text.
- Capitalized: The text capitalized.
- Lowercase:   The lowercase text.
- Uppercase:   The uppercase text.
*/
enum LocalizationOption {
    case original
    case capitalized
    case lowercase
    case uppercase
    
    func formatString(_ string: String) -> String {
        var formattedString: String
        
        switch self {
        case .capitalized:
            formattedString = string.capitalized
        case .lowercase:
            formattedString = string.lowercased()
        case .uppercase:
            formattedString = string.uppercased()
        default:
            formattedString = string
        }
        
        return formattedString
    }
}

// MARK: Properties

/**
Cache the content of the localized string until the language changes.
*/
private var localizedStringCache: [String: String] = [:]

// MARK: Manage Localization

/**
Replace NSLocalizedString in the application.
 
- parameter key:    The key.
- parameter option: The option.
 
- returns: The localized string.
*/
func localizedString(_ key: String, option: LocalizationOption = .original) -> String {
    
    if let localizedString: String = localizedStringCache[key] {
        return option.formatString(localizedString)
    }
    
    var localizedString: String
    let languageIdentifier: LanguageManager.Language = LanguageManager.language
    
    if let languageFilePath: String = Bundle.main.path(forResource: languageIdentifier.resourceName, ofType: "lproj"),
        let languageBundle: Bundle = Bundle(path: languageFilePath) {
            localizedString = languageBundle.localizedString(forKey: key, value: "", table: nil)
    } else {
        localizedString = NSLocalizedString(key, comment: "")
    }
    
    localizedStringCache[key] = localizedString
    
    return option.formatString(localizedString)
}

/**
Resets the localization cache.
*/
func resetLocalizationCache() {
    localizedStringCache = [:]
}
