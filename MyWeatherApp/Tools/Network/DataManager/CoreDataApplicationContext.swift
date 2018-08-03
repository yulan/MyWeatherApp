//
//  CoreDataContextManager.swift
//  MyWeatherApp
//
//  Created by Lan on 23/07/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import Foundation

struct CoreDataApplicationContext {
    
    static let rootFetchContext: NSManagedObjectContext = NSManagedObjectContext.mr_default()
    static let rootSaveContext: NSManagedObjectContext = NSManagedObjectContext.mr_rootSaving()
}
