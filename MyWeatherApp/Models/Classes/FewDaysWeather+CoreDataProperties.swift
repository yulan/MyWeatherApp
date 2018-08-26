//
//  FewDaysWeather+CoreDataProperties.swift
//  
//
//  Created by Lan on 22/08/2018.
//
//

import Foundation
import CoreData


extension FewDaysWeather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FewDaysWeather> {
        return NSFetchRequest<FewDaysWeather>(entityName: "FewDaysWeather")
    }

    @NSManaged public var cnt: NSNumber
    @NSManaged public var code: NSNumber
    @NSManaged public var message: Double
    @NSManaged public var weatherList: NSSet?
    @NSManaged public var city: City

}

// MARK: Generated accessors for weatherInfoDetail
extension FewDaysWeather {

    @objc(addWeatherInfoDetailObject:)
    @NSManaged public func addToWeatherInfoDetail(_ value: OneDayWeatherInfo)

    @objc(removeWeatherInfoDetailObject:)
    @NSManaged public func removeFromWeatherInfoDetail(_ value: OneDayWeatherInfo)

    @objc(addWeatherInfoDetail:)
    @NSManaged public func addToWeatherInfoDetail(_ values: NSSet)

    @objc(removeWeatherInfoDetail:)
    @NSManaged public func removeFromWeatherInfoDetail(_ values: NSSet)

}

extension FewDaysWeather: ResponseManagedObjectSerializable {
    
    static func managedObject(JSON json: Any, withContext context: NSManagedObjectContext) -> FewDaysWeather {
        
        let jsonObject: JSON = JSON(json)
        let cite = City.managedObject(JSON: jsonObject["city"], withContext: context)
        var fewDaysWeather: FewDaysWeather
        if let fewDaysWeatherLocal = FewDaysWeather.mr_findFirst(byAttribute: "city", withValue: cite, in: context) {
            fewDaysWeather = fewDaysWeatherLocal
        } else {
            fewDaysWeather = FewDaysWeather.mr_createEntity(in: context)!
        }
        context.performAndWait {
            fewDaysWeather.city = cite
            
            fewDaysWeather.cnt = NSNumber(value:jsonObject["cnt"].intValue)
            fewDaysWeather.message = jsonObject["message"].doubleValue
            fewDaysWeather.code = NSNumber(value:jsonObject["cod"].intValue)
            
            let oneDayWeatherInfo = OneDayWeatherInfo.managedCollection(JSON: jsonObject["list"].object, withidentifier: jsonObject["city"], withContext: context)
            fewDaysWeather.weatherList = NSSet(array: oneDayWeatherInfo)
        }
        
        context.mr_saveToPersistentStoreAndWait()
        
        return fewDaysWeather
    }
}

