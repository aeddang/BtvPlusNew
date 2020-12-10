//
//  PageFactory.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import UIKit
import Foundation
extension PageID{
    static let intro:PageID = "intro"
    static let home:PageID = "home"
}

struct PageProvider {
    static func getPageObject(_ pageID:PageID)-> PageObject {
        let pobj = PageObject(pageID: pageID)
        pobj.pageIDX = getPageIdx(pageID)
        pobj.isHome = isHome(pageID)
        pobj.isAnimation = !pobj.isHome
        pobj.isDimed = getDimed(pageID)
        pobj.zIndex = isTop(pageID) ? 1 : 0
        return pobj
    }
    static func isHome(_ pageID:PageID)-> Bool{
        switch pageID {
        case .home, .intro : return  true
           default : return  false
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
   static let viewPagerModel = "viewPagerModel"
   static let infinityScrollModel = "infinityScrollModel"
}

extension PageEventType {
   static let pageChange = "pageChange"
}


struct PageFactory{
    static func getPage(_ pageObject:PageObject) -> PageViewProtocol{
        switch pageObject.pageID {
            case .home : return PageTest()
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
    func getPageOrientation(_ pageObject:PageObject ) -> UIInterfaceOrientationMask? {
        switch pageObject.pageID {
        case .home : return UIInterfaceOrientationMask.portrait
            default : return UIInterfaceOrientationMask.portrait
        }
    }
    func getCloseExceptions() -> [PageID]? {
        return []
    }
    
    static func needBottomTab(_ pageObject:PageObject) -> Bool{
        switch pageObject.pageID {
        case .home: return true
        default : return false
        }
    }
    
    static func needTopTab(_ pageObject:PageObject) -> Bool{
        switch pageObject.pageID {
        case .home: return true
        default : return false
        }
    }
    
    static func needKeyboard(_ pageObject:PageObject) -> Bool{
        switch pageObject.pageID {
        default : return false
        }
    }
    
}

