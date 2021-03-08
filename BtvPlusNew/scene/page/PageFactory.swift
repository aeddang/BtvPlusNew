//
//  PageFactory.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import UIKit
import Foundation
import SwiftUI

extension PageID{
    static let intro:PageID = "intro"
    static let serviceError:PageID = "serviceError"
    static let home:PageID = "home"
    static let category:PageID = "category"
    static let synopsis:PageID = "synopsis"
    static let oeean:PageID = "oeean"
    static let pairing:PageID = "pairing"
    static let my:PageID = "my"
    static let setup:PageID = "setup"
    static let pairingSetupUser:PageID = "pairingSetupUser"
    static let pairingDevice:PageID = "pairingDevice"
    static let pairingBtv:PageID = "pairingBtv"
    static let pairingUser:PageID = "pairingUser"
    static let pairingManagement:PageID = "pairingManagement"
    
    static let purchase:PageID = "purchase"
    static let multiBlock:PageID = "multiBlock"
    static let categoryList:PageID = "categoryList"
    static let previewList:PageID = "previewList"
    static let fullPlayer:PageID = "fullPlayer"
}

struct PageProvider {
    
    static func getPageObject(_ pageID:PageID)-> PageObject {
        let pobj = PageObject(pageID: pageID)
        pobj.pageIDX = getPageIdx(pageID)
        pobj.isHome = isHome(pageID)
        pobj.isAnimation = !pobj.isHome
        pobj.isDimed = getDimed(pageID)
        pobj.animationType = getType(pageID)
        pobj.zIndex = isTop(pageID) ? 1 : 0
        return pobj
    }
    
    static func getPageId(skimlink:String?)-> PageID? {
        guard let skimlink = skimlink else { return nil }
        if let _ = skimlink.range(of: "btvplusapp/MyPairgingManager", options: .caseInsensitive) { return .my }
        return nil
    }
    
    static func isHome(_ pageID:PageID)-> Bool{
        switch pageID {
        case .home, .intro , .category : return  true
           default : return  false
        }
    }
    
    static func getType(_ pageID:PageID)-> PageAnimationType{
        switch pageID {
        case .home, .category,
             .pairingSetupUser, .pairingBtv,
             .pairingDevice, .pairingUser, .pairingManagement,
             .purchase :
            return  .vertical
        case .fullPlayer :
            return .none
        default : return  .horizental
        }
    }
    
    static func isTop(_ pageID:PageID)-> Bool{
        switch pageID{
           default : return  false
        }
    }
    
    static func getPageIdx(_ pageID:PageID)-> Int {
        switch pageID {
            case .intro : return 1
            case .home : return  100
            case .category : return  101
            default : return  9999
        }
    }
    
    static func getDimed(_ pageID:PageID)-> Bool {
        switch pageID {
            default : return  false
        }
    }
    
    static func getPageTitle(_ pageID:PageID, deco:String = "")-> String {
        switch pageID {
            default : return  ""
        }
    }
}

extension PageParam {
   static let id = "id"
   static let data = "data"
   static let type = "type"
   static let title = "title"
   static let autoPlay = "autoPlay"
   static let initTime = "initTime"
   static let viewPagerModel = "viewPagerModel"
   static let infinityScrollModel = "infinityScrollModel"
}

extension PageEventType {
   static let pageChange = "pageChange"
}

enum PageStyle{
    case dark, white, normal
    var textColor:Color {
        get{
            switch self {
            case .normal: return Color.app.white
            case .dark: return Color.app.white
            case .white: return Color.app.black
            }
        }
    }
    var bgColor:Color {
        get{
            switch self {
            case .normal: return Color.brand.bg
            case .dark: return Color.app.blueDeep
            case .white: return Color.app.white
            }
        }
    }
}

struct PageFactory{
    static func getPage(_ pageObject:PageObject) -> PageViewProtocol{
        switch pageObject.pageID {
        case .home : return PageHome()
        case .category : return PageCategory()
        case .serviceError : return PageServiceError()
        case .my : return PageMy()
        case .setup : return PageSetup()
        case .synopsis : return PageSynopsis()
        case .pairing : return PagePairing()
        case .pairingSetupUser : return PagePairingSetupUser()
        case .pairingDevice : return PagePairingDevice()
        case .pairingBtv : return PagePairingBtv()
        case .pairingUser : return PagePairingUser()
        case .pairingManagement : return PagePairingManagement()
        case .purchase : return PagePurchase()
        case .multiBlock : return PageMultiBlock()
        case .categoryList : return PageCategoryList()
        case .previewList : return PagePreviewList()
        case .fullPlayer : return PageFullPlayer()
        default : return PageTest()
        }
    }
   
    static func getViewPagerModel(_ pageObject:PageObject)-> ViewPagerModel{
        guard let params = pageObject.params else { return ViewPagerModel() }
        return ( params[.viewPagerModel] as? ViewPagerModel ) ?? ViewPagerModel()
    }
    static func getInfinityScrollModel(_ pageObject:PageObject)-> InfinityScrollModel{
        guard let params = pageObject.params else { return  InfinityScrollModel() }
        return ( params[.infinityScrollModel] as? InfinityScrollModel ) ?? InfinityScrollModel()
    }
}

struct PageSceneModel: PageModel {
    var currentPageObject: PageObject? = nil
    var topPageObject: PageObject? = nil
    
    func getPageOrientation(_ pageObject:PageObject?) -> UIInterfaceOrientationMask? {
        guard let pageObject = pageObject ?? self.topPageObject else {
            return UIInterfaceOrientationMask.all
        }
        switch pageObject.pageID {
        case .home, .synopsis, .purchase, .category, .previewList:
            return UIInterfaceOrientationMask.portrait
        case .fullPlayer: return UIInterfaceOrientationMask.landscape
        default :
            return UIInterfaceOrientationMask.all
        }
    }
    func getPageOrientationLock(_ pageObject:PageObject?) -> UIInterfaceOrientationMask? {
        guard let pageObject = pageObject ?? self.topPageObject else {
            return UIInterfaceOrientationMask.all
        }
        switch pageObject.pageID {
        case .synopsis, .fullPlayer:
            return UIInterfaceOrientationMask.all
        default :
            return getPageOrientation(pageObject)
        }
    }
    func getCloseExceptions() -> [PageID]? {
        return []
    }
    
    func isHistoryPage(_ pageObject:PageObject ) -> Bool {
        switch pageObject.pageID {
        case .serviceError, .fullPlayer: return false
        default : return true
        }
    }
    
    static func needBottomTab(_ pageObject:PageObject) -> Bool{
        switch pageObject.pageID {
        case .home, .category: return true
        default : return false
        }
    }
    
    static func needTopTab(_ pageObject:PageObject) -> Bool{
        
        switch pageObject.pageID {
        case .home, .category: return true
        default : return false
        }
    }
    
    static func needKeyboard(_ pageObject:PageObject) -> Bool{
        switch pageObject.pageID {
        case .pairingSetupUser, .pairingBtv: return true
        default : return false
        }
    }
    
}

