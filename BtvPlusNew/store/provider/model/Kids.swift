//
//  Kids.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/01.
//

import Foundation
class KidsGnbModel:Identifiable, ObservableObject{
    private(set) var home: KidsGnbItemData? = nil
    private(set) var monthly: KidsGnbItemData? = nil
    private(set) var datas: [KidsGnbItemData] = []
    var playListData:KidsPlayListData? = nil // kis Item에 하위 블락이 없어서 kisplay list를 공유 함 trash...
    
    @Published var isUpdated:Bool = false  {didSet{ if isUpdated { isUpdated = false} }}

    func setData(gnb:GnbBlock) {
        if let gnbs = gnb.gnbs {
            self.datas = gnbs.map{ gnb in
                switch gnb.kidsz_gnb_cd {
                case EuxpNetwork.KidsGnbCd.home.rawValue:
                    let item = KidsGnbItemData().setHomeData(data: gnb)
                    self.home = item
                    return item
                case EuxpNetwork.KidsGnbCd.monthlyTicket.rawValue:
                    let item = KidsGnbItemData().setData(gnb)
                    self.monthly = item
                    return item
                default :
                    return KidsGnbItemData().setData(gnb)
                }
            }
        }
        self.isUpdated = true
    }
    
    func getGnbDatas() -> [KidsGnbItemData] {
       return datas
    }
    
    func getGnbData(title:String)-> KidsGnbItemData? {
        guard let band = self.datas.first(
                where: { $0.title == title }) else { return nil }
        return band
    }
    func getGnbData(menuCode:String)-> KidsGnbItemData? {
        guard let band = self.datas.first(
                where: { $0.menuCode == menuCode }) else { return nil }
        return band
    }
    
    func getGnbData(menuId:String)-> KidsGnbItemData? {
        guard let band = self.datas.first(
                where: { $0.menuId == menuId }) else { return nil }
        return band
    }
    
    func getGnbData(linkId:String)-> KidsGnbItemData? {
        guard let band = self.datas.first(
                where: { data in
                    data.blocks?.first(where: {
                        $0.menu_id == linkId
                    }) != nil
                }) else { return nil }
        return band
    }
    
    func getGnbData(links:[String])-> (KidsGnbItemData , String)?{
        var findId:String = ""
        guard let band = self.datas.first(
                where: { data in
                    data.blocks?.first(where: { block in
                        links.first(where: {
                            let isFind = block.menu_id == $0
                            if isFind {findId = $0 }
                            return isFind
                        }) != nil
                    }) != nil
                }) else { return nil }
        return (band, findId)
    }
    
    func getMyDatas() -> [BlockItem]? {
        return self.home?.getMyData() 
    }
    
}

class KidsGnbItemData:InfinityData, ObservableObject{
    private(set) var imageOn: String = Asset.noImg1_1
    private(set) var imageOff: String = Asset.noImg1_1
    private(set) var title: String? = nil
    private(set) var menuId: String? = nil
    private(set) var menuCode: String? = nil
    private(set) var blocks: [BlockItem]? = nil
    private(set) var isHome:Bool = false
    fileprivate(set) var idx:Int = -1

    func setHomeData(data:GnbItem) -> KidsGnbItemData {
        self.isHome = true
        self.title = data.menu_nm
        self.menuId = data.menu_id
        self.menuCode = data.kidsz_gnb_cd
        self.imageOn = AssetKids.gnbTop.homeOn
        self.imageOff = AssetKids.gnbTop.homeOff
        self.blocks = data.blocks?.map{$0}
        return self
    }
    
    func setData(_ data:GnbItem) -> KidsGnbItemData {
        self.title = data.menu_nm
        self.menuId = data.menu_id
        self.menuCode = data.kidsz_gnb_cd
        self.blocks = data.blocks?.map{$0}
        let size = CGSize(width: DimenKids.icon.heavy, height: DimenKids.icon.heavy)
        
        self.imageOff = ImagePath.thumbImagePath(filePath: data.menu_off_img_path, size: size, convType: .alpha) ?? self.imageOn
        self.imageOn = ImagePath.thumbImagePath(filePath: data.menu_on_img_path, size: size, convType: .alpha) ?? self.imageOff
        return self
    }
    
    func getMyData() -> [BlockItem]? {
        if !self.isHome { return nil }
        let myBlocks = self.blocks?
            .first(where: {$0.menu_id == EuxpNetwork.MenuTypeCode.MENU_KIDS_HOME_FIRST.rawValue})?.blocks?
                    .first(where: {$0.menu_id == EuxpNetwork.MenuTypeCode.MENU_KIDS_MY.rawValue})?.blocks
        
        return myBlocks
    }
   
}

//svc_prop_cd
enum KidsPlayType:Equatable{
    case play, english , tale, create, subject, unknown(String? = nil)
    static let limitedLv1 :Int = 48
    static let limitedLv2 :Int = 72
    
    static func getType(_ value:String?)->KidsPlayType{
        switch value {
        case "512": return .play
        case "513": return .english
        case "514": return .tale
        case "515": return .create
        case "516": return .subject
        default : return .unknown(value)
        }
    }
    var sortIdx:Int {
        get{
            switch self {
            case .play: return 0
            case .english: return 1
            case .tale: return 2
            case .create: return 3
            case .subject: return 4
            default : return  100
            }
        }
    }
    
    var noImage:String {
        get{
            switch self {
            case .play: return AssetKids.image.homeCardBg1
            case .english: return AssetKids.image.homeCardBg2
            case .tale: return AssetKids.image.homeCardBg3
            case .create: return AssetKids.image.homeCardBg4
            case .subject: return AssetKids.image.homeCardBg5
            default : return  AssetKids.image.homeCardBg1
            }
        }
    }
    
    var diagnosticReportType:DiagnosticReportType? {
        get{
            switch self {
            case .english: return .english
            case .tale: return .infantDevelopment
            case .create: return .creativeObservation
            default : return  nil
            }
        }
    }
    
    static func ==(lhs: KidsPlayType, rhs: KidsPlayType) -> Bool {
        switch (lhs, rhs) {
        case ( .play, .play): return true
        case ( .english, .english): return true
        case ( .tale, .tale): return true
        case ( .create, .create): return true
        case ( .subject, .subject): return true
        default : return false
        }
    }
}
