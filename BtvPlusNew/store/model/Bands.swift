//
//  Bands.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI

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
    
    func setDate(_ data:GnbBlock?){
        guard let data = data else { return }
        if let gnbs = data.gnbs {
            self.datas = gnbs.map{ gnb in
                Band().setDate(gnb)
            }
        }
        self.status = .ready
        self.event = .updated
        self.event = nil
    }
    
    func getData(menuId:String)-> Band? {
        guard let band = self.datas.first(
                where: { $0.menuId == menuId }) else { return nil }
        return band
    }
    
    func getData(gnbTypCd:String)-> Band? {
        guard let band = self.datas.first(
                where: { $0.gnbTypCd == gnbTypCd }) else { return nil }
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

    private(set) var defaultIcon:String = Asset.noImg1_1
    private(set) var activeIcon:String = Asset.noImg1_1
    private(set) var blocks:Array<BlockItem> = []
    
    func setDate(_ data:GnbItem) -> Band{
        name = data.menu_nm ?? ""
        menuId = data.menu_id ?? ""
        limLvl = data.lim_lvl_yn?.toBool() ?? false
        gnbTypCd = data.gnb_typ_cd ?? ""
        pagePath = data.page_path ?? ""
        
        let size = CGSize(width: 100, height: 100)
        if data.menu_on_img_path != nil {
            defaultIcon =  ImagePath.thumbImagePath(filePath: data.menu_on_img_path, size: size, convType: .alpha)
        }
        if data.menu_off_img_path != nil {
            activeIcon =  ImagePath.thumbImagePath(filePath: data.menu_off_img_path!, size: size, convType: .alpha)
        }
        
        btmMenuTreeExps = data.btm_menu_tree_exps_yn?.toBool() ?? false
        bnrUse = data.bnr_use_yn?.toBool() ?? false
        blocks = data.blocks ?? []
        return self
    }
    
}
