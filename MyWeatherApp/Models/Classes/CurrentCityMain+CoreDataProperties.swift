//
//  CurrentCityMain+CoreDataProperties.swift
//  
//
//  Created by Lan on 16/07/2018.
//
//

import Foundation

extension CurrentCityMain {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrentCityMain> {
        return NSFetchRequest<CurrentCityMain>(entityName: "CurrentCityMain")
    }

    @NSManaged public var temp: NSNumber
    @NSManaged public var pressure: NSNumber
    @NSManaged public var humidity: NSNumber
    @NSManaged public var tempMin: NSNumber
    @NSManaged public var tempMax: NSNumber
    @NSManaged public var seaLevel: NSNumber
    @NSManaged public var grndLevel: NSNumber
    @NSManaged public var currentCity: CurrentCity?

}

extension CurrentCityMain: ResponseManagedObjectSerializable {
    
    static func managedObject(JSON json: Any, withContext context: NSManagedObjectContext) -> CurrentCityMain {
        
        let jsonObject: JSON = JSON(json)
        let currentCityMain: CurrentCityMain = CurrentCityMain.mr_createEntity(in: context)!
        
        context.performAndWait {
            currentCityMain.temp = NSNumber(value: jsonObject["temp"].doubleValue)
            currentCityMain.pressure = NSNumber(value:jsonObject["pressure"].doubleValue)
            currentCityMain.humidity = NSNumber(value:jsonObject["humidity"].doubleValue)
            currentCityMain.tempMin = NSNumber(value:jsonObject["tempMin"].doubleValue)
            currentCityMain.tempMax = NSNumber(value:jsonObject["tempMax"].doubleValue)
            currentCityMain.seaLevel = NSNumber(value:jsonObject["seaLevel"].doubleValue)
            currentCityMain.grndLevel = NSNumber(value:jsonObject["grndLevel"].doubleValue)
        }
        
        context.mr_saveToPersistentStoreAndWait()
        
        return currentCityMain
    }
}
