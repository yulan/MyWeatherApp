//
//  CurrentCityWind+CoreDataProperties.swift
//  
//
//  Created by Lan on 16/07/2018.
//
//

import Foundation

extension CurrentCityWind {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrentCityWind> {
        return NSFetchRequest<CurrentCityWind>(entityName: "CurrentCityWind")
    }

    @NSManaged public var degrees: NSNumber?
    @NSManaged public var speed: NSNumber?
    @NSManaged public var currentCity: CurrentCity?

}

extension CurrentCityWind: ResponseManagedObjectSerializable {
    
    static func managedObject(JSON json: Any, withContext context: NSManagedObjectContext) -> CurrentCityWind {
        
        let jsonObject: JSON = JSON(json)
        let currentCityWind: CurrentCityWind = CurrentCityWind.mr_createEntity(in: context)!
        context.performAndWait {
            if let degrees = jsonObject["degrees"].double {
                currentCityWind.degrees = NSNumber(value:degrees)
            }
            
            if let speed = jsonObject["degrees"].double {
                currentCityWind.degrees = NSNumber(value:speed)
            }
        }
        
        context.mr_saveToPersistentStoreAndWait()
        
        return currentCityWind
    }
}
