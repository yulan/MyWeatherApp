//
//  OneDayWeatherInfo+CoreDataProperties.swift
//  
//
//  Created by Lan on 22/08/2018.
//
//

import Foundation
import CoreData


extension OneDayWeatherInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OneDayWeatherInfo> {
        return NSFetchRequest<OneDayWeatherInfo>(entityName: "OneDayWeatherInfo")
    }

    @NSManaged public var dt: String?
    @NSManaged public var dt_txt: String?
    @NSManaged public var clouds: NSNumber?
    @NSManaged public var rain: NSNumber?
    @NSManaged public var snow: NSNumber?
    @NSManaged public var sysPod: String?
    @NSManaged public var oneDayMain: OneDayWeatherMain?
    @NSManaged public var oneDayWeather: NSSet?
    @NSManaged public var oneDayWind: CurrentCityWind?
    @NSManaged public var oneDayDetail: FewDaysWeather?
    @NSManaged public var cityId: NSNumber
}

// MARK: Generated accessors for oneDayWeather
extension OneDayWeatherInfo {

    @objc(addOneDayWeatherObject:)
    @NSManaged public func addToOneDayWeather(_ value: CurrentCityWeatherInfo)

    @objc(removeOneDayWeatherObject:)
    @NSManaged public func removeFromOneDayWeather(_ value: CurrentCityWeatherInfo)

    @objc(addOneDayWeather:)
    @NSManaged public func addToOneDayWeather(_ values: NSSet)

    @objc(removeOneDayWeather:)
    @NSManaged public func removeFromOneDayWeather(_ values: NSSet)

}

extension OneDayWeatherInfo: ResponseManagedObjectWithIdentifierSerializable {
    
    static func managedObject(JSON json: Any, withidentifier identifier: Any, withContext context: NSManagedObjectContext) -> OneDayWeatherInfo {
        
        let jsonObject: JSON = JSON(json)
        let idJsonObject: JSON = JSON(identifier)
        
        let id = NSNumber(value: idJsonObject["id"].intValue)
        
        var oneDayWeatherInfo: OneDayWeatherInfo
        if let oneDayWeatherInfoLocal = OneDayWeatherInfo.mr_findFirst(byAttribute: "cityId", withValue: id, in: context) {
            oneDayWeatherInfo = oneDayWeatherInfoLocal
        } else {
            oneDayWeatherInfo = OneDayWeatherInfo.mr_createEntity(in: context)!
        }
        context.performAndWait {
            oneDayWeatherInfo.cityId = id
            oneDayWeatherInfo.dt = jsonObject["dt"].string
            oneDayWeatherInfo.dt_txt = jsonObject["dt_txt"].string
            if let clouds = jsonObject["clouds"]["all"].double {
                oneDayWeatherInfo.clouds = NSNumber(value: clouds)
            }
            if let rain = jsonObject["rain"].double {
                oneDayWeatherInfo.rain = NSNumber(value: rain)
            }
            if let snow = jsonObject["snow"].double {
                oneDayWeatherInfo.snow = NSNumber(value: snow)
            }
            oneDayWeatherInfo.sysPod = jsonObject["sys"]["pod"].string
            oneDayWeatherInfo.oneDayMain = OneDayWeatherMain.managedObject(JSON: jsonObject["main"].object, withContext: context)
            oneDayWeatherInfo.oneDayWind = CurrentCityWind.managedObject(JSON: jsonObject["wind"].object, withContext: context)
            let currentCityWeatherInfos = CurrentCityWeatherInfo.managedCollection(JSON: jsonObject["weather"].object, withContext: context)
            oneDayWeatherInfo.oneDayWeather = NSSet(array: currentCityWeatherInfos)
        }
        
        context.mr_saveToPersistentStoreAndWait()
        
        return oneDayWeatherInfo
    }
}

extension OneDayWeatherInfo: ResponseManagedCollectionWithIdentifierSerializable {
    
    static func managedCollection(JSON json: Any, withidentifier identifier: Any, withContext context: NSManagedObjectContext) -> [OneDayWeatherInfo] {
        var oneDayWeatherInfos: [OneDayWeatherInfo] = []
        let json: JSON = JSON(json)
        
        for (_, cityJSON) in json {
            oneDayWeatherInfos.append(OneDayWeatherInfo.managedObject(JSON: cityJSON.object, withidentifier: identifier, withContext: context))
        }
        
        return oneDayWeatherInfos
    }
}

