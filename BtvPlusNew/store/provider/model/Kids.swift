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
    var playListData:KidsPlayListData? = nil
    
    @Published var isUpdated:Bool = false  {didSet{ if isUpdated { isUpdated = false} }}

    func setData(gnb:GnbBlock) {
        if let gnbs = gnb.gnbs {
            self.datas = gnbs.map{ gnb in
                switch gnb.menu_id {
                case EuxpNetwork.MenuTypeCode.MENU_KIDS_HOME.rawValue:
                    let item = KidsGnbItemData().setHomeData(data: gnb)
                    self.home = item
                    return item
                case EuxpNetwork.MenuTypeCode.MENU_KIDS_MONTHLY.rawValue:
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
    
    func getGnbData(menuId:String)-> KidsGnbItemData? {
        guard let band = self.datas.first(
                where: { $0.menuId == menuId }) else { return nil }
        return band
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
    private(set) var blocks: [BlockItem]? = nil
    private(set) var isHome:Bool = false
    fileprivate(set) var idx:Int = -1

    func setHomeData(data:GnbItem) -> KidsGnbItemData {
        self.isHome = true
        self.title = data.menu_nm
        self.menuId = data.menu_id
        self.imageOn = AssetKids.gnbTop.homeOn
        self.imageOff = AssetKids.gnbTop.homeOff
        self.blocks = data.blocks?.map{$0}
        return self
    }
    
    func setData(_ data:GnbItem) -> KidsGnbItemData {
        self.title = data.menu_nm
        self.menuId = data.menu_id
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
