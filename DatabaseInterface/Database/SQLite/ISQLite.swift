//
//  SQLiteInterface.swift
//  DatabaseInterface
//
//  Created by Duy Pham Viet on 2018/08/14.
//  Copyright © 2018 Duy Pham Viet. All rights reserved.
//

import Foundation
import ObjectMapper
import FMDB
import SQLite

class ISQLiteConstant {
    struct Query {
        static let AlertTable = "ALTER TABLE %@ ADD COLUMN %@ %@"
        static let DropAndCreateTable = "DROP TABLE IF EXISTS %@; CREATE TABLE %@ (%@);"
        static let CreateTable = "CREATE TABLE IF NOT EXISTS %@ (%@)"
        static let DropTable = "DROP TABLE IF EXISTS %@"
        static let Update = "REPLACE INTO %@ (%@) VALUES (%@)"
        static let SelectAll = "SELECT * FROM %@"
        static let SelectWhere = "SELECT * FROM %@ WHERE %@"
        static let Select = "SELECT %@ FROM %@ WHERE %@"
        static let Join = "inner join %@ on %@.%@=%@.%@"
        static let Exist = "SELECT EXISTS (SELECT 1 FROM %@ WHERE %@ LIMIT 1)"
        static let Unique = "UNIQUE (%@)"
        static let DeleteWhere = "DELETE FROM %@ WHERE %@"
    }
    
    struct DBValueType {
        //type in db
        static let Text = "TEXT"
        static let Int = "INTEGER"
        static let Unique = "UNIQUE"
        static let NotNullDefaultValue = "NOT NULL DEFAULT %@"
    }
}

class ISQLite : NSObject, DBProtocol {
    static func createTable(fromModel type:BaseObject.Type)->Bool{
        debugPrint("ISQLite: \(type)")
        let columnDefine = columnsDefine(fromModel: type)
        let tableName = type.init().tableName()
        let query = String(format: ISQLiteConstant.Query.CreateTable, tableName, columnDefine)
        if excuteUpdate(query: query) {
            debugPrint("create table \(tableName) success")
            return true
        }
        else{
            debugPrint("create table \(tableName) fail")
            return false
        }
    }
    
    static func deleteTable(name: String)->Bool {
        debugPrint("ISQLite: \(name)")
        let query = String(format:ISQLiteConstant.Query.DropTable, name)
        if excuteUpdate(query: query){
            debugPrint("delete table \(name) success")
            return true
        }
        else{
            debugPrint("delete table \(name) fail")
            return false
        }
    }
    
    static func insertObjs(array:[BaseObject])->Bool {
        debugPrint("ISQLite: insert")
        if array.count == 0 {
            return true
        }
        
        var result = true
        dbQueue.inTransaction { (db, roolback) in
            let firstObject = array.first!
            let propertiesName = firstObject.getPropertiesName()
            let tableName = firstObject.tableName()
            let listCol = propertiesName.joined(separator: ", ")
            let listParam = propertiesName.map({ (propName) -> String in
                return "?"
            }).joined(separator: ", ")
            
            for object in array {
                let values = object.getPropertiesValue().map({ (v) -> String in
                    if v is Int || v is Float || v is CGFloat || v is Double {
                        return "\(v)"
                    }
                    return v as! String
                })
                
                let query = String(format:ISQLiteConstant.Query.Update, tableName, listCol, listParam)
                do{
                    try db.executeUpdate(query, values: values)
                }
                catch {
                    roolback.pointee = true
                    result = false
                    return
                }
            }
        }
        
        return result
    }
    
    static func updateObjs(array:[BaseObject])->Bool {
        debugPrint("ISQLite: update")
        return insertObjs(array:array)
    }
    
    static func deleteObjs(array:[BaseObject])->Bool {
        debugPrint("ISQLite: delete")
        if array.count == 0 {
            return true
        }
        
        var result = true
        let tableName = array.first!.tableName()
        let propNames = array.first!.getPropertiesName()
        let unquieKeys = array.first!.uniqueKeys()
        dbQueue.inTransaction { (db, rollback) in
            for object in array {
                var condition = ""
                if let unquieKeys = unquieKeys {
                    let propValues = object.getPropertiesValue()
                    for key in unquieKeys {
                        for (i,prop) in propNames.enumerated() {
                            if key == prop {
                                let value = propValues[i]
                                if String.isEmpty(str:condition) {
                                    if value is String {
                                        //string
                                        let sV = value as! String
                                        condition += "\(key) = '\(sV)'"
                                    }
                                    else{
                                        //int
                                        let iV = value as! Int
                                        condition += "\(key) = \(iV)"
                                    }
                                }
                                else{
                                    if value is String {
                                        //string
                                        let sV = value as! String
                                        condition += ", \(key) = '\(sV)'"
                                    }
                                    else{
                                        //int
                                        let iV = value as! Int
                                        condition += ", \(key) = \(iV)"
                                    }
                                }
                                break
                            }
                        }
                    }
                    
                    //create query
                    let query = String(format:ISQLiteConstant.Query.DeleteWhere,tableName, condition)
                    do {
                        try db.executeUpdate(query, values: nil)
                    }
                    catch{
                        rollback.pointee = true
                        result = false
                        return
                    }
                }
                else{
                    
                }
            }
        }
        
        return result
    }
    
    static func fetchObjs<T:BaseObject>(condition: String) -> [T] {
        debugPrint("ISQLite: fetchObjs")
        let tableName = T.tableName()
        let query = String.isEmpty(str: condition) ? String(format: ISQLiteConstant.Query.SelectAll, tableName) :  String(format:ISQLiteConstant.Query.SelectWhere,tableName,condition)
        let arrResult : [T] = ISQLite.excuteQuery(query: query)
        return arrResult
    }
}

//MARK: - Implement
extension ISQLite {
    static let dbQueue = FMDatabaseQueue(path: getDBPath())
    
    static func getDBPath()->String{
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let dbPath = paths.first?.appendingFormat("/%@", IDatabase.dbFileName)
        return dbPath!
    }
    
    static func excuteUpdate(query:String)->Bool {
        var result = false
        dbQueue.inDatabase { (db) in
            do {
                try db.executeUpdate(query, values: nil)
                result = true
            }
            catch{
                debugPrint("excute update fail, query : \(query)")
            }
        }
        return result
    }
    
    static func multipleStatementUpdate(query:String)->Bool {
        var result = false
        dbQueue.inDatabase { (db) in
            result = db.executeStatements(query)
        }
        return result
    }
    
    static func excuteQuery<T:BaseObject>(query:String) ->[T] {
        var arrayResult = [T]()
        dbQueue.inDatabase { (db) in
            do {
                let resultSet = try db.executeQuery(query, values: nil)
                while resultSet.next() {
                    var dictObj = [String:Any]()
                    for i in 0..<resultSet.columnCount {
                        dictObj[resultSet.columnName(for: i)!] = resultSet.object(forColumnIndex: i)
                    }
                    if let obj = T(JSON: dictObj) {
                        arrayResult.append(obj)
                    }
                    else{
                        debugPrint("create obj \(T.self) fail from data: \(dictObj)")
                    }
                }
            }
            catch {
                debugPrint("excute query fail, query : \(query)")
            }
        }
        return arrayResult
    }
}

//MARK: - SUPPORT FUNCTIONS
extension ISQLite {
    static func columnsDefine(fromModel type:BaseObject.Type)->String{
        let object = type.init()
        var columnsDef = "id INTEGER PRIMARY KEY"
        func addProperty(mirror: Mirror){
            for (_, attr) in mirror.children.enumerated() {
                if let property_name = attr.label as String? {
                    var valueType = ISQLiteConstant.DBValueType.Text
                    if attr.value is Int {
                        valueType = ISQLiteConstant.DBValueType.Int
                    }
                    
                    columnsDef = columnsDef.appendingFormat(", %@ %@", property_name, valueType)
                }
            }
        }
        
        let mirrored_object = Mirror(reflecting: object)
        addProperty(mirror: mirrored_object)
        var parent = mirrored_object.superclassMirror
        while parent != nil {
            addProperty(mirror: parent!)
            parent = parent!.superclassMirror
        }
        
        if let uniqueKeys = object.uniqueKeys(){
            let listKeys = uniqueKeys.joined(separator: ", ")
            let uniqueComd = String(format:ISQLiteConstant.Query.Unique, listKeys)
            columnsDef = columnsDef.appendingFormat(", %@", uniqueComd)
        }
        return columnsDef
    }
    
//    static func generateColumn(object:BaseObject) -> String{
//        let arrayProp = object.getPropertiesName()
//        let col = arrayProp.joined(separator: ", ")
//        return col
//    }
//
//    static func generateValue(object:BaseObject) -> String{
//        let arrayValue = object.getPropertiesValue()
//        let value = arrayValue.joined(separator: ", ")
//        return value
//    }
    
    static func deleteObject(object : BaseObject, uniqueKey:[String]){
        
    }
}
