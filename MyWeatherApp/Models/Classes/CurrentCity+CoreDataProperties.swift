//
//  CurrentCity+CoreDataProperties.swift
//  
//
//  Created by Lan on 16/07/2018.
//
//

import Foundation

extension CurrentCity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrentCity> {
        return NSFetchRequest<CurrentCity>(entityName: "CurrentCity")
    }

    @NSManaged public var base: String?
    @NSManaged public var clouds: NSNumber?
    @NSManaged public var rain: NSNumber?
    @NSManaged public var snow: NSNumber?
    @NSManaged public var date: Date?
    @NSManaged public var id: NSNumber
    @NSManaged public var name: String?
    @NSManaged public var cod: NSNumber?
    @NSManaged public var currentCityCoord: CurrentCityCoord?
    @NSManaged public var currentCityMain: CurrentCityMain?
    @NSManaged public var currentCitySys: CurrentCitySys?
    @NSManaged public var currentCityWeatherInfo: CurrentCityWeatherInfo?
    @NSManaged public var currentCityWind: CurrentCityWind?
    
}

extension CurrentCity: ResponseManagedObjectSerializable {
    public static func managedObject(JSON json: Any, withContext context: NSManagedObjectContext) -> CurrentCity {
        let jsonObject: JSON = JSON(json)

        let id = NSNumber(value: jsonObject["id"].intValue)

        var currentCity: CurrentCity
        if let currentCityLocal = CurrentCity.mr_findFirst(byAttribute: "id", withValue: id, in: context) {
            currentCity = currentCityLocal
        } else {
            currentCity = CurrentCity.mr_createEntity(in: context)!
        }
        context.performAndWait {
            currentCity.id = id
            currentCity.base = jsonObject["base"].string
            if let clouds = jsonObject["clouds"]["all"].double {
                currentCity.clouds = NSNumber(value: clouds)
            }
            if let cod = jsonObject["cod"].int {
                currentCity.cod = NSNumber(value: cod)
            }
            if let rain = jsonObject["rain"].double {
                currentCity.rain = NSNumber(value: rain)
            }
            if let snow = jsonObject["snow"].double {
                currentCity.snow = NSNumber(value: snow)
            }
            currentCity.date = Date(timeIntervalSince1970: jsonObject["dt"].doubleValue)
            currentCity.name = jsonObject["name"].string
            currentCity.currentCityCoord = CurrentCityCoord.managedObject(JSON: jsonObject["coord"].object, withContext: context)
            currentCity.currentCityMain = CurrentCityMain.managedObject(JSON: jsonObject["main"].object, withContext: context)
            currentCity.currentCitySys = CurrentCitySys.managedObject(JSON: jsonObject["sys"].object, withContext: context)
            currentCity.currentCityWind = CurrentCityWind.managedObject(JSON: jsonObject["wind"].object, withContext: context)
        }
        
        context.mr_saveToPersistentStoreAndWait()

        return currentCity
    }
}
