//
//  Date+Formatter.swift
//  MyWeatherApp
//
//  Created by Lan on 27/07/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import Foundation

extension Date {
    func toWeekdayDayMonthAndYear() -> String {
        let locale = LanguageManager.locale
        let dateFormatterTemplate = DateFormatter.dateFormat(fromTemplate: "EEEEddMMyy", options: 0, locale: locale)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormatterTemplate
        dateFormatter.locale = locale
        dateFormatter.timeZone = TimeZone(abbreviation: "CET")
        
        return dateFormatter.string(from: self)
    }
    
    func toDayMonthAndYear() -> String {
        let locale = LanguageManager.locale
        let dateFormatterTemplate = DateFormatter.dateFormat(fromTemplate: "ddMMyyyy", options: 0, locale: locale)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormatterTemplate
        dateFormatter.locale = locale
        dateFormatter.timeZone = TimeZone(abbreviation: "CET")
        
        return dateFormatter.string(from: self)
    }
    
    func toHoursAndMinutes() -> String {
        let locale = LanguageManager.locale
        let dateFormatterTemplate = DateFormatter.dateFormat(fromTemplate: "jjmm", options: 0, locale: locale)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormatterTemplate
        dateFormatter.locale = locale
        dateFormatter.timeZone = TimeZone(abbreviation: "CET")
        
        return dateFormatter.string(from: self)
    }
}
