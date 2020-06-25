//
//  NSObjectExtension.swift
//  Test
//
//  Created by Techchain on 6/25/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import Foundation

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    static var id: String {
        return String(describing: self)
    }
    
    static func getProperties<T: NSObject>(type: T.Type) -> [String] {
        var count = UInt32()
        let classToInspect = T.self
        let properties : UnsafeMutablePointer <objc_property_t> = class_copyPropertyList(classToInspect, &count)!
        var propertyNames = [String]()
        let intCount = Int(count)
        for i in 0..<intCount {
            let property : objc_property_t = properties[i]
            guard let propertyName = NSString(utf8String: property_getName(property)) as String? else {
                debugPrint("Couldn't unwrap property name for \(property)")
                break
            }

            propertyNames.append(propertyName)
        }
        return propertyNames
    }
}
