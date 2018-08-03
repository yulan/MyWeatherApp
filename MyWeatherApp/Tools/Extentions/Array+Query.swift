//
//  Array+Additions.swift
//  MyWeatherApp
//
//  Created by Lan on 24/07/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import Foundation

extension Array {
    
    /// Generate a query from a array.
    ///
    /// Example: ["user", "bob"] will return "user/bob".
    ///
    /// Only the `String`, `Numeric` and `Bool` values are managed. If other types are found, the query is `nil`.
    /// Values are not escaped nor URL encoded.
    internal var query: String? {
        if self.contains(where: { !($0 is String) && !($0 is Numeric) && !($0 is Bool) }) {
            return nil
        }
        
        return self
            .map { return String(describing: $0).escaped }
            .joined(separator: "/")
    }
}
