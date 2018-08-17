//
//  DBInterface.swift
//  DatabaseInterface
//
//  Created by Duy Pham Viet on 2018/08/14.
//  Copyright © 2018 Duy Pham Viet. All rights reserved.
//


/*
 Yeu cau:
 1) tao ra query voi dinh dang rieng, tu query nay tao ra query tuong ung cho tung loai csdl.
 vd: user sai sqlite, co query joint cac bang -> khi chuyen qua realm, query nay van sai dc
 2)
 */
import Foundation

enum DBType : Int {
    case SQLite = 0, Realm, CoreData
}

public protocol DBProtocol : NSObjectProtocol {
    
    static func createTable(fromModel:BaseObject.Type)->Bool
    
    static func deleteTable(name: String)->Bool
    
    static func insertObjs(array:[BaseObject])->Bool
    
    static func updateObjs(array:[BaseObject])->Bool
    
    static func deleteObjs(array:[BaseObject])->Bool
    
    static func fetchObjs<T:BaseObject>(condition: String) -> [T]
}

public class IDatabase {
    //MARK: - PROPERTIES
    
    //database type will be used in application
    static var db : DBProtocol.Type!
    
    //current version of database
    static var curVer: UInt64 = 0
    
    //database's name
    static var dbFileName = "Database"
    
    //when have migration, this function is call to migration
    static var migrationAction : (()->Void)?
    
    //MARK: - FUNCTIONS
    //Table
    public class func createTable(fromModel:BaseObject.Type)->Bool{
        return db.createTable(fromModel: fromModel)
    }
    
    public class func deleteTable(name:String)->Bool{
        return db.deleteTable(name: name)
    }
    
    //NonQuery
    public class func insertObjs(array:[BaseObject])->Bool{
        return db.insertObjs(array: array)
    }
    
    public class func updateObjs(array:[BaseObject])->Bool{
        return db.updateObjs(array: array)
    }
    
    public class func deleteObjs(array:[BaseObject])->Bool{
        return db.deleteObjs(array: array)
    }
    
    //Query
    public class func fetchObjs<T:BaseObject>(condition:String)->[T]{
        return db.fetchObjs(condition: condition)
    }
}


