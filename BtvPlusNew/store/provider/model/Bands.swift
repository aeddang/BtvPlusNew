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
    let kidsGnbModel = KidsGnbModel()
    
    func resetData(){
        self.datas = []
        self.status = .initate
        self.event = .update
        self.event = nil
    }
    
    func setData(_ data:GnbBlock?){
        guard let data = data else { return }
        if let gnbs = data.gnbs {
            self.datas = gnbs.filter{$0.gnb_typ_cd != EuxpNetwork.GnbTypeCode.GNB_KIDS.rawValue}.map{ gnb in
                return Band().setData(gnb)
            }
        }
        self.status = .ready
        self.event = .updated
        DataLog.d("UPDATEED GNBDATA", tag:self.tag)
        self.event = nil
    }
    func setDataKids(_ data:GnbBlock?){
        guard let data = data else { return }
        self.kidsGnbModel.setData(gnb: data)
    }
    
    func getData(menuId:String)-> Band? {
        guard let band = self.datas.first(
                where: { $0.menuId == menuId }) else { return nil }
        return band
    }
    
    func getData(gnbTypCd:String)-> Band? {
        guard let band = self.datas.first(
                where: { $0.gnbTypCd.subString(start: 0, len: 5) == gnbTypCd.subString(start: 0, len: 5) }) else { return nil }
        return band
    }
    
    func getHome()-> Band? {
        return self.datas.first
    }
    
    func getPreviewBlockData()->  BlockItem?  {
        guard let band = self.datas.first(
                where: { $0.gnbTypCd == EuxpNetwork.GnbTypeCode.GNB_CATEGORY.rawValue }) else { return nil }
        return band.blocks.first(
            where: { CateSubType.getType(id:$0.gnb_sub_typ_cd) == .prevList}
        )
    }
    
    func getClipBlockData()->  BlockItem?  {
        guard let band = self.datas.first(
                where: { $0.gnbTypCd == EuxpNetwork.GnbTypeCode.GNB_CATEGORY.rawValue }) else { return nil }
        return band.blocks.first(
            where: { CateSubType.getType(id:$0.gnb_sub_typ_cd) == .clip}
        )
    }
    
    func getEventBlockData()->  BlockItem?  {
        guard let band = self.datas.first(
                where: { $0.gnbTypCd == EuxpNetwork.GnbTypeCode.GNB_CATEGORY.rawValue }) else { return nil }
        return band.blocks.first(
            where: { CateSubType.getType(id:$0.gnb_sub_typ_cd) == .event}
        )
    }
    
    func getTipBlockData()->  BlockItem?  {
        guard let band = self.datas.first(
                where: { $0.gnbTypCd == EuxpNetwork.GnbTypeCode.GNB_CATEGORY.rawValue }) else { return nil }
        return band.blocks.first(
            where: { CateSubType.getType(id:$0.gnb_sub_typ_cd) == .tip}
        )
    }
    
    func getMonthlyBlockData(name:String?)-> BlockItem? {
        guard let name = name else { return nil }
        guard let band = getData(gnbTypCd: EuxpNetwork.GnbTypeCode.GNB_MONTHLY.rawValue) else {return nil}
        let block = band.blocks.first(where: {
            
            $0.menu_nm == name
        })
        return block 
    }
    
}

class Band {
    private(set) var name:String = ""
    private(set) var menuId:String = ""
    private(set) var isAdult:Bool = false
    private(set) var gnbTypCd:String = ""
    private(set) var pagePath:String = ""
    private(set) var btmMenuTreeExps:Bool = false
    private(set) var bnrUse:Bool = false

    private(set) var defaultIcon:String = ""
    private(set) var activeIcon:String = ""
    private(set) var defaultNoImg:String = Asset.noImg1_1
    private(set) var activeNoImg:String = Asset.noImg1_1
    private(set) var blocks:Array<BlockItem> = []
    
    func setData(_ data:GnbItem) -> Band{
        name = data.menu_nm ?? ""
        menuId = data.menu_id ?? ""
        isAdult = data.lim_lvl_yn?.toBool() ?? false
        gnbTypCd = data.gnb_typ_cd ?? ""
        pagePath = data.page_path ?? ""
        
        let size = CGSize(width: 50, height: 50)
        
        switch gnbTypCd {
        case EuxpNetwork.GnbTypeCode.GNB_HOME.rawValue :
            self.defaultNoImg = Asset.gnbBottom.homeOff
            self.activeNoImg = Asset.gnbBottom.homeOn
        case EuxpNetwork.GnbTypeCode.GNB_OCEAN.rawValue :
            self.defaultNoImg = Asset.gnbBottom.oceanOff
            self.activeNoImg = Asset.gnbBottom.oceanOn
        case EuxpNetwork.GnbTypeCode.GNB_MONTHLY.rawValue :
            self.defaultNoImg = Asset.gnbBottom.paymentOff
            self.activeNoImg = Asset.gnbBottom.paymentOn
        case EuxpNetwork.GnbTypeCode.GNB_CATEGORY.rawValue :
            self.defaultNoImg = Asset.gnbBottom.categoryOff
            self.activeNoImg = Asset.gnbBottom.categoryOn
        case EuxpNetwork.GnbTypeCode.GNB_FREE.rawValue :
            self.defaultNoImg = Asset.gnbBottom.freeOff
            self.activeNoImg = Asset.gnbBottom.freeOn
        default:
            break
        }
        
        if let path = data.menu_off_img_path {
            defaultIcon =  ImagePath.thumbImagePath(filePath: path, size: size, convType: .alpha)  ?? defaultIcon
        }
        if let path =  data.menu_on_img_path {
            activeIcon =  ImagePath.thumbImagePath(filePath: path, size: size, convType: .alpha) ?? activeIcon
        }
        
        btmMenuTreeExps = data.btm_menu_tree_exps_yn?.toBool() ?? false
        bnrUse = data.bnr_use_yn?.toBool() ?? false
        blocks = data.blocks ?? []
        return self
    }
    
}
