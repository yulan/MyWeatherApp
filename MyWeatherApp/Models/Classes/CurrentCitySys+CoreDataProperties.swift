//
//  CurrentCitySys+CoreDataProperties.swift
//  
//
//  Created by Lan on 16/07/2018.
//
//

import Foundation

extension CurrentCitySys {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrentCitySys> {
        return NSFetchRequest<CurrentCitySys>(entityName: "CurrentCitySys")
    }

    @NSManaged public var type: NSNumber
    @NSManaged public var id: NSNumber
    @NSManaged public var message: Double
    @NSManaged public var country: String?
    @NSManaged public var sunrise: Date?
    @NSManaged public var sunset: Date?
    @NSManaged public var currentCity: CurrentCity?

}

extension CurrentCitySys: ResponseManagedObjectSerializable {
    
    static func managedObject(JSON json: Any, withContext context: NSManagedObjectContext) -> CurrentCitySys {
        
        let jsonObject: JSON = JSON(json)
        
        let id = NSNumber(value: jsonObject["id"].intValue)
        
        var currentCitySys: CurrentCitySys
        if let currentCitySysLocal = CurrentCitySys.mr_findFirst(byAttribute: "id", withValue: id, in: context) {
            currentCitySys = currentCitySysLocal
        } else {
            currentCitySys = CurrentCitySys.mr_createEntity(in: context)!
        }
    
        context.performAndWait {
            currentCitySys.id = id
            currentCitySys.type = NSNumber(value: jsonObject["type"].intValue)
            currentCitySys.id = NSNumber(value: jsonObject["id"].intValue)
            currentCitySys.message = jsonObject["message"].doubleValue
            currentCitySys.country = jsonObject["country"].stringValue
            currentCitySys.sunrise = Date(timeIntervalSince1970: jsonObject["sunrise"].doubleValue)
            currentCitySys.sunset = Date(timeIntervalSince1970: jsonObject["sunset"].doubleValue)
        }
        
        context.mr_saveToPersistentStoreAndWait()
        
        return currentCitySys
    }
}
