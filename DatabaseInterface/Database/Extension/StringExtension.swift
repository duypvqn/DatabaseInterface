//
//  StringExtension.swift
//  CookingManager
//
//  Created by Duy Pham Viet on 2017/05/29.
//  Copyright © 2017 Duy Pham Viet. All rights reserved.
//

import Foundation
import UIKit

extension String{
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return String(self[Range(start ..< end)])
    }
    
    mutating func reformatDateTime()
    {
        if let range1 = self.range(of: ".") {
            if let range2 = self.range(of: "Z") {
                let removeRange = range1.lowerBound..<range2.lowerBound
                self.removeSubrange(removeRange)
            }
        }
    }
    
    public static func isEmpty(str:String?) -> Bool{
        if let str = str {
            if str.count > 0 {
                return false
            }
        }
        return true
    }
    
    public static func isNotEmpty(str:String?) -> Bool{
        return !String.isEmpty(str: str)
    }
    
    //MARK: - validate
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    //MARK: -
    public func image() -> UIImage? {
        return UIImage.init(named: self)
    }
    
    public func int()->Int{
        return String.isEmpty(str: self) ? 0 : Int(self)!
    }
    
    public func float()->Float{
        return String.isEmpty(str: self) ? 0 : Float(self)!
    }
    
    public func string()->String{
        return String.isNotEmpty(str: self) ? self : ""
    }
    
    public func string(default str:String)->String{
        return String.isNotEmpty(str: self) ? self : str
    }
}
