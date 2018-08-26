//
//  Call5DaysAndCurrentCityRequest.swift
//  MyWeatherApp
//
//  Created by Lan on 02/08/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import Foundation
import CoreLocation

struct Call5DaysAndCurrentCityRequest: HTTPRequest {
    
    // MARK: properties
     //By city name
    fileprivate let cityName: String?
    //By city id
    fileprivate let cityId: String?
    //By geographic coordinates
    fileprivate let lat: String?
    fileprivate let lon: String?
    // By ZIP code
    fileprivate let zipCode: String?
    fileprivate let countryCode: String?
    
    //Units format
    fileprivate let units: String?
    fileprivate let isCall5SaysResquest: Bool
    
    // MARK: init
    
    init(_ fetch5daysOrCurrentCityWeatherStruct: Fetch5daysOrCurrentCityWeatherStruct) {
        self.cityName = fetch5daysOrCurrentCityWeatherStruct.cityName
        self.cityId = fetch5daysOrCurrentCityWeatherStruct.cityId
        self.lat = fetch5daysOrCurrentCityWeatherStruct.lat
        self.lon = fetch5daysOrCurrentCityWeatherStruct.lon
        self.zipCode = fetch5daysOrCurrentCityWeatherStruct.zipCode
        self.countryCode = fetch5daysOrCurrentCityWeatherStruct.countryCode
        self.units = fetch5daysOrCurrentCityWeatherStruct.units
        self.isCall5SaysResquest = fetch5daysOrCurrentCityWeatherStruct.isCall5SaysResquest
        self.parameters = self.getParameters()
    }
    
    // MARK: HTTPRequest values
    
    var method: HTTPService.Method                              { return .get }
    var endpoint: String?                                       { return self.isCall5SaysResquest ? "forecast" : "weather"}
    var inputFormat: HTTPService.HTTPRequestExchangeFormat      { return .urlEncoded }
    var outputFormat: HTTPService.HTTPResponseExchangeFormat    { return .json }
    var parameters: RequestBodyType = RequestBodyType.object([:])
    
    func getParameters() -> RequestBodyType {
        var parameters: [String: Any] = [:]
        if let cityName = self.cityName {
            if let countryCode = self.countryCode {
                parameters["q"] = "\(cityName),\(countryCode)"
            } else {
                parameters["q"] = cityName
            }
        } else if let cityId = self.cityId {
            parameters["id"] = cityId
        } else if let lat = self.lat, let lon = self.lon {
            parameters["lat"] = lat
            parameters["lon"] = lon
        } else if let zipCode = self.zipCode {
            if let countryCode = self.countryCode {
                parameters["zip"] = "\(zipCode),\(countryCode)"
            } else {
                parameters["zip"] = zipCode
            }
        } else {
            return .object(parameters)
        }
        
        parameters["appid"] = HTTPService.shared.APPID
        guard  let units = self.units else {
            return .object(parameters)
        }
        
        parameters["units"] = units
        return .object(parameters)
    }
}
