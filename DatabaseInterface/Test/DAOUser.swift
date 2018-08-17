//
//  DAOUser.swift
//  DatabaseInterface
//
//  Created by Duy Pham Viet on 2018/08/17.
//  Copyright © 2018 Duy Pham Viet. All rights reserved.
//

import UIKit
import ObjectMapper

class DAOUser: BaseObject {
    static let kUserId = "userId"
    
    @objc dynamic var userId = ""
    @objc dynamic var userName = ""
    @objc dynamic var lat : CGFloat = 35.6451572
    @objc dynamic var lon : CGFloat = 139.7122242
    
    override static func primaryKey()->String?{
        return DAOUser.kUserId
    }
    
    public override func uniqueKeys()->[String]?{
        return [DAOUser.kUserId]
    }
    
    public override func tableName() -> String {
        return DAOUser.tableName()
    }
    
    public override class func tableName() -> String {
        return "User"
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        userId <- map["userId"]
        userName <- map["userName"]
        lat <- map["lat"]
        lon <- map["lon"]
    }
}
