//
//  RealmInterface.swift
//  DatabaseInterface
//
//  Created by Duy Pham Viet on 2018/08/14.
//  Copyright © 2018 Duy Pham Viet. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class IRealm: NSObject, DBProtocol {
    //MARK: - DBInterface
    static func createTable(fromModel:BaseObject.Type)->Bool{
        debugPrint("IRealm: \(fromModel)")
        return true
    }
    
    static func deleteTable(name: String)->Bool {
        debugPrint("IRealm: \(name)")
        return true
    }
    
    static func insertObjs(array:[BaseObject])->Bool {
        debugPrint("IRealm: insert")
        if let _ = IRealm.updateObjects(arrayData: array) {
            debugPrint("insert fail")
            return false
        }
        else{
            debugPrint("insert success")
            return true
        }
    }
    
    static func updateObjs(array:[BaseObject])->Bool {
        debugPrint("IRealm: update")
        return insertObjs(array: array)
    }
    
    static func deleteObjs(array:[BaseObject])->Bool {
        debugPrint("IRealm: delete")
        return IRealm.deleteObjs(array: array)
    }
    
    static func fetchObjs<T:BaseObject>(condition: String) -> [T] {
        debugPrint("IRealm: fetchObjs")
        if condition.count > 0 {
            guard let result = IRealm.getObjects(filter: condition) as? [T] else{
                return [T]()
            }
            return result
        }
        
        let result : [T] = IRealm.getObjects()
        return result
    }
}

//MARK: - Realm config
extension IRealm {
    static func realmDB()->Realm{
        if Realm.Configuration.defaultConfiguration.schemaVersion < IDatabase.curVer {
            IDatabase.migrationAction?()
        }
        
        do{
            let realm = try Realm()
            return realm
        }
        catch{
            debugPrint("open db error : \(error.localizedDescription)")
            return try! Realm()
        }
    }
    
    static func deleteRealm()->Bool{
        let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
        let realmURLs = [
            realmURL,
            realmURL.appendingPathExtension("lock"),
            realmURL.appendingPathExtension("note"),
            realmURL.appendingPathExtension("management")
        ]
        for URL in realmURLs {
            do {
                if FileManager.default.fileExists(atPath: URL.path){
                    try FileManager.default.removeItem(at: URL)
                }
            } catch {
                // handle error
                return false
            }
        }
        return true
    }
}

//MARK: - Return Realm Object
extension IRealm {
    /// Get objects from local DB and return Results RealmObject
    ///
    /// - Parameters:
    ///   - filter: filter query (default nil)
    ///   - keySorted: key sorted (default nil)
    ///   - ascending: ascending / descending (it is used when have key sorted)
    ///   - distinctKeys: list key distinct
    /// - Returns: Results RealmObject
    class func rGetObjects<T:BaseObject>(filter:String? = nil, keySorted:String? = nil, ascending:Bool = false, distinctKeys:[String]? = nil)->Results<T>{
        var result : Results<T> = IRealm.realmDB().objects(T.self)
        if let filter = filter , filter.count > 0 {
            result = result.filter(filter)
        }
        if let keySorted = keySorted , keySorted.count > 0 {
            result = result.sorted(byKeyPath: keySorted, ascending: ascending)
        }
        if let keys = distinctKeys, keys.count > 0 {
            result = result.distinct(by: keys)
        }
        
        return result
    }
}

//MARK: - Return normal object
extension IRealm {
    /// Get objects and return Array RealmObject
    ///
    /// - Parameters:
    ///   - filter: filter query (default nil: get all)
    ///   - keySorted: key sorted (default nil)
    ///   - ascending: ascending / descending (it is used when have key sorted)
    ///   - distinctKeys: list key distinct
    /// - Returns: Array RealmObject
    class func getObjects<T:BaseObject>(filter:String? = nil, keySorted:String? = nil, ascending:Bool = false, distinctKeys:[String]? = nil)-> [T] {
        let results : Results<T> = IRealm.rGetObjects(filter: filter, keySorted: keySorted, ascending: ascending)
        return Array(results)
    }
    
    /// Delete array realm object
    ///
    /// - Parameter listData: list objects need to delete
    /// - Returns: return true if succ otherwise false and error
    class func deleteObjects<T:BaseObject>(listData:[T])->(Bool,Error?) {
        let reamlDB = IRealm.realmDB()
        reamlDB.beginWrite()
        reamlDB.delete(listData)
        do{
            try reamlDB.commitWrite()
            return (true, nil)
        }
        catch {
            debugPrint("DAOCity: delete all data fail : \(error.localizedDescription)")
            return (false, error)
        }
    }
    
    /// Save array of realm object
    ///
    /// - Parameter arrayData: array object need to save
    /// - Returns: return true if succ otherwise false and error
    class func updateObjects<T:BaseObject>(arrayData:[T])->Error? {
        let realmDB = IRealm.realmDB()
        realmDB.beginWrite()
        realmDB.add(arrayData, update: true)
        do{
            try realmDB.commitWrite()
            return nil
        }
        catch {
            return error
        }
    }
}
