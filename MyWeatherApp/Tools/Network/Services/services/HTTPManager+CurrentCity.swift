//
//  HTTPManager+CurrentCity.swift
//  MyWeatherApp
//
//  Created by Lan on 23/07/2018.
//  Copyright © 2018 Lan YU. All rights reserved
//

import Foundation

public struct Fetch5daysOrCurrentCityWeatherStruct {
    public let cityName: String?
    //By city id
    public let cityId: String?
    //By geographic coordinates
    public let lat: String?
    public let lon: String?
    // By ZIP code
    public let zipCode: String?
    public let countryCode: String?
    
    //Units format
    public let units: String?
    public let isCall5SaysResquest: Bool
    
    public init(cityName: String? = nil, countryCode:String? = nil, cityId: String? = nil, lat: String? = nil, lon: String? = nil, zipCode: String? = nil, units: String? = nil, isCall5SaysResquest: Bool = true) {
        self.cityName = cityName
        self.cityId = cityId
        self.lat = lat
        self.lon = lon
        self.zipCode = zipCode
        self.countryCode = countryCode
        self.units = units
        self.isCall5SaysResquest = isCall5SaysResquest
    }
}


extension HTTPManager {

//    public class func fetchFlightsFromBoardingPass(_ barCodeData: String, success: @escaping ((Any) -> Void), failure: @escaping (HTTPService.HTTPResponseFailureReason) -> Void) {
//
//        let requestClosure: () -> HTTPRequest = { () -> HTTPRequest in
//            return FlightsFromBoardingPassRequest(barCodeData: barCodeData)
//        }
//
//        let responseClosure: (Response) -> Void = { response in
//
//            switch response {
//            case .json(let json): success(json)
//            case .error(let reason) : failure(reason)
//            default: failure(.unknown)
//            }
//        }
//        HTTPManager.shared.execute(requestClosure: requestClosure, andReponseClosure: responseClosure)
//    }
    
    public class func fetchCurrentCityWeather (_ fetch5daysOrCurrentCityWeatherStruct: Fetch5daysOrCurrentCityWeatherStruct, success: @escaping ((Any) -> Void), failure: @escaping (HTTPService.HTTPResponseFailureReason) -> Void) {
        
        let requestClosure: () -> HTTPRequest = { () -> HTTPRequest in
            return Call5DaysAndCurrentCityRequest(fetch5daysOrCurrentCityWeatherStruct)
            //Call5DaysAndCurrentCityRequest(cityName: FetchCurrentCityWeatherStruct.cityName, units: FetchCurrentCityWeatherStruct.unites, isCall5SaysResquest: false)
        }
        
        let responseClosure: (Response) -> Void = { response in
            
            switch response {
            case .json(let json): success(json)
            case .error(let reason) : failure(reason)
            default: failure(.unknown)
            }
        }
        HTTPManager.shared.execute(requestClosure: requestClosure, andReponseClosure: responseClosure)
    }
    
//    public class func fetchFlightDetail(_ compositeKey: String, success: @escaping ((Any) -> Void), failure: @escaping (HTTPService.HTTPResponseFailureReason) -> Void) {
//
//        let requestClosure: () -> HTTPRequest = { () -> HTTPRequest in
//            return FlightDetailRequest(compositeKey: compositeKey)
//        }
//
//        let responseClosure: (Response) -> Void = { response in
//
//            switch response {
//            case .json(let json): success(json)
//            case .error(let reason) : failure(reason)
//            default: failure(.unknown)
//            }
//        }
//        HTTPManager.shared.execute(requestClosure: requestClosure, andReponseClosure: responseClosure)
//    }
//
//    public class func fetchFlightSolaris(_ fetchFlightSolarisStruct: FetchFlightSolarisStruct, success: @escaping ((Any) -> Void), failure: @escaping (HTTPService.HTTPResponseFailureReason) -> Void) {
//
//        let requestClosure: () -> HTTPRequest = { () -> HTTPRequest in
//            return FetchFlightSolarisRequest(fetchFlightSolarisStruct: fetchFlightSolarisStruct)
//        }
//
//        let responseClosure: (Response) -> Void = { response in
//
//            switch response {
//            case .json(let json): success(json)
//            case .error(let reason) : failure(reason)
//            default: failure(.unknown)
//            }
//        }
//        HTTPManager.shared.execute(requestClosure: requestClosure, andReponseClosure: responseClosure)
//    }
//
//    public class func fetchDestinations(_ success: @escaping ((Any) -> Void), failure: @escaping (HTTPService.HTTPResponseFailureReason) -> Void) {
//
//        let requestClosure: () -> HTTPRequest = { () -> HTTPRequest in
//            return FlightDestinationsRequest()
//        }
//
//        let responseClosure: (Response) -> Void = { response in
//
//            switch response {
//            case .json(let json): success(json)
//            case .error(let reason) : failure(reason)
//            default: failure(.unknown)
//            }
//        }
//        HTTPManager.shared.execute(requestClosure: requestClosure, andReponseClosure: responseClosure)
//    }
//
//    public class func fetchAirlines(_ fetchAirlinesStruct: FetchAirlinesStruct, success: @escaping ((Any) -> Void), failure: @escaping (HTTPService.HTTPResponseFailureReason) -> Void) {
//
//        let requestClosure: () -> HTTPRequest = { () -> HTTPRequest in
//            return SearchAirlineRequest(fetchAirlinesStruct: fetchAirlinesStruct)
//        }
//
//        let responseClosure: (Response) -> Void = { response in
//
//            switch response {
//            case .json(let json): success(json)
//            case .error(let reason) : failure(reason)
//            default: failure(.unknown)
//            }
//        }
//        HTTPManager.shared.execute(requestClosure: requestClosure, andReponseClosure: responseClosure)
//    }
//
//    public class func fetchAirlineDetail(_ companyCode: String, success: @escaping ((Any) -> Void), failure: @escaping (HTTPService.HTTPResponseFailureReason) -> Void) {
//
//        let requestClosure: () -> HTTPRequest = { () -> HTTPRequest in
//            return SearchAirlineDetailRequest(companyCode: companyCode)
//        }
//
//        let responseClosure: (Response) -> Void = { response in
//
//            switch response {
//            case .json(let json): success(json)
//            case .error(let reason) : failure(reason)
//            default: failure(.unknown)
//            }
//        }
//        HTTPManager.shared.execute(requestClosure: requestClosure, andReponseClosure: responseClosure)
//    }
}
