//
//  HTTPService.swift
//  MyWeatherApp
//
//  Created by Lan on 23/07/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import Foundation

public final class HTTPService {
    
    // MARK: Shared
    
    static let shared: HTTPService = HTTPService()
    
    // MARK: Configuration
    
    static let timeoutInterval: TimeInterval = 60
    
    fileprivate lazy var session: URLSession = {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        return session
    }()
    
    // MARK: Execute Core
    
    fileprivate class func taskCompletion(_ data: Data?, urlResponse: URLResponse?,
                                          error: Error?, successClosure: HTTPSuccessClosure?,
                                          failureClosure: HTTPErrorClosure?) -> Void {
        if error != nil || (urlResponse as? HTTPURLResponse != nil && !(HTTPCode.successCodes.range ~= (urlResponse as! HTTPURLResponse).statusCode)) {
            if let statusCode = (urlResponse as? HTTPURLResponse)?.statusCode {
                if let data = data, let json: Any = try? JSONSerialization.jsonObject(with: data, options: []) {
                    failureClosure?(error, data, HTTPResponseFailureReason.httpCodeJSON(statusCode, json))
                } else {
                    failureClosure?(error, data, HTTPResponseFailureReason.httpCode(statusCode))
                }
            }
        } else {
            successClosure?(data, (urlResponse as! HTTPURLResponse))
        }
    }
    
    fileprivate class func signRequest(_ httpRequest: HTTPRequest, successClosure: @escaping (URLRequest) -> Void, andFailureClosure failureClosure: HTTPErrorClosure?) {
        
        guard let urlRequest: URLRequest = HTTPRequestHelper.getRequest(forRequest: httpRequest) as URLRequest? else {
            failureClosure?(nil, nil, HTTPResponseFailureReason.parseError)
            return
        }
        
        guard let request = HTTPRequestHelper.signRequest(forRequest: urlRequest) else {
            failureClosure?(nil, nil, HTTPResponseFailureReason.parseError)
            return
        }
        
        successClosure(request)
        
    }
    
    fileprivate class func execute(_ httpRequest: HTTPRequest,
                                   withSuccessClosure successClosure: HTTPSuccessClosure?,
                                   andFailureClosure failureClosure: HTTPErrorClosure?) {
        
        HTTPService.sendEventBefore(request: httpRequest)
        let date = Date()
        
        let execute: (URLRequest) -> Void = { request in
            let task = self.shared.session.dataTask(with: request, completionHandler: { data, urlResponse, error in
                
                let executionDuration = Date().timeIntervalSince(date)
                HTTPService.sendEventAfter(request: request, withResponse: urlResponse, withData: data, andDuration: executionDuration)
                
                self.taskCompletion(data, urlResponse: urlResponse, error: error, successClosure: successClosure, failureClosure: failureClosure)
            })
            task.resume()
        }
        
        self.signRequest(httpRequest, successClosure: execute, andFailureClosure: failureClosure)
    }
    
    // MARK: Execute Requests
    
    class func excecuteEmpty(_ httpRequest: HTTPRequest,
                             withSuccessClosure successClosure: ((HTTPURLResponse) -> Void)?,
                             andFailureClosure failureClosure: ((HTTPResponseFailureReason) -> Void)?) {
        
        let success: HTTPSuccessClosure = { data, HTTPResponse in
            successClosure?(HTTPResponse)
        }
        
        let failure: HTTPErrorClosure = { error, data, HttpCode in
            failureClosure?(HttpCode)
        }
        
        self.execute(httpRequest, withSuccessClosure: success, andFailureClosure: failure)
    }
    
    class func executeJSON(_ httpRequest: HTTPRequest,
                           withSuccessClosure successClosure: ((Any) -> Void)?,
                           andFailureClosure failureClosure: ((HTTPResponseFailureReason) -> Void)?) {
        let success: HTTPSuccessClosure = { data, statusCode in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                successClosure?(json)
            } else {
                failureClosure?(HTTPResponseFailureReason.parseError)
            }
        }
        
        let failure: HTTPErrorClosure = { error, data, HttpCode in
            failureClosure?(HttpCode)
        }
        
        self.execute(httpRequest, withSuccessClosure: success, andFailureClosure: failure)
    }
    
    class func executeData(_ httpRequest: HTTPRequest,
                           withSuccessClosure successClosure: ((Data) -> Void)?,
                           andFailureClosure failureClosure: ((HTTPResponseFailureReason) -> Void)?) {
        let success: HTTPSuccessClosure = { data, statusCode in
            if let data = data {
                successClosure?(data)
            } else {
                failureClosure?(HTTPResponseFailureReason.parseError)
            }
        }
        
        let failure: HTTPErrorClosure = { error, data, HttpCode in
            failureClosure?(HttpCode)
        }
        
        self.execute(httpRequest, withSuccessClosure: success, andFailureClosure: failure)
    }
    
    // MARK: Execute Upload Core
    
    fileprivate class func executeUpload(_ httpRequest: HTTPRequest, fromData data: Data,
                                         withSuccessClosure successClosure: HTTPSuccessClosure?,
                                         andFailureClosure failureClosure: HTTPErrorClosure?) {
        
        HTTPService.sendEventBefore(request: httpRequest)
        let date = Date()
        
        let execute: (URLRequest) -> Void = { request in
            let task = self.shared.session.uploadTask(with: request, from: data, completionHandler: { data, urlResponse, error in
                
                let executionDuration = Date().timeIntervalSince(date)
                HTTPService.sendEventAfter(request: request, withResponse: urlResponse, withData: data, andDuration: executionDuration)
                
                self.taskCompletion(data, urlResponse: urlResponse, error: error as NSError?, successClosure: successClosure, failureClosure: failureClosure)
            })
            task.resume()
        }
        
        self.signRequest(httpRequest, successClosure: execute, andFailureClosure: failureClosure)
    }
    
    // MARK: Execute Upload Requests
    
    class func excecuteUploadEmpty(_ httpRequest: HTTPRequest, fromData data: Data,
                                   withSuccessClosure successClosure: ((HTTPURLResponse) -> Void)?,
                                   andFailureClosure failureClosure: ((HTTPResponseFailureReason) -> Void)?) {
        
        let success: HTTPSuccessClosure = { data, statusCode in
            successClosure?(statusCode)
        }
        
        let failure: HTTPErrorClosure = { error, data, HttpCode in
            failureClosure?(HttpCode)
        }
        
        self.executeUpload(httpRequest, fromData: data, withSuccessClosure: success, andFailureClosure: failure)
    }
    
    class func executeUploadJSON(_ httpRequest: HTTPRequest, fromData data: Data,
                                 withSuccessClosure successClosure: ((Any) -> Void)?,
                                 andFailureClosure failureClosure: ((HTTPResponseFailureReason) -> Void)?) {
        let success: HTTPSuccessClosure = { data, statusCode in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                successClosure?(json)
            } else {
                failureClosure?(HTTPResponseFailureReason.parseError)
            }
        }
        
        let failure: HTTPErrorClosure = { error, data, HttpCode in
            failureClosure?(HttpCode)
        }
        
        self.executeUpload(httpRequest, fromData: data, withSuccessClosure: success, andFailureClosure: failure)
    }
    
    class func executeUploadData(_ httpRequest: HTTPRequest, fromData data: Data,
                                 withSuccessClosure successClosure: ((Data) -> Void)?,
                                 andFailureClosure failureClosure: ((HTTPResponseFailureReason) -> Void)?) {
        let success: HTTPSuccessClosure = { data, statusCode in
            if let data = data {
                successClosure?(data)
            } else {
                failureClosure?(HTTPResponseFailureReason.parseError)
            }
        }
        
        let failure: HTTPErrorClosure = { error, data, HttpCode in
            failureClosure?(HttpCode)
        }
        
        self.executeUpload(httpRequest, fromData: data, withSuccessClosure: success, andFailureClosure: failure)
    }
    
    // MARK: Execute Download Requests
    
    class func executeDownload(_ httpRequest: HTTPRequest, toDestination destination: URL,
                               withSuccessClosure successClosure: HTTPSuccessClosure?,
                               andFailureClosure failureClosure: HTTPErrorClosure?) {
        
        HTTPService.sendEventBefore(request: httpRequest)
        let date = Date()
        
        let execute: (URLRequest) -> Void = { request in
            let task = self.shared.session.downloadTask(with: request, completionHandler: { location, urlResponse, error in
                
                let executionDuration = Date().timeIntervalSince(date)
                HTTPService.sendEventAfter(request: request, withResponse: urlResponse, withData: nil, andDuration: executionDuration)
                
                // Error from request or service
                guard let location = location, error == nil || (urlResponse as? HTTPURLResponse != nil && !(HTTPCode.successCodes.range ~= (urlResponse as! HTTPURLResponse).statusCode)) else {
                    
                   // HTTPService.ping(error: error, withResponse: urlResponse, withData: nil, andFailureClosure: failureClosure)
                    return
                }
                // Error from request or service
                do {
                    try FileManager.default.moveItem(at: location, to: destination)
                } catch {
                    failureClosure?((error as NSError), nil, HTTPResponseFailureReason.parseError)
                    return
                }
                
                // Success
                successClosure?(nil, (urlResponse as! HTTPURLResponse))
            })
            task.resume()
        }
        
        self.signRequest(httpRequest, successClosure: execute, andFailureClosure: failureClosure)
    }
    
    // MARK: HTTPManager Event delegate
    
    fileprivate static func sendEventBefore(request: HTTPRequest) {
        HTTPManager.shared.willExecute(request: HTTPRequestHelper.getRequest(forRequest: request))
    }
    
    fileprivate static func sendEventAfter(request: URLRequest, withResponse urlResponse: URLResponse?, withData data: Data?, andDuration duration: TimeInterval) {
        if let response: HTTPURLResponse = urlResponse as? HTTPURLResponse {
            HTTPManager.shared.didExecute(request: request, withResponse: response, withData: data, andDuration: duration)
        } else {
            HTTPManager.shared.didExecute(request: request, withResponse: nil, withData: nil, andDuration: duration)
        }
    }
}
