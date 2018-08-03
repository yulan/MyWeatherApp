//
//  Alamofire+CoreDataSerializable.swift
//  MyWeatherApp
//
//  Created by Lan on 16/07/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import Foundation

public protocol ResponseManagedObjectSerializable: class {
    static func managedObject(JSON: Any, withContext: NSManagedObjectContext) -> Self
}

public protocol ResponseManagedCollectionSerializable: class {
    static func managedCollection(JSON: Any, withContext: NSManagedObjectContext) -> [Self]
}
