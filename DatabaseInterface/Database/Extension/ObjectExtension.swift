//
//  ObjectExtension.swift
//  Nichiren
//
//  Created by Duy Pham Viet on 2017/11/24.
//  Copyright © 2017 Duy Pham Viet. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

extension NSObject{
    func className()->String {
        return NSStringFromClass(type(of: self))
    }
    
    static func className()->String{
        return String.init(describing: self)
    }
    
    class func swiftClassFromString(className: String) -> AnyClass? {
        // get the project name
        if  let appName: String = Bundle.main.object(forInfoDictionaryKey:"CFBundleName") as? String {
            let classStringName = "\(appName).\(className)"
            return NSClassFromString(classStringName)
        }
        return nil;
    }
    
    class func objectFromClass(className cls: String)->AnyObject?{
        if let aClass = NSObject.swiftClassFromString(className: cls) as? NSObject.Type {
            return aClass.init()
        }
        return nil
    }
    
    func getPropertiesName()->[String]{
        var arrayProp = [String]()
        func addProperty(mirror: Mirror){
            for (_, attr) in mirror.children.enumerated() {
                if let property_name = attr.label as String? {
                    arrayProp.append(property_name)
                }
            }
        }
        
        let mirrored_object = Mirror(reflecting: self)
        addProperty(mirror: mirrored_object)
        var parent = mirrored_object.superclassMirror
        while parent != nil {
            addProperty(mirror: parent!)
            parent = parent!.superclassMirror
        }
        
        return arrayProp
    }
    
    func getPropertiesValue()->[Any]{
        var arrayValue = [Any]()
        func addProperty(mirror: Mirror){
            for (_, attr) in mirror.children.enumerated() {
                if let property_name = attr.label as String? {
                    var value : Any = ""
                    if attr.value is Int {
                        value = 0
                    }
                    if let v = self.value(forKey: property_name) {
                        value = v
                    }
                    arrayValue.append(value)
                }
            }
        }
        
        let mirrored_object = Mirror(reflecting: self)
        addProperty(mirror: mirrored_object)
        var parent = mirrored_object.superclassMirror
        while parent != nil {
            addProperty(mirror: parent!)
            parent = parent!.superclassMirror
        }
        
        return arrayValue
    }
    
    func jsonString()->String?{
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            let jsonString = String.init(data: jsonData, encoding: .utf8)
            return jsonString
        }
        catch{
            debugPrint("convert to json string fail: \(error.localizedDescription)")
            return nil
        }
    }
    
    func copyObject()->Self{
        let newObject = type(of: self).init()
        
        func addProperty(mirror: Mirror){
            for (_, attr) in mirror.children.enumerated() {
                if let property_name = attr.label as String? {
                    if let value = self.value(forKey: property_name) {
                        newObject.setValue(value, forKey: property_name)
                    }
                }
            }
        }
        
        let mirrored_object = Mirror(reflecting: self)
        addProperty(mirror: mirrored_object)
        var parent = mirrored_object.superclassMirror
        while parent != nil {
            addProperty(mirror: parent!)
            parent = parent!.superclassMirror
        }
        
        return newObject
    }
    
    //MARK: - DISPATCH
    static func runInMainThread(_ action:@escaping ()->Void){
        DispatchQueue.main.async(execute: action)
    }
    
    static func runInMainThread(delay: Double, action:@escaping ()->Void){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+delay, execute: action)
    }
    
    static func runInBackground(_ action:@escaping ()->Void){
        DispatchQueue.global(qos: .background).async {
            action()
        }
    }
    
    static func runInBackground(delay:Double, action:@escaping ()->Void){
        let deadlineTime = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: action)
    }
}
