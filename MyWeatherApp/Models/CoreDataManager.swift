//
//  CoreDataManager.swift
//  MyWeatherApp
//
//  Created by Lan on 16/07/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import Foundation
import MagicalRecord

//MARK: - NSManagedObject
struct CoreDataManager {
    
    static var shared: CoreDataManager = CoreDataManager()
    
    var defaultContext: NSManagedObjectContext = NSManagedObjectContext.mr_rootSaving()
    
    //MARK: Find
    func find<T: NSManagedObject>(
        withPredicate predicate: NSPredicate? = nil,
        in context: NSManagedObjectContext? = nil,
        sortedBy sort: String? = nil,
        ascending: Bool = true) -> [T] {
        
        let contextNoNil = context ?? CoreDataManager.shared.defaultContext
        
        //Sorted
        if let sort = sort {
            return T.mr_findAllSorted(by: sort, ascending: ascending, with: predicate, in: contextNoNil) as? [T] ?? []
        }
        
        //No Sorted
        return T.mr_findAll(with: predicate, in: contextNoNil) as? [T] ?? []
    }
    
    func find<T: NSManagedObject>(
        byAttribute attribute: String,
        withValue value: Any,
        in context: NSManagedObjectContext? = nil,
        sortedBy sort: String? = nil,
        ascending: Bool = true) -> [T] {
        
        let contextNoNil = context ?? CoreDataManager.shared.defaultContext
        
        //Sorted
        if let sort = sort {
            return T.mr_find(byAttribute: attribute, withValue: value, andOrderBy: sort, ascending: ascending, in: contextNoNil) as? [T] ?? []
        }
        
        //No Sorted
        return T.mr_find(byAttribute: attribute, withValue: value, in: contextNoNil) as? [T] ?? []
    }
    
    func findFirst<T: NSManagedObject>(
        withPredicate predicate: NSPredicate? = nil,
        in context: NSManagedObjectContext? = nil) -> T? {
        
        let contextNoNil = context ?? CoreDataManager.shared.defaultContext
        
        return T.mr_findFirst(with: predicate, in: contextNoNil)
    }
    
    func findFirst<T: NSManagedObject>(
        byAttribute attribute: String,
        withValue value: Any,
        in context: NSManagedObjectContext? = nil) -> T? {
        
        let contextNoNil = context ?? CoreDataManager.shared.defaultContext
        
        return T.mr_findFirst(byAttribute: attribute, withValue: value, in: contextNoNil)
    }
    
    func findFirstOrCreate<T: NSManagedObject>(
        byAttribute attribute: String,
        withValue value: Any,
        in context: NSManagedObjectContext? = nil) -> T? {
        
        let contextNoNil = context ?? CoreDataManager.shared.defaultContext
        return T.mr_findFirstOrCreate(byAttribute: attribute, withValue: value, in: contextNoNil)
    }
    
    func findFirstOrCreate<T: NSManagedObject>(
        withPredicate predicate: NSPredicate? = nil,
        in context: NSManagedObjectContext? = nil) -> T? {
        
        let contextNoNil = context ?? CoreDataManager.shared.defaultContext
        return self.findFirst(withPredicate: predicate, in: contextNoNil) ?? self.create(in: contextNoNil)
    }
    
    func findFirstOrCreate<T: NSManagedObject>(in context: NSManagedObjectContext? = nil) -> T? {
        
        let contextNoNil = context ?? CoreDataManager.shared.defaultContext
        
        return self.findFirst(in: contextNoNil) ?? self.create(in: contextNoNil)
    }
    
    //MARK: Create
    func create<T: NSManagedObject>(in context: NSManagedObjectContext? = nil) -> T? {
        let contextNoNil = context ?? CoreDataManager.shared.defaultContext
        let object = T.mr_createEntity(in: contextNoNil)
        return object
    }
    
    //MARK: Save
    func save<T: NSManagedObject>(_ object: T?, completion: ((Bool) -> ())?) {
        if let completion = completion {
            object?.managedObjectContext?.mr_saveToPersistentStore(completion: { (success, _) in
                completion(success)
            })
        } else {
            object?.managedObjectContext?.mr_saveToPersistentStoreAndWait()
        }
    }
    
    //MARK: Truncate & Delete
    func truncateAll<T: NSManagedObject>(_ type: T.Type,
                                         in context: NSManagedObjectContext? = nil) {
        let contextNoNil = context ?? CoreDataManager.shared.defaultContext
        type.mr_truncateAll(in: contextNoNil)
        contextNoNil.mr_saveToPersistentStoreAndWait()
    }
    
    func deleteAll<T: NSManagedObject>(_ type: T.Type,
                                              with predicate: NSPredicate,
                                                in context: NSManagedObjectContext? = nil) {
        let contextNoNil = context ?? CoreDataManager.shared.defaultContext
        type.mr_deleteAll(matching: predicate, in: contextNoNil)
        contextNoNil.mr_saveToPersistentStoreAndWait()
    }
    
    func delete<T: NSManagedObject>(_ object: T, in context: NSManagedObjectContext? = nil) {
        let contextNoNil = context ?? CoreDataManager.shared.defaultContext
        object.mr_deleteEntity(in: contextNoNil)
        contextNoNil.mr_saveToPersistentStoreAndWait()
    }
    
    func delete<T: NSManagedObject>(
        _ type: T.Type,
        withPredicate predicate: NSPredicate? = nil,
        in context: NSManagedObjectContext? = nil) {
        
        let contextNoNil = context ?? CoreDataManager.shared.defaultContext
        
        let objectsToDelete: [T] = CoreDataManager.shared.find(withPredicate: predicate, in: contextNoNil)
        
        objectsToDelete.forEach { $0.mr_deleteEntity(in: contextNoNil) }
        contextNoNil.mr_saveToPersistentStoreAndWait()
    }
    
    func delete<T: NSManagedObject>(
        _ type: T.Type,
        byAttribute attribute: String,
        withValue value: Any,
        in context: NSManagedObjectContext? = nil) {
        
        let contextNoNil = context ?? CoreDataManager.shared.defaultContext
        
        let objectsToDelete: [T] = CoreDataManager.shared.find(byAttribute: attribute, withValue: value, in: contextNoNil)
        
        objectsToDelete.forEach { $0.mr_deleteEntity(in: contextNoNil) }
        contextNoNil.mr_saveToPersistentStoreAndWait()
    }
    
    //MARK: Utils
    func numberOfEntities<T: NSManagedObject>(_ type: T.Type,
                                                     withPredicate predicate: NSPredicate? = nil,
                                                     in context: NSManagedObjectContext? = nil) -> Int {
        let contextNoNil = context ?? CoreDataManager.shared.defaultContext
        return T.mr_numberOfEntities(with: predicate, in: contextNoNil).intValue
    }
}

