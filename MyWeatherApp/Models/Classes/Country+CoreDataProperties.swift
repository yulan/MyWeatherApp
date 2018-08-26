//
//  Country+CoreDataProperties.swift
//  
//
//  Created by Lan on 31/07/2018.
//
//

import Foundation
import CoreData

extension Country {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Country> {
        return NSFetchRequest<Country>(entityName: "Country")
    }

    @NSManaged public var name: String?
    @NSManaged public var code: String?

}

extension Country: ResponseManagedObjectSerializable {
    
    static func managedObject(JSON json: Any, withContext context: NSManagedObjectContext) -> Country {
        
        let jsonObject: JSON = JSON(json)
        let code = jsonObject["code"].stringValue
        
        var country: Country
        if let countryLocal = Country.mr_findFirst(byAttribute: "code", withValue: code, in: context) {
            country = countryLocal
        } else {
            country = Country.mr_createEntity(in: context)!
        }
        
        context.performAndWait {
            country.code = code
            country.name = jsonObject["name"].string
        }
        
        context.mr_saveToPersistentStoreAndWait()
        
        return country
    }
}

extension Country: ResponseManagedCollectionSerializable {
    
    static func managedCollection(JSON json: Any, withContext context: NSManagedObjectContext) -> [Country] {
        var countries: [Country] = []
        let json: JSON = JSON(json)
        
        for (_, countryJSON) in json {
            countries.append(Country.managedObject(JSON: countryJSON.object, withContext: context))
        }
        
        return countries
    }
}
