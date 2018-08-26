//
//  PreprocessingCountryList.swift
//  MyWeatherApp
//
//  Created by Lan on 31/07/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import Foundation

class PreprocessingCountryList {
    // Main
    func loadJson() {
        guard let json: JSON = self.countryListJSON else {
            print("loadJson not ok")
            return
        }
        let context = CoreDataApplicationContext.rootSaveContext
        let _: [Country] = Country.managedCollection(JSON: json, withContext: context)
    }
    
    // MARK: Helper
    fileprivate var countryListJSON: JSON? {
        guard let path = Bundle.main.path(forResource: "CountryList", ofType: "json"),
            let string = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else {
                return nil
        }
        let json = JSON(parseJSON: string)
        return json
    }
}
