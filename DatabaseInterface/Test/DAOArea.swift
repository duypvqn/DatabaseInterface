//
//  DAOArea.swift
//  Nichiren
//
//  Created by Duy Pham Viet on 2017/12/15.
//  Copyright © 2017 Duy Pham Viet. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift

class DAOArea: BaseObject {
    static let kAreaId = "areaId"
    static let kAreaName = "areaName"
    static let kIsActivated = "isActivated"
    
    @objc dynamic var areaId = ""
    @objc dynamic var areaName = ""
    @objc dynamic var isActivated = 1
    
    override static func primaryKey()->String?{
        return DAOArea.kAreaId
    }
    
    public override func uniqueKeys()->[String]?{
        return [DAOArea.kAreaId]
    }
    
    public override func tableName() -> String {
        return DAOArea.tableName()
    }
    
    public override class func tableName() -> String {
        return "Area"
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        areaId <- map["areaId"]
        areaName <- map["areaName"]
        isActivated <- map["isActivated"]
    }
}

