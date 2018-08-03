//
//  HTTPRequest.swift
//  MyWeatherApp
//
//  Created by Lan on 23/07/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import Foundation

protocol HTTPRequest {
    
    var method: HTTPService.Method                              { get }

    var endpoint: String?                                       { get }
    
    var inputFormat: HTTPService.HTTPRequestExchangeFormat      { get }
    var outputFormat: HTTPService.HTTPResponseExchangeFormat    { get }
    
    //var headers: [HTTPService.Header]                           { get }
    var additionnalHeaders: [String: String]                    { get }
    
    var parameters: RequestBodyType                             { get }
}

extension HTTPRequest {
    
    var parameters: RequestBodyType                             { return .array([]) }
    
    var additionnalHeaders: [String: String] {
        let header = HTTPManager.shared.commonAdditionalHeader
        return header
    }
    
    public static var finalEndpoint: String {
        return ""
    }
}

public enum RequestBodyType {
    case array([Any])
    case object([String: Any])
}
