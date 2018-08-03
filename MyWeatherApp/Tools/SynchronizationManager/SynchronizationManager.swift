//
//  SynchronizationManager.swift
//  MyWeatherApp
//
//  Created by Lan on 31/07/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import Foundation

//protocol TileSetSynchronizationObserver {
//    func synchronizationManagerDidUpdateTileSet(_ synchronizationManager: SynchronizationManager, didUpdateTileSet tileSet: SM_TileSet)
//}

/**
This class is responsible for performing tasks at regular interval such as requesting logged user informations in order to update the UI, etc.
Current cron tasks executed :
    -   Fetching logged user informations
*/
class SynchronizationManager: NSObject {

    // MARK: Constants

    fileprivate struct Constants {
        #if DEBUG
        static let fetchUserIntervals: (TimeInterval, TimeInterval)                     = (60*2,        60*1)
        static let fetchTerminalsIntervals: (TimeInterval, TimeInterval)                = (60*60,       60*2)
        static let fetchDestinationsIntervals: (TimeInterval, TimeInterval)             = (60*60,       60*2)
        static let fetchThemesIntervals: (TimeInterval, TimeInterval)                   = (60*60,       60*2)
        static let fetchAlertFlashIntervals: (TimeInterval, TimeInterval)               = (60*1,        30*1)
        static let fetchParkingTerminalsIntervals: (TimeInterval, TimeInterval)         = (60*60,       60*2)
        static let fetchCMSServicesIntervals: (TimeInterval, TimeInterval)              = (60*60,       30*1)
        static let fetchCMSCommercialIntervals: (TimeInterval, TimeInterval)            = (60*60,       30*1)
        static let fetchCMSEServicesIntervals: (TimeInterval, TimeInterval)             = (60*60,       30*1)
        static let fetchFidelityProgramServicesIntervals: (TimeInterval, TimeInterval)  = (60*60,       30*1)
        static let fetchTileSetIntervals: (TimeInterval, TimeInterval)                  = (60*1,        30*1)
        #else
        static let fetchUserIntervals: (TimeInterval, TimeInterval)                     = (60*2,        60*1)
        static let fetchTerminalsIntervals: (TimeInterval, TimeInterval)                = (60*60*24,    60*1)
        static let fetchDestinationsIntervals: (TimeInterval, TimeInterval)             = (60*60*24,    60*10)
        static let fetchThemesIntervals: (TimeInterval, TimeInterval)                   = (60*60*24,    60*10)
        static let fetchAlertFlashIntervals: (TimeInterval, TimeInterval)               = (60*1,        60*1)
        static let fetchParkingTerminalsIntervals: (TimeInterval, TimeInterval)         = (60*60*24,    60*1)
        static let fetchCMSServicesIntervals: (TimeInterval, TimeInterval)              = (60*60*24,    30*1)
        static let fetchCMSCommercialIntervals: (TimeInterval, TimeInterval)            = (60*60*24,    30*1)
        static let fetchCMSEServicesIntervals: (TimeInterval, TimeInterval)             = (60*60*24,    30*1)
        static let fetchFidelityProgramServicesIntervals: (TimeInterval, TimeInterval)  = (60*60*24,    30*1)
        static let fetchTileSetIntervals: (TimeInterval, TimeInterval)                  = (60*10,       60*1)
        #endif
    }
    
    // MARK: Singleton

    static let sharedInstance: SynchronizationManager = SynchronizationManager()

    // MARK: Private properties

    fileprivate var operationQueue: OperationQueue = {
        let operationQueue: OperationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 5
        return operationQueue
    }()

//    fileprivate var tasks: [CronTask] = []
//    fileprivate var synchronizeUserTask: CronTask!

//    fileprivate var userObservers: ObserverSet<(SynchronizationManager, User)> = ObserverSet()
//    fileprivate var terminalObservers: ObserverSet<SynchronizationManager> = ObserverSet()
//    fileprivate var parkingTerminalObservers: ObserverSet<SynchronizationManager> = ObserverSet()
//    fileprivate var themeObservers: ObserverSet<SynchronizationManager> = ObserverSet()
//    fileprivate var alertFlashObservers: ObserverSet<SynchronizationManager> = ObserverSet()
//    fileprivate var tileSetObservers: ObserverSet<(SynchronizationManager, SM_TileSet)> = ObserverSet()
    
    // MARK: Public properties

    fileprivate(set) var isSynchronizingTerminals: Bool = false
    fileprivate(set) var isSynchronizingParkingTerminals: Bool = false
    fileprivate(set) var isSynchronizingThemes: Bool = false

    // MARK: Initializers

    override init() {
        super.init()
        
        ReachabilityManager.sharedInstance.addObserver(self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SynchronizationManager.applicationDidEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SynchronizationManager.applicationDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SynchronizationManager.languageDidChange(_:)), name: NSNotification.Name(rawValue: LanguageManager.Constants.appLanguageDidChangedNotification), object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SynchronizationManager.userLoggedStatusDidChange(_:)), name: LoginOperationDidSuccessNotification, object: nil)
        
        self.setupTasks()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Setup methods

    fileprivate func setupTasks() {
        let fetchUserTask: CronTask = CronTask(timeInterval: Constants.fetchUserIntervals.0, failureTimeInterval: Constants.fetchUserIntervals.1,
            executionBlock: { [unowned self] (completionHandler) -> Void in
                self.synchronizeLoggedUser(completionHandler)
            },
            conditionBlock: { _ in
                return UserSessionManager.sharedInstance.isConnected
            }
        )
    
        self.synchronizeUserTask = fetchUserTask

        let fetchTerminalsTask: CronTask = CronTask(timeInterval: Constants.fetchTerminalsIntervals.0, failureTimeInterval: Constants.fetchTerminalsIntervals.1,
            executionBlock: { [unowned self] completionHandler -> Void in
                self.synchronizeTerminals(completionHandler)
            },
            conditionBlock: { task in
                if let lastTimeTerminalsUpdated: Date = UserDefaultsManager.lastTimeTerminalUpdated {
                    let now: Date = Date()
                    let timeInterval: TimeInterval = now.timeIntervalSince(lastTimeTerminalsUpdated)
                    return timeInterval > task.currentTimeInterval
                } else {
                    return true
                }
            }
        )

        let fetchParkingTerminalsTask: CronTask = CronTask(timeInterval: Constants.fetchParkingTerminalsIntervals.0, failureTimeInterval: Constants.fetchParkingTerminalsIntervals.1,
            executionBlock: { [unowned self] completionHandler -> Void in
                self.synchronizeParkingTerminals(completionHandler)
            },
            conditionBlock: { task in
                if let lastTimeParkingTerminalsUpdated: Date = UserDefaultsManager.lastTimeParkingTerminalUpdated {
                    let now: Date = Date()
                    let timeInterval: TimeInterval = now.timeIntervalSince(lastTimeParkingTerminalsUpdated)
                    return timeInterval > task.currentTimeInterval
                } else {
                    return true
                }
            }
        )
        
        let alertFlashTask: CronTask = CronTask(timeInterval: Constants.fetchAlertFlashIntervals.0, failureTimeInterval: Constants.fetchAlertFlashIntervals.1,
            executionBlock: { [unowned self] completionHandler -> Void in
                self.synchronizeAlertFlash(completionHandler)
            },
            conditionBlock: { task in
                return true
            }
        )

        let fetchCategoriesAndThemesTask: CronTask = CronTask(timeInterval: Constants.fetchThemesIntervals.0, failureTimeInterval: Constants.fetchThemesIntervals.1,
            executionBlock: { [unowned self] completionHandler -> Void in
                self.synchronizeCategoriesAndThemes(completionHandler)
            },
            conditionBlock: { task in
                guard ReachabilityManager.sharedInstance.isNetworkAvailable else { return false }
                //guard let _ = AuthorizationTokenManager.sharedInstance.token else { return false }
                
                if let lastTimeThemesUpdated: Date = UserDefaultsManager.lastTimeThemesUpdated {
                    let now: Date = Date()
                    let timeInterval: TimeInterval = now.timeIntervalSince(lastTimeThemesUpdated)
                    return timeInterval > task.currentTimeInterval
                } else {
                    return true
                }
            }
        )

        let fetchDestinationsTask: CronTask = CronTask(timeInterval: Constants.fetchDestinationsIntervals.0, failureTimeInterval: Constants.fetchDestinationsIntervals.1,
            executionBlock: { [unowned self] completionHandler -> Void in
                self.synchronizeDestinations(completionHandler)
            },
            conditionBlock: { task in
                if let lastTimeDestinationsUpdated: Date = UserDefaultsManager.lastTimeDestinationsUpdated {
                    let timeInterval: TimeInterval = Date().timeIntervalSince(lastTimeDestinationsUpdated)
                    return timeInterval > task.currentTimeInterval
                } else {
                    return true
                }
            }
        )
        
        
        let fetchCMSServicesTask: CronTask = CronTask(timeInterval: Constants.fetchCMSServicesIntervals.0, failureTimeInterval: Constants.fetchCMSServicesIntervals.1,
                executionBlock: self.synchronizeCMSServices,
                conditionBlock: { task in
                    if let lastTimeServicesUpdated: Date = UserDefaultsManager.lastTimeCMSServicesUpdated {
                        let timeInterval: TimeInterval = Date().timeIntervalSince(lastTimeServicesUpdated)
                        return timeInterval > task.currentTimeInterval
                    } else {
                        return true
                    }
                }
        )
        
        let fetchCMSCommercialTask: CronTask = CronTask(timeInterval: Constants.fetchCMSCommercialIntervals.0, failureTimeInterval: Constants.fetchCMSCommercialIntervals.1,
                executionBlock: self.synchronizeCMSCommercial,
                conditionBlock: { task in
                    if let lastTimeCommercialUpdated: Date = UserDefaultsManager.lastTimeCMSCommercialUpdated {
                        let timeInterval: TimeInterval = Date().timeIntervalSince(lastTimeCommercialUpdated)
                        return timeInterval > task.currentTimeInterval
                    } else {
                        return true
                    }
                }
        )
        
        let fetchCMSEServicesTask: CronTask = CronTask(timeInterval: Constants.fetchCMSEServicesIntervals.0, failureTimeInterval: Constants.fetchCMSEServicesIntervals.1,
               executionBlock: self.synchronizeCMSEServices,
               conditionBlock: { task in
                if let lastTimeServicesUpdated: Date = UserDefaultsManager.lastTimeCMSEServicesUpdated {
                    let timeInterval: TimeInterval = Date().timeIntervalSince(lastTimeServicesUpdated)
                    return timeInterval > task.currentTimeInterval
                } else {
                    return true
                }
            }
        )
        
        let fetchFidelityProgramTask: CronTask = CronTask(timeInterval: Constants.fetchFidelityProgramServicesIntervals.0, failureTimeInterval: Constants.fetchFidelityProgramServicesIntervals.1,
            executionBlock: self.synchronizeFidelityProgramTask,
            conditionBlock: { task in
                if let lastTimeServicesUpdated: Date = UserDefaultsManager.lastTimeFidelityProgramUpdated {
                    let timeInterval: TimeInterval = Date().timeIntervalSince(lastTimeServicesUpdated)
                    return timeInterval > task.currentTimeInterval
                } else {
                    return true
                }
            }
        )
        
        let tileSetTask: CronTask = CronTask(timeInterval: Constants.fetchTileSetIntervals.0,
            failureTimeInterval: Constants.fetchTileSetIntervals.1,
            executionBlock: self.synchronizeTileSetTask,
            conditionBlock: { task in
                if let lastTimeServicesUpdated: Date = UserDefaultsManager.lastTimeTileSetUpdated {
                    let timeInterval: TimeInterval = Date().timeIntervalSince(lastTimeServicesUpdated)
                    return timeInterval > task.currentTimeInterval
                } else {
                    return true
                }
            }
        )
        
        self.tasks = [fetchUserTask, fetchCategoriesAndThemesTask, fetchTerminalsTask, fetchDestinationsTask, fetchCMSServicesTask, fetchParkingTerminalsTask, alertFlashTask, fetchFidelityProgramTask, fetchCMSCommercialTask, fetchCMSEServicesTask, tileSetTask]
    }

    // MARK: Public methods

    func start() {
        self.tasks.execute({ $0.start() })
    }

    func stop() {
        self.tasks.execute({ $0.stop() })
    }

    func fire() {
        self.tasks.execute({ $0.fire() })
    }

    func addUserObserver<T: AnyObject & UserSynchronizationObserver>(_ observer: T) {
        let f: (T) -> (SynchronizationManager, User) -> Void = type(of: observer).synchronizationManager
        _ = self.userObservers.add(observer, f)
    }

    func addTerminalObserver<T: AnyObject & TerminalSynchronizationObserver>(_ observer: T) {
        let f: (T) -> (SynchronizationManager) -> Void = type(of: observer).synchronizationManagerDidUpdateTerminals
        _ = self.terminalObservers.add(observer, f)
    }

    func addParkingTerminalObserver<T: AnyObject & ParkingTerminalSynchronizationObserver>(_ observer: T) {
        let f: (T) -> (SynchronizationManager) -> Void = type(of: observer).synchronizationManagerDidUpdateParkingTerminals
        _ = self.terminalObservers.add(observer, f)
    }
    
    func addAlertFlashObserver<T: AnyObject & AlertFlashSynchronizationObserver>(_ observer: T) -> ObserverSetEntry<SynchronizationManager> {
        let f: (T) -> (SynchronizationManager) -> Void = type(of: observer).synchronizationManagedDidUpdateAlertFlashData
        return self.alertFlashObservers.add(observer, f)
    }

    func removeAlertFlashObserver(_ observer: ObserverSetEntry<SynchronizationManager>) {
        self.alertFlashObservers.remove(observer)
    }

    func addThemeObserver<T: AnyObject & ThemeSynchronizationObserver>(_ observer: T) {
        let f: (T) -> (SynchronizationManager) -> Void = type(of: observer).synchronizationManagerDidUpdateThemes
        _ = self.themeObservers.add(observer, f)
    }
    
    func synchronizeUserIfNeeded() {
        self.synchronizeUserTask.fire()
    }

    // MARK: Notification methods

    @objc fileprivate func applicationDidEnterBackground(_ notification: Notification) {
        self.stop()
    }

    @objc fileprivate func applicationDidBecomeActive(_ notification: Notification) {
        self.start()
        self.fire()
    }
    
    @objc fileprivate func languageDidChange(_ notification: Notification) {
        UserDefaultsManager.lastTimeDestinationsUpdated = nil
        UserDefaultsManager.lastTimeThemesUpdated = nil
        UserDefaultsManager.lastTimeTerminalUpdated = nil
        UserDefaultsManager.lastTimeParkingTerminalUpdated = nil
        UserDefaultsManager.lastTimeCMSServicesUpdated = nil
        UserDefaultsManager.lastTimeFidelityProgramUpdated = nil
        
        self.fire()
    }
    
    @objc fileprivate func authorizationTokenManagerDidFetchAnonymousToken(_ notification: Notification) {
        UserDefaultsManager.lastTimeCMSServicesUpdated = nil
        
        self.fire()
    }
    
    @objc fileprivate func userLoggedStatusDidChange(_ notification: Notification) {
        UserDefaultsManager.lastTimeCMSServicesUpdated = nil
        
        self.fire()
    }
    
    // MARK: Private methods

    fileprivate func synchronizeLoggedUser(_ completionHandler: @escaping (CronTask.Status) -> Void) {
        let operation: SynchronizeLoggedUserOperation = SynchronizeLoggedUserOperation(synchronizationCompletionHandler: completionHandler)
        operation.synchronizeUserHandler = { [unowned self] user in
            let infos: (SynchronizationManager, User) = (self, user)
            self.userObservers.notify(infos)
        }
        
        self.operationQueue.addOperation(operation)
    }
    
    fileprivate func synchronizeTerminals(_ completionHandler: @escaping (CronTask.Status) -> Void) {
        self.isSynchronizingTerminals = true

        let fetchTerminalsOperation: FetchAllTerminalsOperation = FetchAllTerminalsOperation(completionClosure: { success in
            completionHandler((success ? .success : .failure))
            if success {
                UserDefaultsManager.lastTimeTerminalUpdated = Date()
            }

            self.isSynchronizingTerminals = false
            self.terminalObservers.notify(self)
        })

        self.operationQueue.addOperation(fetchTerminalsOperation)
    }

    fileprivate func synchronizeParkingTerminals(_ completionHandler: @escaping (CronTask.Status) -> Void) {
        self.isSynchronizingParkingTerminals = true
        
        let operation: SynchronizeParkingTerminalsOperation = SynchronizeParkingTerminalsOperation(synchronizationCompletionHandler: completionHandler)
        operation.synchronizeParkingTerminalsHandler = { [unowned self] success in
            if success {
                UserDefaultsManager.lastTimeParkingTerminalUpdated = Date()
                self.isSynchronizingParkingTerminals = false
                self.parkingTerminalObservers.notify(self)
            } else {
                self.isSynchronizingParkingTerminals = false
            }
        }
        
        self.operationQueue.addOperation(operation)
    }
    
    fileprivate func synchronizeAlertFlash(_ completionHandler: @escaping (CronTask.Status) -> Void) {
        let operation: SynchronizeAlertFlashOperation = SynchronizeAlertFlashOperation(synchronizationCompletionHandler: completionHandler)
        operation.synchronizeAlertFlashHandler = { [unowned self] in

            self.alertFlashObservers.notify(self)
        }
        
        self.operationQueue.addOperation(operation)
    }

    fileprivate func synchronizeDestinations(_ completionHandler: @escaping (CronTask.Status) -> Void) {
        let operation: SynchronizeDestinationsOperation = SynchronizeDestinationsOperation(synchronizationCompletionHandler: completionHandler)
        operation.synchronizeDestinationsHandler = {
            UserDefaultsManager.lastTimeDestinationsUpdated = Date()
        }
        
        self.addUniqueOperation(operation)
    }

    fileprivate func synchronizeCategoriesAndThemes(_ completionHandler: (CronTask.Status) -> Void) {
        let airports: [Airports] = [Airports.CDG, Airports.ORY]
        self.isSynchronizingThemes = true

        // 1° fetch categories and save them in coredata

        var previousOperation: FetchCategoryOperation?

        let categoryOperations: [Operation] = airports.map { airport -> Operation in
            let operation: FetchCategoryOperation = FetchCategoryOperation(airport: airport, completionClosure: nil)
            if let previousOperation: FetchCategoryOperation = previousOperation {
                operation.addDependency(previousOperation)
            }
            previousOperation = operation

            return operation
        }

        // 2° fetch themes once categories operation are done

        let lastCategoryOperation: Operation = categoryOperations.last!

        let lastCategoryOperationCompletionClosure: () -> Void = {
            var themeOperations: [Operation] = []
            var previousThemeOperation: Operation?
            let categories: [POICategory] = POICategory.mr_findAll() as! [POICategory]

            for airport in airports {
                for category in categories where category.airportTasCodes.contains(airport.tasCode) {
                    let operation: FetchThemeOperation = FetchThemeOperation(
                        airport: airport,
                        categoryId: category.identifier.intValue,
                        completionClosure: nil)

                    if let previousThemeOperation: Operation = previousThemeOperation {
                        operation.addDependency(previousThemeOperation)
                    }

                    themeOperations.append(operation)
                    previousThemeOperation = operation
                }
            }

            self.operationQueue.addOperations(themeOperations, waitUntilFinished: false)

            if let lastThemeOperation: Operation = themeOperations.last {
                lastThemeOperation.completionBlock = {
                    UserDefaultsManager.lastTimeThemesUpdated = Date()
                    self.isSynchronizingThemes = false
                    self.themeObservers.notify(self)
                }
            } else {
                UserDefaultsManager.lastTimeThemesUpdated = Date()
                self.isSynchronizingThemes = false
                self.themeObservers.notify(self)
            }
        }

        lastCategoryOperation.completionBlock = lastCategoryOperationCompletionClosure

        self.operationQueue.addOperations(categoryOperations, waitUntilFinished: false)
    }
    
    fileprivate func synchronizeCMSServices(_ completionHandler: @escaping (CronTask.Status) -> Void) {
        
        var cancelled = false
        
        let completionClosure: () -> Void = {
            
            if cancelled { return }
            
            ADPDispatch.async {
                NotificationCenter.default.post(name: Notification.Name(rawValue: SynchronizationManager.CMSServicesListUpdatedNotification), object: nil)
            }
            
            if let _ = CMSFileManager.retrieveJsonMenu() {
                UserDefaultsManager.lastTimeCMSServicesUpdated = Date()
                completionHandler(.success)
            } else {
                UserDefaultsManager.lastTimeCMSServicesUpdated = Date()
                completionHandler(.failure)
            }

//            // Operations to fetch the html pages following the menu operation
//            var fetchHtmlPagesOperations: [Operation] = []
//            var previousHtmlPagesOperation: Operation?
//            
//            var expectedUrlCount: Int = 0
//            var urlDownloadSucceededCount: Int = 0
//            
//            //For all Html urls to download:
//            if let cmsServiceMenu: CMSServiceCategoryResponseJSON = CMSFileManager.retrieveJsonMenu() {
//                
//                cmsServiceMenu.serviceCategoryList.execute { serviceCategory in
//                    serviceCategory.services.execute { service in
//                        
//                        // check that it doesn't start with the "myairport" string (deeplink)
//                        if !service.pageURL.hasPrefix(ConstantsGlobal.Scheme.appScheme) {
//                            
//                            expectedUrlCount += 1
//                            
//                            let completeUrl: String = service.pageURL
//                            
//                            let fetchCMSServiceHtmlOperation: FetchCMSServiceHtmlOperation = FetchCMSServiceHtmlOperation(completeUrl: completeUrl,serviceConstants: CMSManager.CMSType.Service.constants, completionClosure: { success in
//                                if success {
//                                    urlDownloadSucceededCount += 1
//                                }
//                            })
//                            
//                            if let previousHtmlPagesOperation: Operation = previousHtmlPagesOperation {
//                                fetchCMSServiceHtmlOperation.addDependency(previousHtmlPagesOperation)
//                            }
//                            
//                            fetchHtmlPagesOperations.append(fetchCMSServiceHtmlOperation)
//                            previousHtmlPagesOperation = fetchCMSServiceHtmlOperation
//                        }
//                    }
//                }
//                
//                self.operationQueue.addOperations(fetchHtmlPagesOperations, waitUntilFinished: false)
//                
//            } else {
//
//                if let _ = UserDefaultsManager.lastTimeCMSServicesUpdated {
//                    UserDefaultsManager.lastTimeCMSServicesUpdated = NSDate()
//                }
//                completionHandler(.Failure)
//            }
//            
//            if let fetchHtmlPageOperation: Operation = fetchHtmlPagesOperations.last {
//                fetchHtmlPageOperation.completionBlock = {
//
//                    if expectedUrlCount == urlDownloadSucceededCount {
//                        UserDefaultsManager.lastTimeCMSServicesUpdated = NSDate()
//                        completionHandler(.Success)
//                    } else {
//
//                        if let _ = UserDefaultsManager.lastTimeCMSServicesUpdated {
//                            UserDefaultsManager.lastTimeCMSServicesUpdated = NSDate()
//                        }
//                        completionHandler(.Failure)
//                    }
//                }
//            } else {
//                
//                if let _ = UserDefaultsManager.lastTimeCMSServicesUpdated {
//                    UserDefaultsManager.lastTimeCMSServicesUpdated = NSDate()
//                }
//                completionHandler(.Failure)
//            }
        }
        
        
        // Operation to fetch the menu
        let fetchCMSServicesMenuOperation: FetchCMSServicesMenuOperation = FetchCMSServicesMenuOperation(serviceType: .service, completionClosure: {success in
            
            if !success {
                cancelled = true
                completionHandler(.failure)
            }
            
        })

        fetchCMSServicesMenuOperation.completionBlock = completionClosure
        self.operationQueue.addOperation(fetchCMSServicesMenuOperation)
    }
    
    fileprivate func synchronizeCMSCommercial(_ completionHandler: @escaping (CronTask.Status) -> Void) {
        
        var cancelled = false
        
        let completionClosure: () -> Void = {
            
            if cancelled { return }
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: SynchronizationManager.CMSCommercialListUpdatedNotification), object: nil)
            
            // Operations to fetch the html pages following the menu operation
            var fetchHtmlPagesOperations: [Operation] = []
            var previousHtmlPagesOperation: Operation?
            
            var expectedUrlCount: Int = 0
            var urlDownloadSucceededCount: Int = 0
            
            //For all Html urls to download:
            if let cmsCommercialOffers: CMSCommercialCategoryResponseJSON = CMSFileManager.retrieveJsonCommercialsOffers() {
                
                cmsCommercialOffers.commercialCategoryList.execute { commercialCategory in
                    commercialCategory.services.execute { service in
                        
                        // check that it doesn't start with the "myairport" string (deeplink)
                        if !service.pageURL.hasPrefix(ConstantsGlobal.Scheme.appScheme) {
                            
                            expectedUrlCount += 1
                            
                            let completeUrl: String = service.pageURL
                            
                            let fetchCMSCommercialHtmlOperation: FetchCMSServiceHtmlOperation = FetchCMSServiceHtmlOperation(completeUrl: completeUrl,serviceConstants: CMSManager.CMSType.commercial.constants, completionClosure: { success in
                                if success {
                                    urlDownloadSucceededCount += 1
                                }
                            })
                            
                            if let previousHtmlPagesOperation: Operation = previousHtmlPagesOperation {
                                fetchCMSCommercialHtmlOperation.addDependency(previousHtmlPagesOperation)
                            }
                            
                            fetchHtmlPagesOperations.append(fetchCMSCommercialHtmlOperation)
                            previousHtmlPagesOperation = fetchCMSCommercialHtmlOperation
                        }
                    }
                }
                
                self.operationQueue.addOperations(fetchHtmlPagesOperations, waitUntilFinished: false)
                
            } else {
                
                if let _ = UserDefaultsManager.lastTimeCMSServicesUpdated {
                    UserDefaultsManager.lastTimeCMSServicesUpdated = Date()
                }
                completionHandler(.failure)
            }
            
            if let fetchHtmlPageOperation: Operation = fetchHtmlPagesOperations.last {
                fetchHtmlPageOperation.completionBlock = {
                    
                    if expectedUrlCount == urlDownloadSucceededCount {
                        UserDefaultsManager.lastTimeCMSCommercialUpdated = Date()
                        completionHandler(.success)
                    } else {
                        
                        if let _ = UserDefaultsManager.lastTimeCMSCommercialUpdated {
                            UserDefaultsManager.lastTimeCMSCommercialUpdated = Date()
                        }
                        completionHandler(.failure)
                    }
                }
            } else {
                
                if let _ = UserDefaultsManager.lastTimeCMSCommercialUpdated {
                    UserDefaultsManager.lastTimeCMSCommercialUpdated = Date()
                }
                completionHandler(.failure)
            }
        }
        
        
        // Operation to fetch the menu
        let fetchCMSCommercialOperation: FetchCMSServicesMenuOperation = FetchCMSServicesMenuOperation(serviceType: .commercial, completionClosure: {success in
            
            if !success {
                cancelled = true
                completionHandler(.failure)
            }
            
        })
        
        fetchCMSCommercialOperation.completionBlock = completionClosure
        self.operationQueue.addOperation(fetchCMSCommercialOperation)
    }
    
    fileprivate func synchronizeCMSEServices(_ completionHandler: @escaping (CronTask.Status) -> Void) {
        var cancelled = false
        
        let completionClosure: () -> Void = {
            
            if cancelled { return }
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: SynchronizationManager.CMSEServicesListUpdatedNotification), object: nil)
            
            // Operations to fetch the html pages following the menu operation
            var fetchHtmlPagesOperations: [Operation] = []
            var previousHtmlPagesOperation: Operation?
            
            var expectedUrlCount: Int = 0
            var urlDownloadSucceededCount: Int = 0
            
            //For all Html urls to download:
            if let cmsServiceMenu: CMSServiceCategoryResponseJSON = CMSFileManager.retrieveJsonMenu() {
                
                cmsServiceMenu.serviceCategoryList.execute { serviceCategory in
                    serviceCategory.services.execute { service in
                        
                        // check that it doesn't start with the "myairport" string (deeplink)
                        if !service.pageURL.hasPrefix(ConstantsGlobal.Scheme.appScheme) {
                            
                            expectedUrlCount += 1
                            
                            let completeUrl: String = service.pageURL
                            
                            let fetchCMSServiceHtmlOperation: FetchCMSServiceHtmlOperation = FetchCMSServiceHtmlOperation(completeUrl: completeUrl, serviceConstants: CMSManager.CMSType.eService.constants, completionClosure: { success in
                                if success {
                                    urlDownloadSucceededCount += 1
                                }
                            })
                            
                            if let previousHtmlPagesOperation: Operation = previousHtmlPagesOperation {
                                fetchCMSServiceHtmlOperation.addDependency(previousHtmlPagesOperation)
                            }
                            
                            fetchHtmlPagesOperations.append(fetchCMSServiceHtmlOperation)
                            previousHtmlPagesOperation = fetchCMSServiceHtmlOperation
                        }
                    }
                }
                
                self.operationQueue.addOperations(fetchHtmlPagesOperations, waitUntilFinished: false)
                
            } else {
                
                if let _ = UserDefaultsManager.lastTimeCMSServicesUpdated {
                    UserDefaultsManager.lastTimeCMSServicesUpdated = Date()
                }
                completionHandler(.failure)
            }
            
            if let fetchHtmlPageOperation: Operation = fetchHtmlPagesOperations.last {
                fetchHtmlPageOperation.completionBlock = {
                    
                    if expectedUrlCount == urlDownloadSucceededCount {
                        UserDefaultsManager.lastTimeCMSServicesUpdated = Date()
                        completionHandler(.success)
                    } else {
                        
                        if let _ = UserDefaultsManager.lastTimeCMSServicesUpdated {
                            UserDefaultsManager.lastTimeCMSServicesUpdated = Date()
                        }
                        completionHandler(.failure)
                    }
                }
            } else {
                
                if let _ = UserDefaultsManager.lastTimeCMSServicesUpdated {
                    UserDefaultsManager.lastTimeCMSServicesUpdated = Date()
                }
                completionHandler(.failure)
            }
        }
        
        
        // Operation to fetch the menu
        let fetchCMSEServicesMenuOperation: FetchCMSServicesMenuOperation = FetchCMSServicesMenuOperation(serviceType: .eService, completionClosure: {success in
            
            if !success {
                cancelled = true
                completionHandler(.failure)
            }
        })
        
        fetchCMSEServicesMenuOperation.completionBlock = completionClosure
        self.operationQueue.addOperation(fetchCMSEServicesMenuOperation)
    }
    
    fileprivate func synchronizeFidelityProgramTask(_ completionHandler: @escaping (CronTask.Status) -> Void) {
        let operation = SynchronizeFidelityProgramOperation(synchronizationCompletionHandler: completionHandler)
        
        operation.synchronizationHandler = {
            UserDefaultsManager.lastTimeFidelityProgramUpdated = Date()
        }
        
        self.operationQueue.addOperation(operation)
    }
    
    fileprivate func synchronizeTileSetTask(_ completionHandler: @escaping (CronTask.Status) -> Void) {
        let operation: SynchronizeTileSetOperation = SynchronizeTileSetOperation(synchronizationCompletionHandler: completionHandler)
        operation.synchronizeTileSetHandler = { _ in
            UserDefaultsManager.lastTimeTileSetUpdated = Date()
        }
        
        self.operationQueue.addOperation(operation)
    }

    fileprivate func addUniqueOperation <T : Operation> (_ operation: T) {

        var operationClassExist = false
        let operationQueueCopy = self.operationQueue.operations
        
        for operation in operationQueueCopy {
            if operation.isKind(of: T.self) {
                operationClassExist = true
                break
            }
        }
        
        if !operationClassExist {
            self.operationQueue.addOperation(operation)
        }
    }
}

extension SynchronizationManager: ReachabilityObserver {
    func reachabilityManager(_ reachabilityManager: ReachabilityManager, withNetworkAvailable networkAvailable: Bool) {
        guard networkAvailable else { return }
        self.fire()
    }
}
