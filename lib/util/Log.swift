//
//  Log.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import os.log

protocol Log {
    static var tag:String { get }
}
struct LogManager  {
    static fileprivate(set) var memoryLog:String = ""
    static var isMemory = false
    {
        didSet{
            if !isMemory {
                Self.memoryLog = ""
            }
        }
    }
}

extension Log {
   
    static func log(_ message: String, tag:String? = nil , log: OSLog = .default, type: OSLogType = .default) {
        let t = (tag == nil) ? Self.tag : Self.tag + " -> " + tag!
        os_log("%@ %@", log: log, type: type, t, message)
        
    }
    
    static func i(_ message: String, tag:String? = nil) {
        Self.log(message, tag:tag, log:.default, type:.info )
    }
    
    static func d(_ message: String, tag:String? = nil) {
        if LogManager.isMemory {
            LogManager.memoryLog += ("\n" + (tag ?? "Log") + " : " + message)
        }
        #if DEBUG
        Self.log(message, tag:tag, log:.default, type:.debug )
        #endif
    }
    
    static func e(_ message: String, tag:String? = nil) {
        if LogManager.isMemory {
            LogManager.memoryLog += ("\n" + (tag ?? "Log") + " : " + message)
        }
        Self.log(message, tag:tag, log:.default, type:.error )
    }
}
struct PageLog:Log {
    static var tag: String = "Page"
}

struct ComponentLog:Log {
    static var tag: String = "Component"
}

struct DataLog:Log {
    static var tag: String = "Data"
}
