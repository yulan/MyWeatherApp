//
//  City+CoreDataProperties.swift
//  
//
//  Created by Lan on 25/07/2018.
//
//

import Foundation

extension City {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<City> {
        return NSFetchRequest<City>(entityName: "City")
    }

    @NSManaged public var id: NSNumber
    @NSManaged public var name: String?
    @NSManaged public var country: String?
    @NSManaged public var cityCoord: CurrentCityCoord?

}

extension City: ResponseManagedObjectSerializable {
    
    static func managedObject(JSON json: Any, withContext context: NSManagedObjectContext) -> City {
        
        let jsonObject: JSON = JSON(json)
        let id = NSNumber(value: jsonObject["id"].intValue)
        
        var city: City
        if let cityLocal = City.mr_findFirst(byAttribute: "id", withValue: id, in: context) {
            city = cityLocal
        } else {
            city = City.mr_createEntity(in: context)!
        }
        
        context.performAndWait {
            city.id = id
            city.name = jsonObject["name"].string
            city.country = jsonObject["country"].string
            city.cityCoord = CurrentCityCoord.managedObject(JSON: jsonObject["coord"].object, withContext: context)
        }
        
        context.mr_saveToPersistentStoreAndWait()
        
        return city
    }
}

extension City: ResponseManagedCollectionSerializable {
    
    static func managedCollection(JSON json: Any, withContext context: NSManagedObjectContext) -> [City] {
        var cities: [City] = []
        let json: JSON = JSON(json)
        
        for (_, cityJSON) in json {
            cities.append(City.managedObject(JSON: cityJSON.object, withContext: context))
        }
        
        return cities
    }
}

