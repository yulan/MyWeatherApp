//
//  HTTPRequestHelper.swift
//  MyWeatherApp
//
//  Created by Lan on 23/07/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import Foundation

extension URL {
    func URLByAppendingPathComponentHelper(_ endpoint: String?) -> URL? {
        if let endpoint = endpoint {
            return self.appendingPathComponent(endpoint)
        } else {
            return self
        }
    }
}

struct HTTPRequestHelper {
    
    static func url(forRequest httpRequest: HTTPRequest) -> URL? {
        guard  var url: URL = HTTPService.shared.BaseURL?.URLByAppendingPathComponentHelper(httpRequest.endpoint) else {
            return nil
        }
        
        switch httpRequest.method {
        case .get, .delete, .post, .put:
            switch httpRequest.inputFormat {
            case .urlEncoded:
                switch httpRequest.parameters {
                case .object(let parameters):
                    if let queryString = parameters.query {
                        var urlString = url.absoluteString
                        urlString = "\(urlString)?\(queryString)"
                        if let urlNew = URL(string: urlString) {
                            url = urlNew
                        }
                    }
                case .array: return url
                }
            case .json:
                switch httpRequest.parameters {
                case .object: return url
                case .array(let parameters):
                    if let queryString = parameters.query {
                        url = url.appendingPathComponent(queryString)
                    }
                }
            case .formUrlencoded:
                return url
            }
        }
        
        return url
    }
    
//    static func headers(forRequest httpRequest: HTTPRequest) -> [String: String] {
//        var selectedHeader: [HTTPService.Header] = httpRequest.headers
//        var headers: [String: String] = [:]
//        switch httpRequest.inputFormat {
//        case .json: selectedHeader.append(.contentTypeJSON)
//        case .urlEncoded, .formUrlencoded: selectedHeader.append(.contentTypeURLEncoded)
//        }
//        selectedHeader.forEach { headers[$0.tuple.key] = $0.tuple.value }
//        httpRequest.additionnalHeaders.forEach { headers[$0.0] = $0.1 }
//        return headers
//    }
    
    static func body(forRequest httpRequest: HTTPRequest) -> Data? {
        
        guard httpRequest.method == .post || httpRequest.method == .put || httpRequest.method == .delete else { return nil }
        
        switch httpRequest.inputFormat {
        case .json:
            do {
                var parameters: Any
                switch httpRequest.parameters {
                case .array(let value): parameters = value
                case .object(let value): parameters = value
                }
                return try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            } catch {
                return nil
            }
            
        case .formUrlencoded:
            var parameters: [String: Any]
            switch httpRequest.parameters {
            case .object(let value): parameters = value
            default: return nil
            }
            return parameters.query?.data(using: String.Encoding.utf8)
            
        case .urlEncoded:
            return nil
        }
    }
    
    static func getRequest(forRequest httpRequest: HTTPRequest) -> URLRequest? {
        
        guard let url = HTTPRequestHelper.url(forRequest: httpRequest) else {
            return nil
        }
        var urlRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: HTTPService.timeoutInterval)
        urlRequest.httpMethod = httpRequest.method.rawValue
        //urlRequest.allHTTPHeaderFields = HTTPRequestHelper.headers(forRequest: httpRequest)
        urlRequest.httpBody = HTTPRequestHelper.body(forRequest: httpRequest)
        return urlRequest
    }
    
    static func signRequest(forRequest urlRequest: URLRequest) -> URLRequest? {
        guard let mutableRequest: NSMutableURLRequest = (urlRequest as NSURLRequest).mutableCopy() as? NSMutableURLRequest else { return nil }
        return mutableRequest as URLRequest
    }
    
//    static func multiParameterString<T: Stringable>(parameters: [T]) -> String {
//        return (parameters.map({ $0.toString() }) as NSArray).componentsJoined(by: "|")
//    }
}
