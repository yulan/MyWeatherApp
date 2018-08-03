//
//  HTTPService+Constants.swift
//  MyWeatherApp
//
//  Created by Lan on 23/07/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import Foundation

extension HTTPService {
    
    // MARK: Typedef
    
    typealias HTTPSuccessClosure = (Data?, HTTPURLResponse) -> Void
    typealias HTTPErrorClosure = (Error?, Data?, HTTPResponseFailureReason) -> Void
    
    // MARK: Enumerations
    
    /// The HTTP methods.
    ///
    /// - delete: For a DELETE request.
    /// - get: For a GET request.
    /// - post: For a POST request.
    /// - put: For a PUT request.
    enum Method: String {
        case delete = "DELETE"
        case get    = "GET"
        case post   = "POST"
        case put    = "PUT"
    }

    /// Some well known values which can be added in the request headers.
    ///
    /// - contentTypeJSON: contentTypeJSON description
    enum Header {
        case acceptEncoding
        case contentTypeURLEncoded
        case contentTypeJSON
        
        var tuple: (key: String, value: String) {
            switch self {
            case .acceptEncoding:           return (key: "Accept-Encoding", value: "gzip, deflate")
            case .contentTypeURLEncoded:    return (key: "Content-Type", value: "application/x-www-form-urlencoded; charset=utf-8")
            case .contentTypeJSON:          return (key: "Content-Type", value: "application/json")
            }
        }

            var usualJSON: [Header] {
            return [.acceptEncoding, .contentTypeJSON]
        }
    }
    
    
    /// The API key. to complet!!!!!!!! TODO
    /// These URLs change in function of the environment (INTE, VAL, PROD).
    ///
    /// - proxy: The Proxy base URL.
    public var APPID: String {
        return "f2c1fb0af873d7996d8653b45afb8e5e"
    }
    
    /// The base URLs used by the services. !!!!!!!! TODO
    /// These URLs change in function of the environment (INTE, VAL, PROD).
    ///
    /// - proxy: The Proxy base URL.
    public var BaseURL: URL? {
        return URL(string:"https://api.openweathermap.org/data/2.5")
    }

    /// The type of exchange format expected in the request.
    ///
    /// - data: A JSON.
    /// - json: A urlEncoded.
    enum HTTPRequestExchangeFormat {
        case json
        case urlEncoded
        case formUrlencoded
    }
    
    /// The type of exchange format expected in the response.
    ///
    /// - data: A NSData.
    /// - empty: No response.
    /// - json: A JSON.
    enum HTTPResponseExchangeFormat {
        case data
        case empty
        case json
    }
    
    /// The reason the HTTP call failed.
    ///
    /// - httpCode: Failed due to a HTTP code.
    /// - parseError: Failed due to a parsing error.
    /// - timeout: Failed due to timeout.
    /// - unknown: Failed due to an unknown reason.
    public enum HTTPResponseFailureReason: Error {
        case httpCode(Int)
        case httpCodeJSON(Int, Any)
        case parseError
        case timeout
        case unauthorized
        case unknown
        case pingFailure
        case refreshTokenFailure
        
        public var error: NSError {
            switch self {
            case .httpCode(let statusCode):                 return NSError(domain: "HTTP Error", code: statusCode, userInfo: nil)
            case .httpCodeJSON(let statusCode, _):          return NSError(domain: "HTTP Error", code: statusCode, userInfo: nil)
            case .parseError:                               return NSError(domain: "Parse Error", code: 900, userInfo: nil)
            case .timeout:                                  return NSError(domain: "Timeout Error", code: 901, userInfo: nil)
            case .unauthorized:                             return NSError(domain: "Unauthorized area", code: 401, userInfo: nil)
            case .unknown:                                  return NSError(domain: "Unknow Error", code: 902, userInfo: nil)
            case .pingFailure:                              return NSError(domain: "Ping Failure", code: 903, userInfo: nil)
            case .refreshTokenFailure:                      return NSError(domain: "Refresh token failure", code: 400, userInfo: nil)
            }
        }
    }
    
    // MARK: HTTP Codes
    
    
    /// The different type of standard HTTP status code.
    ///
    /// - informationalCodes: Informational codes.
    /// - successCodes: Success codes.
    /// - redirectionCodes: Redirection codes.
    /// - clientErrorCodes: Client error codes.
    /// - serverErrorCodes: Server error codes.
    enum HTTPCode {
        case informationalCodes
        case successCodes
        case redirectionCodes
        case clientErrorCodes
        case serverErrorCodes
        
        init?(code: Int?) {
            guard let code = code else { return nil }
            
            switch code {
            case HTTPCode.informationalCodes.range: self = HTTPCode.informationalCodes
            case HTTPCode.successCodes.range:       self = HTTPCode.successCodes
            case HTTPCode.redirectionCodes.range:   self = HTTPCode.redirectionCodes
            case HTTPCode.clientErrorCodes.range:   self = HTTPCode.clientErrorCodes
            case HTTPCode.serverErrorCodes.range:   self = HTTPCode.serverErrorCodes
            default:                                return nil
            }
        }
        
        var range: CountableRange<Int> {
            switch self {
            case .informationalCodes:    return 100 ..< 199
            case .successCodes:          return 200 ..< 299
            case .redirectionCodes:      return 300 ..< 399
            case .clientErrorCodes:      return 400 ..< 499
            case .serverErrorCodes:      return 500 ..< 599
            }
        }
    }
    
    enum HTTPHeader : String {
        case Authorization  = "Authorization"
        case UserAgent      = "User-Agent"
    }
}
