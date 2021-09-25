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
    static let auth:PageID = "auth"
    static let serviceError:PageID = "serviceError"
    static let home:PageID = "home"
    static let category:PageID = "category"
    static let synopsis:PageID = "synopsis"
    static let monthlyTicket:PageID = "monthlyTicket"
    static let synopsisPackage:PageID = "synopsisPackage"
    static let synopsisPlayer:PageID = "synopsisPlayer"
    static let pairing:PageID = "pairing"
    static let my:PageID = "my"
    static let myPurchase:PageID = "myPurchase"
    static let myBookMark:PageID = "myBookMark"
    static let myBenefits:PageID = "myBenefits"
    static let myAlram:PageID = "myAlram"
    static let myPurchaseTicketList:PageID = "myPurchaseTicketList"
    static let myRecommand:PageID = "myRecommand"
    static let myPossessionPurchase:PageID = "myPossessionPurchase"
    static let myRegistCard:PageID = "myRegistCard"
    
    static let modifyProile:PageID = "modifyProile"
    static let setup:PageID = "setup"
    static let terminateStb:PageID = "terminateStb"
    static let pairingSetupUser:PageID = "pairingSetupUser"
    static let pairingDevice:PageID = "pairingDevice"
    static let pairingBtv:PageID = "pairingBtv"
    static let pairingUser:PageID = "pairingUser"
    static let pairingManagement:PageID = "pairingManagement"
    static let pairingEmptyDevice:PageID = "pairingEmptyDevice"
    static let pairingGuide:PageID = "pairingGuide"
    static let pairingAppleTv:PageID = "pairingAppleTv"
    static let pairingFamilyInvite:PageID = "pairingFamilyInvite"
  
    static let purchase:PageID = "purchase"
    static let multiBlock:PageID = "multiBlock"
    static let categoryList:PageID = "categoryList"
    static let previewList:PageID = "previewList"
    static let watchedList:PageID = "watchedList"
    static let fullPlayer:PageID = "fullPlayer"
    
    static let webview:PageID = "webview"
    static let webviewList:PageID = "webviewList"
    static let person:PageID = "person"
    static let search:PageID = "search"
    static let schedule:PageID = "schedule"
    static let adultCertification:PageID = "adultCertification"
    static let userCertification:PageID = "userCertification"
    static let confirmNumber:PageID = "confirmNumber"
    static let watchHabit:PageID = "watchHabit"
    static let purchaseList:PageID = "purchaseList"
    
    static let couponList:PageID = "couponList"
    static let privacyAndAgree:PageID = "PrivacyAndAgree"
    static let remotecon:PageID = "remotecon"
    static let playerTest:PageID = "playerTest"
    static let playerTestList:PageID = "playerTestList"
    static let cashCharge:PageID = "cashCharge"
    static let cashChargeGuide:PageID = "cashChargeGuide"
    static let cashChargePrivacyAndAgree:PageID = "cashChargePrivacyAndAgree"
    static let recommand:PageID = "recommand"
    static let recommandReceive:PageID = "recommandReceive"
    static let snsShare:PageID = "snsShare"
    static let picker:PageID = "picker"
}

struct PageProvider {
    
    static func getPageObject(_ pageID:PageID, animationType:PageAnimationType? = nil)-> PageObject {
        let pobj = PageObject(pageID: pageID, pageGroupID:PageType.btv.rawValue)
        pobj.pageIDX = getPageIdx(pageID)
        pobj.isHome = isHome(pageID)
        pobj.isAnimation = !pobj.isHome
        pobj.isDimed = getDimed(pageID)
        pobj.animationType = animationType ?? getType(pageID)
        pobj.zIndex = isTop(pageID) ? 1 : 0
        return pobj
    }
    
    static func getPageId(skimlink:String?)-> PageID? {
        guard let skimlink = skimlink else { return nil }
        if let _ = skimlink.range(of: "btvplusapp/MyPairgingManager", options: .caseInsensitive) { return .pairingManagement }
        if let _ = skimlink.range(of: "btvplusapp/PairingManager", options: .caseInsensitive) { return .pairingManagement }
        if let _ = skimlink.range(of: "btvplusapp/Pairing", options: .caseInsensitive) { return .pairing }
        if let _ = skimlink.range(of: "btvplusapp/Settings", options: .caseInsensitive) { return .setup }
        if let _ = skimlink.range(of: "btvplusapp/chargeStation", options: .caseInsensitive) { return .cashCharge }
        if let _ = skimlink.range(of: "btvplusapp/FamilyInvite", options: .caseInsensitive) { return .snsShare }

        return nil
    }
    
    static func isHome(_ pageID:PageID)-> Bool{
        switch pageID {
        case .home, .intro , .category, .auth : return  true
           default : return  false
        }
    }
    
    static func getType(_ pageID:PageID)-> PageAnimationType{
        if pageID == .synopsis {
            return PageSynopsis.useLayer ? .vertical : .horizontal
        }
        
        switch pageID {
        case .pairingSetupUser, .pairingBtv,
             .pairingDevice, .pairingUser, .pairingManagement, .pairingEmptyDevice, .pairingGuide,
             .purchase , .webview, .webviewList, .schedule, .modifyProile,
             .adultCertification, .userCertification, .terminateStb,
             .myPurchaseTicketList, .remotecon, .playerTest,
             .myRecommand, .myRegistCard, .picker:
            return  .vertical
        case .fullPlayer, .synopsisPlayer :
            return .none
        case .confirmNumber, .privacyAndAgree, .cashChargeGuide, .cashChargePrivacyAndAgree,
             .recommand, .recommandReceive, .snsShare, .pairingAppleTv, .pairingFamilyInvite:
            return .opacity
        default : return  .horizontal
        }
    }
    
    static func isTop(_ pageID:PageID)-> Bool{
        if pageID == .synopsis {
            return PageSynopsis.useLayer
        }
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





struct PageFactory{ 
    static func getPage(_ pageObject:PageObject) -> PageViewProtocol{
        switch pageObject.pageID {
        case .auth : return PageAuth()
        case .intro : return PageIntro()
        case .home : return PageHome()
        case .category : return PageCategory()
        case .monthlyTicket : return PageMultiBlock()
        case .serviceError : return PageServiceError()
        case .my : return PageMy()
        case .myPurchase : return PageMyPurchase()
        case .myBookMark : return PageCategoryList()
        case .myBenefits : return PageMyBenefits()
        case .myAlram : return PageMyAlram()
        case .myRecommand : return PageMyRecommand()
        case .myPossessionPurchase : return PageMyPossessionPurchase()
        case .myRegistCard : return PageMyRegistCard()
        case .modifyProile : return PageModifyProfile()
        case .setup : return PageSetup()
        case .terminateStb : return PageTerminateStb()
        case .synopsis : return PageSynopsis()
        case .synopsisPackage : return PageSynopsisPackage()
        case .synopsisPlayer : return PageSynopsisPlayer()
        case .pairing : return PagePairing()
        case .pairingSetupUser : return PagePairingSetupUser()
        case .pairingDevice : return PagePairingDevice()
        case .pairingBtv : return PagePairingBtv()
        case .pairingUser : return PagePairingUser()
        case .pairingManagement : return PagePairingManagement()
        case .pairingEmptyDevice : return PagePairingEmptyDevice()
        case .pairingGuide : return PagePairingGuide()
        case .pairingAppleTv : return PagePairingAppleTv() 
        case .pairingFamilyInvite : return PagePairingFamilyInvite()
        case .purchase : return PagePurchase()
        case .multiBlock : return PageMultiBlock()
        case .categoryList : return PageCategoryList()
        case .watchedList : return PageWatchedList()
        case .previewList : return PagePreviewList()
        case .fullPlayer : return PageFullPlayer()
        case .webview : return PageWebview()
        case .webviewList : return PageWebview()
        case .person : return PagePerson()
        case .search : return PageSearch()
        case .schedule : return PageSchedule()
        case .adultCertification : return PageAdultCertification()
        case .userCertification : return PageCertification()
        case .confirmNumber : return PageConfirmNumber()
        case .watchHabit : return PageWatchHabit()
        case .purchaseList : return PagePurchaseList()
        case .myPurchaseTicketList : return PageMyPurchaseTicketList()
        case .couponList : return PageCouponList()
        case .privacyAndAgree : return PagePrivacyAndAgree()
        case .remotecon : return PageRemotecon()
        case .playerTest : return PagePlayerTest()
        case .playerTestList : return PagePlayerTestList()
        case .cashCharge : return PageCashCharge()
        case .cashChargeGuide : return PageCashChargeGuide()
        case .cashChargePrivacyAndAgree : return PageCashChargePrivacyAndAgree()
        case .recommand : return PageRecommand()
        case .recommandReceive : return PageRecommandReceive()
        case .snsShare : return PageSnsShare()
        case .picker : return PagePicker()
        default : return PageTest()
        }
    }
}


