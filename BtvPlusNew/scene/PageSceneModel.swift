//
//  Page.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/01.
//
import Foundation

extension PageParam {
    static let id = "id"
    static let cid = "cid" // Certification
    static let index = "index" // Certification
    static let subId = "subId"
    static let link = "link"
    static let data = "data"
    static let datas = "datas"
    static let type = "type"
    static let subType = "subType"
    static let title = "title"
    static let text = "text"
    static let subText = "subText"
    static let autoPlay = "autoPlay"
    static let initTime = "initTime"
    static let viewPagerModel = "viewPagerModel"
    static let infinityScrollModel = "infinityScrollModel"
    static let needAdult = "needAdult"
    static let watchLv = "watchLv"
    static let isFree = "isFree"
}

extension PageEventType {
    static let pageChange = "pageChange"
    static let timeChange = "timeChange"
    static let completed = "completed"
    static let cancel = "cancel"
    static let certification = "certification"
    static let selected = "selected"
}

struct PageSceneModel: PageModel {
    var currentPageObject: PageObject? = nil
    var topPageObject: PageObject? = nil
    
    func getPageOrientation(_ pageObject:PageObject?) -> UIInterfaceOrientationMask? {
        guard let pageObject = pageObject ?? self.topPageObject else {
            return UIInterfaceOrientationMask.all
        }
        switch pageObject.pageID {
        case .fullPlayer, .synopsisPlayer: return UIInterfaceOrientationMask.landscape
        default : break
        }
        if SystemEnvironment.isTablet && pageObject.pageGroupID == PageType.btv.rawValue {
            return UIInterfaceOrientationMask.all }
        switch pageObject.pageID {
        case .categoryList, .multiBlock :
            return UIInterfaceOrientationMask.portrait
        default :
            switch pageObject.pageGroupID {
            case PageType.kids.rawValue :
                return UIInterfaceOrientationMask.landscape
            default:
                return UIInterfaceOrientationMask.portrait
            }
        }
    }
    
    func getPageOrientationLock(_ pageObject:PageObject?) -> UIInterfaceOrientationMask? {
        guard let pageObject = pageObject ?? self.topPageObject else {
            return UIInterfaceOrientationMask.all
        }
    
        if SystemEnvironment.isTablet && pageObject.pageGroupID == PageType.btv.rawValue {
            return UIInterfaceOrientationMask.all }
        switch pageObject.pageID {
        case .fullPlayer, .synopsis:
            return UIInterfaceOrientationMask.all
        default :
            return getPageOrientation(pageObject)
        }
    }
    
    func getUIStatusBarStyle(_ pageObject:PageObject?) -> UIStatusBarStyle? {
        if pageObject?.pageGroupID == PageType.kids.rawValue {
            return .darkContent
        } else {
            return .lightContent
        }
    }
    
    func getCloseExceptions() -> [PageID]? {
        return PageSynopsis.useLayer ? [.synopsis] : nil
    }
    
    func isHistoryPage(_ pageObject:PageObject ) -> Bool {
        switch pageObject.pageID {
        case .serviceError, .fullPlayer, .auth, .confirmNumber, .adultCertification, .certification : return false
        case .kidsIntro, .registKid: return false
        default : return true
        }
    }
    
    
    static func needPairing(_ pageObject:PageObject) -> Bool{
        switch pageObject.pageID {
        case .kidsExam: return true
        case .cashCharge, .synopsisPlayer, .snsShare: return true
        default : return false
        }
    }
    
    static func needBottomTab(_ pageObject:PageObject, sceneOrientation:SceneOrientation) -> Bool{
        switch pageObject.pageID {
        case .synopsis :
            return SystemEnvironment.isTablet ? sceneOrientation == .portrait : true
        case .home, .category, .multiBlock, .search, .my, .webviewList,
             .categoryList, .previewList, .setup, .synopsisPackage:
            return true
        default :
            return false
        }
    }
    
    static func needTopTab(_ pageObject:PageObject) -> Bool{
        switch pageObject.pageID {
        case .home, .category : return true
        case .kidsHome : return true
        default : return false
        }
    }
    
    static func needKeyboard(_ pageObject:PageObject) -> Bool{
        switch pageObject.pageID {
        case .pairingSetupUser, .pairingBtv, .search, .modifyProile, .webviewList, .confirmNumber,
             .confirmNumber, .pairingManagement, .setup, .remotecon , .myRegistCard: return true
        case .registKid,  .kidsSearch, .editKid , .kidsConfirmNumber: return true
        default : return false
        }
    }
    
}
