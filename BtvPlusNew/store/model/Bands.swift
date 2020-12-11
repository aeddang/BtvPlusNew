//
//  Bands.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation

enum BandsStatus{
    case initate, ready
}

enum BandsEvent{
    case update, updated
}

class Bands:ObservableObject, PageProtocol {
    @Published private(set) var status:BandsStatus = .initate
    @Published private(set) var event:BandsEvent? = nil
    private(set) var datas:Array<Band> = []
    
    func resetData(){
        self.datas = []
        self.status = .initate
        self.event = .update
        self.event = nil
    }
    
    func setDate(_ data:GnbBlock){
        if let gnbs = data.gnbs {
            self.datas = gnbs.map{ gnb in
                Band().setDate(gnb)
            }
        }
        self.status = .ready
        self.event = .updated
        self.event = nil
    }
    
    func getData(pageID:PageID)-> Band? {
        let key = PageProvider.getApiKey(pageID)
        guard let band = self.datas.first(
                where: { $0.menuId == key }) else { return nil }
        return band
    }
}

class Band {
    private(set) var name:String = ""
    private(set) var menuId:String = ""
    private(set) var limLvl:Bool = false
    private(set) var gnbTypCd:String = ""
    private(set) var pagePath:String = ""
    private(set) var btmMenuTreeExps:Bool = false
    private(set) var bnrUse:Bool = false
    private(set) var blocks:Array<BlockItem> = []
    func setDate(_ data:GnbItem) -> Band{
        name = data.menu_nm ?? ""
        menuId = data.menu_id ?? ""
        limLvl = data.lim_lvl_yn?.toBool() ?? false
        gnbTypCd = data.gnb_typ_cd ?? ""
        pagePath = data.page_path ?? ""
        btmMenuTreeExps = data.btm_menu_tree_exps_yn?.toBool() ?? false
        bnrUse = data.bnr_use_yn?.toBool() ?? false
        blocks = data.blocks ?? []
        return self
    }
    
}
