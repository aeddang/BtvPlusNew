//
//  Model.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI

struct DynamicValue: Codable {
    private var boolValue: Bool?  = nil
    private var numberValue: Double? = nil
    private var stringValue: String? = nil
    
    var bool: Bool? {
        get{
            if let bool = self.boolValue { return bool }
            if let bit = self.numberValue { return bit == 1 ? true : false }
            if let yn = self.stringValue { return yn.uppercased() == "Y" ? true : false }
            return nil
        }
    }
    var number: Double? {
        get{
            if let num = self.numberValue{ return num }
            if let bool = self.boolValue { return bool ? 1 : 0 }
            if let numStr = self.stringValue {
                guard let num = Double(numStr) else { return  0}
                return num
            }
            return nil
        }
    }
    var string: String? {
        get{
            if let str = self.stringValue{ return str }
            if let bool = self.boolValue { return  bool ? "true" : "false" }
            if let num = self.numberValue { return num.description }
            return nil
        }
    }
    
    init(from decoder: Decoder) throws {
        let container =  try decoder.singleValueContainer()
        do {
            stringValue = try container.decode(String.self)
        } catch {
            do {
                numberValue = try container.decode(Double.self)
            } catch {
                boolValue = try container.decode(Bool.self)
            }
        }
    }
    
}
