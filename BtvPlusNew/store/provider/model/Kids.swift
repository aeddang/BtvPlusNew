//
//  Kids.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/01.
//

import Foundation
class KidsGnbModel:Identifiable, ObservableObject{
    private(set) var home: KidsGnbItemData? = nil
    private(set) var datas: [KidsGnbItemData] = []
    @Published var isUpdated:Bool = false  {didSet{ if isUpdated { isUpdated = false} }}

    func setData(gnb:GnbBlock) {
        if let gnbs = gnb.gnbs {
            self.datas = gnbs.map{ gnb in
                let item =  gnb.menu_id == EuxpNetwork.MenuTypeCode.MENU_KIDS_HOME.rawValue ? KidsGnbItemData().setHomeData(data: gnb) : KidsGnbItemData().setData(gnb)
                if item.isHome { self.home = item }
                return item
            }
        }
        self.isUpdated = true
    }
    
    func getGnbDatas() -> [KidsGnbItemData] {
       return datas
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
        
        self.imageOff = ImagePath.thumbImagePath(filePath: data.bnr_off_img_path, size: size, convType: .alpha) ?? self.imageOn
        self.imageOn = ImagePath.thumbImagePath(filePath: data.bnr_on_img_path, size: size, convType: .alpha) ?? self.imageOff
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
