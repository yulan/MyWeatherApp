//
//  Dictionary+Additions.swift
//  MyWeatherApp
//
//  Created by Lan on 24/07/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import Foundation

extension Dictionary {
    
    /// Generate a query from a dictonary.
    ///
    /// Example: ["name": "Bob", "isUser": false] will return "name=Bob&isUser=false".
    ///
    /// The keys have to be of type `String`, and the values have to be of type `String`, `Numeric` and `Bool`. If other keys/values types are found, the query is `nil`.
    /// Keys and values are not escaped nor URL encoded.
    public var query: String? {
        if self.contains(where: { key, value in !(key is String) || !(value is String || value is Numeric || value is Bool) }) {
            return nil
        }
        
        return self
            .map { key, value in "\(String(describing: key).escaped)=\(String(describing: value).escaped)" }
            .joined(separator: "&")
    }
}

extension Dictionary where Key == String, Value == Any {
    
    /// Generate a dictionary from a query.
    ///
    /// Example: "user=bob&age=42" will create a dictionary which contains ["user": "bob", "age": "42"]
    ///
    /// Note: All the query value are evaluated as `String`.
    init?(withQuery query: String) {
        guard query.contains("=") else { return nil }
        
        self = Dictionary<String, Any>()
        
        let parametersArray = query.split(separator: "&")
        
        for parameter in parametersArray {
            let keyValueArray = parameter.split(separator: "=")
            
            guard keyValueArray.count == 2 else { return nil }
            
            let key = String(keyValueArray[0])
            let value = String(keyValueArray[1])
            
            self[key] = value
        }
        
        if parametersArray.count != self.count { return nil }
    }
}

/// Compare two dictionaries to check if they are equals.
///
/// - Parameters:
///   - lhs: First dictionary
///   - rhs: Second dictionary
/// - Returns: `true` if the dictionaries have the same content, else `false`.
public func ==(lhs: [AnyHashable: Any], rhs: [AnyHashable: Any] ) -> Bool {
    return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}

/// Compare two dictionaries to check if they are not equals.
///
/// - Parameters:
///   - lhs: First dictionary
///   - rhs: Second dictionary
/// - Returns: `true` if the dictionaries don't have the same content, else `false`.
public func !=(lhs: [AnyHashable: Any], rhs: [AnyHashable: Any] ) -> Bool {
    return !(lhs == rhs)
}
