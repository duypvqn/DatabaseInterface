//
//  BaseObject.swift
//  DatabaseInterface
//
//  Created by Duy Pham Viet on 2018/08/14.
//  Copyright © 2018 Duy Pham Viet. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import ObjectMapper

protocol BaseObjectProtocol {
    
}

public class BaseObject : Object, Mappable {
    //MARK: INIT
    @objc dynamic var createDate = ""
    @objc dynamic var modifierDate = ""
    
    required public init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required public init() {
        super.init()
    }
    
    required public init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    required convenience public init?(map: Map) {
        self.init()
    }
    
    public func mapping(map: Map) {
        createDate <- map["createDate"]
        modifierDate <- map["modifierDate"]
    }
    
    public func tableName()->String{
        let thisType = type(of: self)
        return String.init(describing: thisType)
    }
    
    public class func tableName()->String {
        return String.init(describing: self)
    }
    
    public func uniqueKeys()->[String]?{
        return nil
    }
}
