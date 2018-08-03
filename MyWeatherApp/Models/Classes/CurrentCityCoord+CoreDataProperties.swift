//
//  CurrentCityCoord+CoreDataProperties.swift
//  
//
//  Created by Lan on 16/07/2018.
//
//

import Foundation

extension CurrentCityCoord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrentCityCoord> {
        return NSFetchRequest<CurrentCityCoord>(entityName: "CurrentCityCoord")
    }

    @NSManaged public var latitude: NSNumber
    @NSManaged public var longitude: NSNumber
    @NSManaged public var currentCity: CurrentCity?
    @NSManaged public var city: City?
}


extension CurrentCityCoord: ResponseManagedObjectSerializable {
    
    static func managedObject(JSON json: Any, withContext context: NSManagedObjectContext) -> CurrentCityCoord {
        
        let jsonObject: JSON = JSON(json)
        let currentCityCoord: CurrentCityCoord = CurrentCityCoord.mr_createEntity(in: context)!
        context.performAndWait {
            currentCityCoord.latitude =  NSNumber(value:jsonObject["lat"].doubleValue)
            currentCityCoord.longitude =  NSNumber(value:jsonObject["lon"].doubleValue)
        }
        
        return currentCityCoord
    }
}
