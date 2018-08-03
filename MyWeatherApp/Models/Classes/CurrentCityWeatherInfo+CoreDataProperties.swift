//
//  CurrentCityWeatherInfo+CoreDataProperties.swift
//  
//
//  Created by Lan on 16/07/2018.
//
//

import Foundation

extension CurrentCityWeatherInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrentCityWeatherInfo> {
        return NSFetchRequest<CurrentCityWeatherInfo>(entityName: "CurrentCityWeatherInfo")
    }

    @NSManaged public var id: NSNumber
    @NSManaged public var main: String?
    @NSManaged public var discription: String?
    @NSManaged public var icon: String?
    @NSManaged public var currentCity: CurrentCity?

}

extension CurrentCityWeatherInfo: ResponseManagedObjectSerializable {
    
    static func managedObject(JSON json: Any, withContext context: NSManagedObjectContext) -> CurrentCityWeatherInfo {
        
        let jsonObject: JSON = JSON(json)
        
        let id = NSNumber(value: jsonObject["id"].intValue)
        
        var currentCityWeatherInfo: CurrentCityWeatherInfo
        if let currentCityWeatherInfoLocal = CurrentCityWeatherInfo.mr_findFirst(byAttribute: "id", withValue: id, in: context) {
            currentCityWeatherInfo = currentCityWeatherInfoLocal
        } else {
            currentCityWeatherInfo = CurrentCityWeatherInfo.mr_createEntity(in: context)!
        }
        
        context.performAndWait {
            currentCityWeatherInfo.id = id
            currentCityWeatherInfo.main = jsonObject["main"].stringValue
            currentCityWeatherInfo.discription = jsonObject["description"].stringValue
            currentCityWeatherInfo.icon = jsonObject["icon"].stringValue
        }
        
        context.mr_saveToPersistentStoreAndWait()
        
        return currentCityWeatherInfo
    }
}
