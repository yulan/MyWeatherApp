//
//  String+Additions.swift
//  MyWeatherApp
//
//  Created by Lan on 23/07/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import Foundation

extension String {
    
    func base64String() -> String {
        let data: Data! = self.data(using: String.Encoding.utf8)
        return data.base64EncodedString(options: NSData.Base64EncodingOptions())
    }
    
    /**
     Returns a percent-escaped string following RFC 3986 for a query string key or value.
     
     RFC 3986 states that the following characters are "reserved" characters.
     
     - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
     - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
     
     In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
     query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
     should be percent-escaped in the query string.
     
     - parameter string: The string to be percent-escaped.
     
     - returns: The percent-escaped string.
     */
    public var escaped: String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        let allowedCharacterSet = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        allowedCharacterSet.removeCharacters(in: generalDelimitersToEncode + subDelimitersToEncode)
        
        let escaped = self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet) ?? self
        
        return escaped
    }

}
