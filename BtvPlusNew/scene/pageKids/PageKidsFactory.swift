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
    static let kidsIntro:PageID = "kidsIntro"
    static let kidsHome:PageID = "kidsHome"
    static let registKid:PageID = "registKid"
    static let editKid:PageID = "editKid"
    static let kidsMy:PageID = "kidsMy"
    static let kidsMyDiagnostic:PageID = "kidsMyDiagnostic"
    static let kidsProfileManagement:PageID = "kidsProfileManagement"
    static let kidsEnglishLvTestSelect:PageID = "kidsEnglishLvTestSelect"
    static let kidsExam:PageID = "kidsExam"
    
    static let selectKidCharacter:PageID = "selectKidCharacter"
    static let kidsConfirmNumber:PageID = "kidsConfirmNumber"
    
    static let tabInfo:PageID = "tabInfo"
    static let detailInfo:PageID = "detailInfo"
    
   
}

struct PageKidsProvider {
    
    static func getPageObject(_ pageID:PageID)-> PageObject {
        let pobj = PageObject(pageID: pageID, pageGroupID:PageType.kids.rawValue)
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
        //if let _ = skimlink.range(of: "btvplusapp/MyPairgingManager", options: .caseInsensitive) { return .my }
        return nil
    }
    
    static func isHome(_ pageID:PageID)-> Bool{
        switch pageID {
        case .kidsHome, .kidsIntro : return  true
           default : return  false
        }
    }
    
    static func getType(_ pageID:PageID)-> PageAnimationType{
        switch pageID {
        case .registKid, .selectKidCharacter, .kidsConfirmNumber, .tabInfo, .detailInfo:
            return  .opacity
       
        default : return  .horizontal
        }
    }
    
    static func isTop(_ pageID:PageID)-> Bool{
        switch pageID{
           default : return  false
        }
    }
    
    static func getPageIdx(_ pageID:PageID)-> Int {
        switch pageID {
            case .kidsIntro : return 1
            case .kidsHome : return  100
           
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

struct PageKidsFactory{
    static func getPage(_ pageObject:PageObject) -> PageViewProtocol{
        switch pageObject.pageID {
        case .kidsIntro : return PageKidsIntro()
        case .kidsHome : return PageKidsHome()
        case .registKid : return PageRegistKid()
        case .editKid : return PageEditKid()
        case .kidsMy : return  PageKidsMy()
        case .kidsMyDiagnostic : return  PageKidsMyDiagnostic()
        case .kidsProfileManagement : return PageKidsProfileManagement()
        case .kidsEnglishLvTestSelect : return  PageKidsEnglishLvTestSelect()
        case .kidsExam : return  PageKidsExam()
        case .selectKidCharacter : return PageSelectKidCharacter()
        case .kidsConfirmNumber : return PageKidsConfirmNumber()
        case .tabInfo : return PageTabInfo()
        case .detailInfo : return PageDetailInfo()
        default : return PageTest()
        }
    }
}


