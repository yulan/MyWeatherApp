//
//  CoreDataStructModelProtocol.swift
//  MyWeatherApp
//
//  Created by Lan on 16/07/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import Foundation

protocol CoreDataStructJSONProtocol {
    init?(with json: Any?)
    init?(withJson json: JSON)
}

extension Array where Element: CoreDataStructJSONProtocol {
    init(withJson json: Any) {
        switch json {
        case let json as JSON where json.type ==  SwiftyJSON.Type.array:
            self.init(json.arrayValue.compactMap({ (json) -> Element? in
                return Element(withJson: json)
            }))
        default:
            let jsonObject: JSON!
            if let json = json as? JSON {
                jsonObject = json
            } else {
                jsonObject = JSON(json)
            }
            self.init(jsonObject.compactMap({ (args) -> Element? in
                let (_, jsonObject) = args
                return Element(withJson: jsonObject)
            }))
        }
    }
}

//extension CoreDataStructJSONProtocol {
//    init?(with json: Any?) {
//        guard let json = json else { return nil}
//        if let json = json as? JSON { self.init(withJson: json)}
//        else {
//            self.init(withJson: JSON(json))
//        }
//    }
//}
//
//protocol CoreDataToStructProtocol {
//    associatedtype StructModel: StructToCoreDataProtocol
//    func update(from model: StructModel)
//}
//
//extension CoreDataToStructProtocol {
//    func save(completion: ((Bool) -> ())? = nil) {
//        if let managedObject = self as? NSManagedObject {
//            CoreDataManager.shared.save(managedObject, completion: completion)
//        }
//    }
//}

protocol StructToCoreDataProtocol {
//    associatedtype CoreDataModel: NSManagedObject, CoreDataToStructProtocol
    associatedtype CoreDataModel: NSManagedObject
    init?(_ coreDataObject: CoreDataModel)
    func toCoreDataModel(in context: NSManagedObjectContext?) -> CoreDataModel?
}

//extension StructToCoreDataProtocol {
//    static func find(
//        with predicate: NSPredicate? = nil,
//        in context: NSManagedObjectContext? = nil,
//        sortedBy sort: String? = nil,
//        ascending: Bool = true) -> [Self] {
//        return SMManager.find(withPredicate: predicate, in: context, sortedBy: sort, ascending: ascending)
//    }
//
//    static func find(
//        byAttribute attribute: String,
//        withValue value: Any,
//        in context: NSManagedObjectContext? = nil,
//        sortedBy sort: String? = nil,
//        ascending: Bool = true) -> [Self] {
//        return SMManager.find(byAttribute: attribute, withValue: value, in: context, sortedBy: sort, ascending: ascending)
//    }
//
//    static func findFirst(
//        withPredicate predicate: NSPredicate? = nil,
//        in context: NSManagedObjectContext? = nil) -> Self? {
//        return SMManager.findFirst(withPredicate: predicate, in: context)
//    }
//
//    static func findFirst(
//        byAttribute attribute: String,
//        withValue value: Any,
//        in context: NSManagedObjectContext? = nil) -> Self? {
//        return SMManager.findFirst(byAttribute: attribute, withValue: value, in: context)
//    }
//
//    static func findFirstOrCreate(
//        byAttribute attribute: String,
//        withValue value: Any,
//        in context: NSManagedObjectContext? = nil) -> Self? {
//        return SMManager.findFirstOrCreate(byAttribute: attribute, withValue: value, in: context)
//    }
//
//    func save(in context: NSManagedObjectContext? = nil, completion: ((Bool) -> ())? = nil) {
//        SMManager.save(self, in: context, completion: completion)
//    }
//
//    func delete(in context: NSManagedObjectContext? = nil) {
//        SMManager.delete(self, in: context)
//    }
//
//    //MARK: Utils
//    static func numberOfEntities(withPredicate predicate: NSPredicate? = nil,
//                                 in context: NSManagedObjectContext? = nil) -> Int {
//        return SMManager.numberOfEntities(Self.self, withPredicate: predicate, in: context)
//    }
//}

extension Array where Element: StructToCoreDataProtocol {
    func save(deleteFirst: Bool = false, in context: NSManagedObjectContext? = nil, completion: (() -> ())? = nil) {
        if deleteFirst {
            CoreDataManager.shared.truncateAll(Element.CoreDataModel.self)
        }
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        
        let finishBlock = BlockOperation {
            completion?()
        }
        
//        self.forEach {
//            let operation = ForEachSaveStructCoreDataOperation(object: $0)
//            finishBlock.addDependency(operation)
//            operationQueue.addOperation(operation)
//        }
        operationQueue.addOperation(finishBlock)
    }
    
    func save(deleteFirstWithPredicate predicate: NSPredicate, in context: NSManagedObjectContext? = nil, completion: (() -> ())? = nil) {
        
        CoreDataManager.shared.deleteAll(Element.CoreDataModel.self, with: predicate, in: context)
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        
        let finishBlock = BlockOperation {
            completion?()
        }
        
//        self.forEach {
//            let operation = ForEachSaveStructCoreDataOperation(object: $0)
//            finishBlock.addDependency(operation)
//            operationQueue.addOperation(operation)
//        }
        operationQueue.addOperation(finishBlock)
    }
}
