//
//  Model.swift
//  MobileNativeMeeting
//
//  Created by Panupong.k on 15/10/24.
//

import ObjectMapper

struct MobileNativeMeeting2: Mappable {
    var helloWorld0: String?
    var helloWorld1: Int?
    var helloWorld2: Double?
    var helloWorld3: [String]?
    
    init?(map: ObjectMapper.Map) {}
    
    mutating func mapping(map: Map) {
        helloWorld0 <- map[Key.helloWorld0]
        helloWorld1 <- map[Key.helloWorld1]
        helloWorld2 <- map[Key.helloWorld2]
        helloWorld3 <- map[Key.helloWorld3]
    }
    
    private enum Key {
        static let helloWorld0 = "helloWorld0"
        static let helloWorld1 = "helloWorld1"
        static let helloWorld2 = "helloWorld2"
        static let helloWorld3 = "helloWorld3"
    }
}
