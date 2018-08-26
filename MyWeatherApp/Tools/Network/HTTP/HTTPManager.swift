//
//  HTTPManager.swift
//  MyWeatherApp
//
//  Created by Lan on 23/07/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import Foundation

public protocol HTTPConfigurationDelegate {
    func didFailRefreshAuthorizedToken(_ error: NSError) -> Void
    func didMigrateAuthorizationToken() -> Any?
    func willSetCommonAdditionalHeader() -> [String : String]
}

public protocol HTTPManagerEvent {
    func willExecute(request: URLRequest?) -> Void
    func didExecute(request: URLRequest?, withResponse response: HTTPURLResponse?, withData data: Data?, andDuration duration: TimeInterval) -> Void
}

open class HTTPManager {
    
    // MARK: Singleton
    
    open static let shared: HTTPManager = HTTPManager()
    
    // MARK: Properties
    
    var commonAdditionalHeader: [String: String] {
        return self.delegate?.willSetCommonAdditionalHeader() ?? [:]
    }
    
    public var migratedToken: Any? {
        return self.delegate?.didMigrateAuthorizationToken()
    }
    
    public var eventDelegate: HTTPManagerEvent?
    
    public var delegate: HTTPConfigurationDelegate?
    
    // MARK: Initialization
    
    init() {}
    
    // MARK: Enumeration
    
    enum Response {
        case empty(HTTPURLResponse)
        case json(Any)
        case data(Data)
        case error(HTTPService.HTTPResponseFailureReason)
    }
    
    // MARK: Properties
    
    fileprivate let privateQueue: DispatchQueue = DispatchQueue(label: "com.HTTPManager.PrivateQueue", attributes: DispatchQueue.Attributes.concurrent)
    
    // MARK: Core
    
    func execute(requestClosure request: @escaping (() -> HTTPRequest), andReponseClosure response: @escaping ((Response) -> Void)) {
        privateQueue.async {
            
            let request: HTTPRequest = request()
            
            let failureClosure: (HTTPService.HTTPResponseFailureReason) -> Void = { reason in
                response(.error(reason))
            }
            
            switch request.outputFormat {
            case .json:
                let successClosure: (Any) -> Void = { json in
                    response(.json(json))
                }
                HTTPService.executeJSON(request, withSuccessClosure: successClosure, andFailureClosure: failureClosure)
            case .empty:
                let successClosure: (HTTPURLResponse) -> Void = { HTTPResponse in
                    response(.empty(HTTPResponse))
                }
                HTTPService.excecuteEmpty(request, withSuccessClosure: successClosure, andFailureClosure: failureClosure)
            case .data:
                let successClosure: (Data) -> Void = { data in
                    response(.data(data))
                }
                HTTPService.executeData(request, withSuccessClosure: successClosure, andFailureClosure: failureClosure)
            }
        }
    }
    
    func execute(requestClosure request: @escaping (() -> (HTTPRequest, Data)), andReponseClosure response: @escaping ((Response) -> Void)) {
        privateQueue.async {
            
            let closureRequest = request()
            let request: HTTPRequest = closureRequest.0
            let data: Data = closureRequest.1
            
            let failureClosure: (HTTPService.HTTPResponseFailureReason) -> Void = { reason in
                response(.error(reason))
            }
            
            switch request.outputFormat {
            case .json:
                let successClosure: (Any) -> Void = { json in
                    response(.json(json))
                }
                HTTPService.executeUploadJSON(request, fromData: data, withSuccessClosure: successClosure, andFailureClosure: failureClosure)
            case .empty:
                let successClosure: (HTTPURLResponse) -> Void = { HTTPResponse in
                    response(.empty(HTTPResponse))
                }
                HTTPService.excecuteUploadEmpty(request, fromData: data, withSuccessClosure: successClosure, andFailureClosure: failureClosure)
            case .data:
                let successClosure: (Data) -> Void = { data in
                    response(.data(data))
                }
                HTTPService.executeUploadData(request, fromData: data, withSuccessClosure: successClosure, andFailureClosure: failureClosure)
            }
        }
    }
    
    func download(requestClosure request: @escaping (() -> (request: HTTPRequest, location: URL)), andReponseClosure response: @escaping ((Response) -> Void)) {
        privateQueue.async {
                        
            let closureRequest = request()
            let request: HTTPRequest = closureRequest.request
            let location: URL = closureRequest.location
            
            let failureClosure: (Error?, Data?, HTTPService.HTTPResponseFailureReason) -> Void = { error, data, reason in
                response(.error(reason))
            }
            
            switch request.outputFormat {
            case .empty:
                let successClosure: (Data?, HTTPURLResponse) -> Void = { data, HTTPResponse in
                    response(.empty(HTTPResponse))
                }
                HTTPService.executeDownload(request, toDestination: location, withSuccessClosure: successClosure, andFailureClosure: failureClosure)
            default:
                failureClosure(nil, nil, HTTPService.HTTPResponseFailureReason.parseError)
                return
            }
        }
    }
}


extension HTTPManager {

    // MARK: Event delegate call

    internal func willExecute(request: URLRequest?) -> Void {
        self.eventDelegate?.willExecute(request: request)
    }
    
    internal func didExecute(request: URLRequest?, withResponse response: HTTPURLResponse?, withData data: Data?, andDuration duration: TimeInterval) -> Void {
        self.eventDelegate?.didExecute(request: request, withResponse: response, withData: data, andDuration: duration)
    }
}
