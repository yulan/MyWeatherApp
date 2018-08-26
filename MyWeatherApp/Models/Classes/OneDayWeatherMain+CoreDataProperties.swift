//
//  OneDayWeatherMain+CoreDataProperties.swift
//  
//
//  Created by Lan on 22/08/2018.
//
//

import Foundation
import CoreData


extension OneDayWeatherMain {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OneDayWeatherMain> {
        return NSFetchRequest<OneDayWeatherMain>(entityName: "OneDayWeatherMain")
    }

    @NSManaged public var temp: Double
    @NSManaged public var tempMin: Double
    @NSManaged public var tempMax: Double
    @NSManaged public var pressure: Double
    @NSManaged public var seaLevel: Double
    @NSManaged public var granLevel: Double
    @NSManaged public var humidity: Double
    @NSManaged public var tempKF: Double
    @NSManaged public var main: OneDayWeatherInfo?

}

extension OneDayWeatherMain: ResponseManagedObjectSerializable {
    
    static func managedObject(JSON json: Any, withContext context: NSManagedObjectContext) -> OneDayWeatherMain {
        
        let jsonObject: JSON = JSON(json)
        let main: OneDayWeatherMain = OneDayWeatherMain.mr_createEntity(in: context)!
        context.performAndWait {
            main.temp = jsonObject["temp"].doubleValue
            main.tempMin = jsonObject["temp_min"].doubleValue
            main.tempMax = jsonObject["temp_max"].doubleValue
            main.pressure = jsonObject["pressure"].doubleValue
            main.seaLevel = jsonObject["sea_level"].doubleValue
            main.humidity =  jsonObject["humidity"].doubleValue
            main.tempKF = jsonObject["temp_kf"].doubleValue
        }
        
        return main
    }
}

