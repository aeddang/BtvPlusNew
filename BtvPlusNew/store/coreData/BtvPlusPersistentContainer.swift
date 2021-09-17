//
//  BtvPlusPersistentContainer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/09/17.
//

import Foundation
import CoreData
class BtvPlusPersistentContainer: NSPersistentContainer {
    
    override open class func defaultDirectoryURL() -> URL {
        var storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.skb.btvplus")
        storeURL = storeURL?.appendingPathComponent("BtvPlus.sqlite")
        return storeURL!
    }

}
