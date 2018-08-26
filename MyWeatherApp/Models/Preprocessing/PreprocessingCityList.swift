//
//  PreprocessingCityList.swift
//  MyWeatherApp
//
//  Created by Lan on 25/07/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import Foundation

class PreprocessingCityList {
    // Main
    func loadJson() {
        guard let json: JSON = self.cityListJSON else {
            print("loadJson not ok")
            return
        }
        let context = CoreDataApplicationContext.rootSaveContext
        let _: [City] = City.managedCollection(JSON: json, withContext: context)
    }
    
    // MARK: Helper
    fileprivate var cityListJSON: JSON? {
        guard let path = Bundle.main.path(forResource: "CityList1", ofType: "json"),
            let string = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else {
                return nil
        }
        let json = JSON(parseJSON: string)
        return json
    }
}
