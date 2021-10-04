//
//  KidsHeader.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/13.
//

import Foundation
import SwiftUI
import struct Kingfisher.KFImage
class KidsCategoryListData: KidsHomeBlockListData {
    private(set) var title:String? = nil
    private(set) var svcPropCd:String? = nil
    private(set) var isTicket:Bool = false
    private(set) var datas:[KidsCategoryListItemData] = []
    private(set) var sets:[KidsCategoryListItemDataSet] = []
    private(set) var logTabTitle:String? = nil
    func setData(data:BlockItem, uiType:BlockData.UiType? = nil, useTitle:Bool = true) -> KidsCategoryListData{
        self.logTabTitle = data.menu_nm
        
        self.type = .cateList
        if useTitle {
            self.title = data.menu_nm ?? " "
        }
        let cardType = data.btm_bnr_blk_exps_cd
        self.isTicket = uiType == .kidsTicket
        switch cardType {
        case "05":
            self.title = " "
            self.blocks = data.blocks ?? []
            self.datas = [
                KidsCategoryListItemData()
                    .setData(data: data, size: KidsCategoryList.size, isTicket: isTicket)
                    .setNaviLog(action: .init(config: self.logTabTitle, category: data.menu_nm))
            ]
            
        case "08":
            
            if let blocks = data.blocks {
                self.blocks = blocks
                var rows:[KidsCategoryListItemDataSet] = []
                var cells:[KidsCategoryListItemData] = []
                blocks
                    .map{KidsCategoryListItemData()
                    .setData(data: $0, size: KidsCategoryList.sizeHalf, isTicket: isTicket)
                    .setNaviLog(action: .init(config: self.logTabTitle, category: $0.menu_nm))
                }.forEach{ d in
                    if cells.count < 2 {
                        cells.append(d)
                    }else{
                        rows.append(
                            KidsCategoryListItemDataSet(
                                datas: cells,
                                isFull: true)
                            
                        )
                        cells = [d]
                    }
                }
                if !cells.isEmpty {
                    rows.append(
                        KidsCategoryListItemDataSet(
                            datas: cells,
                            isFull: cells.count == 2)
                    )
                }
                self.sets = rows
            }
            
        default:
            self.blocks = data.blocks ?? []
            let count = self.blocks.count
            self.datas = zip(0...count,  self.blocks)
                .map{ idx,  block in
                    if isTicket {
                        return KidsCategoryListItemData()
                            .setData(data: block, isTicket: isTicket)
                            .setNaviLog(
                                action: .init(
                                    menu_id: block.menu_id,
                                    menu_name: block.menu_nm,
                                    position: (idx+1).description + "@" + count.description),
                                contents : .init(
                                    title: self.logTabTitle
                                )
                            )
                    } else {
                        return KidsCategoryListItemData()
                            .setData(data: block, isTicket: isTicket)
                            .setNaviLog(action: .init(config: self.logTabTitle, category: block.menu_nm))
                    }
                }
        }
        return self
    }
    
    
    
}

struct KidsCategoryListItemDataSet:Identifiable {
    private(set) var id = UUID().uuidString
    var datas:[KidsCategoryListItemData] = []
    var isFull = false
    var index:Int = -1
}

class KidsCategoryListItemData:Identifiable, ObservableObject{
    private(set) var id = UUID().uuidString
    
    private(set) var activeImage:String? = nil
    private(set) var passiveImage:String? = nil
    
    private(set) var image:String? = nil
    private(set) var defaultImage:String = AssetKids.noImgCard
    private(set) var title:String? = nil
    private(set) var menuId:String? = nil
    private(set) var prdPrcId:String? = nil
    private(set) var blocks:[BlockItem] = []
    private(set) var size:CGSize = KidsCategoryList.size
    private(set) var monthlyData:MonthlyData? = nil
    private(set) var isTicket:Bool = false
    @Published private(set) var isActive: Bool = false
    
    private(set) var actionLog:MenuNaviActionBodyItem? = nil
    private(set) var contentsLog:MenuNaviContentsBodyItem? = nil
    var logPage:NaviLog.PageId? = nil
    var logAction:NaviLog.Action? = nil
    var hasLog:Bool { get{ return logAction != nil || actionLog != nil || contentsLog != nil} }
   
    @discardableResult
    func setNaviLog(action:MenuNaviActionBodyItem?, contents:MenuNaviContentsBodyItem? = nil) -> KidsCategoryListItemData  {
        self.logAction = isTicket ? .clickPaymentMenu : .clickSecondDepthMenu
        self.contentsLog = contents
        self.actionLog = action
        return self
    }
    
    func setData(data:BlockItem, size:CGSize? = nil, isTicket:Bool = false) -> KidsCategoryListItemData {
        
        let size = size ?? (isTicket ? KidsCategoryList.sizeLong : KidsCategoryList.size)
        //let cardType = data.btm_bnr_blk_exps_cd
        /*
        switch cardType {
        case "07":
            size = KidsCategoryList.sizeRound
        default: break
        }*/
        self.isTicket = isTicket
        self.prdPrcId = data.prd_prc_id
        self.title = data.menu_nm
        self.size = size
        self.blocks = data.blocks ?? [data]
        self.activeImage = ImagePath.thumbImagePath(filePath: data.ppm_join_off_img_path, size:CGSize(width: 0, height: size.height), convType:.alpha)
        self.passiveImage = ImagePath.thumbImagePath(filePath: data.bnr_off_img_path, size:CGSize(width: 0, height: size.height), convType:.alpha)
        self.image = passiveImage
        if size.height == KidsCategoryList.sizeHalf.height {
            self.defaultImage = AssetKids.noImgCardHalf
        }
        if isTicket {
            monthlyData = MonthlyData().setData(data: data)
        }
        return self
    }
    func setData(data: MonthlyInfoItem,  lowLevelPpm:Bool) {
        monthlyData?.setData(data: data, isLow: lowLevelPpm)
        if self.isActive {return}
        self.image = self.activeImage
        self.isActive = true
    }
    func setData(data: PurchaseFixedChargePeriodItem) {
        if self.isActive {return}
        self.image = self.activeImage
        self.isActive = true
    }
    func setData(data: PurchaseFixedChargeItem) {
        if self.isActive {return}
        self.image = self.activeImage
        self.isActive = true
    }
}

extension KidsCategoryList{
    static let size:CGSize = SystemEnvironment.isTablet ? CGSize(width: 205, height: 344) : CGSize(width: 107, height: 179)
    static let sizeHalf:CGSize = SystemEnvironment.isTablet ? CGSize(width: 227, height: 162) : CGSize(width: 118, height: 84)
    static let sizeLong:CGSize = SystemEnvironment.isTablet ? CGSize(width: 198, height: 359) : CGSize(width: 103, height: 187)
    static let sizeRound:CGSize = SystemEnvironment.isTablet ? CGSize(width: 240, height: 359) : CGSize(width: 125, height: 187)
}
struct KidsCategoryList:PageView  {
    @EnvironmentObject var pagePresenter:PagePresenter
    var data:KidsCategoryListData
    
    var body :some View {
        VStack(alignment: .leading , spacing:DimenKids.margin.thin){
            if let title = self.data.title {
                Text(title)
                    .modifier(BlockTitleKids())
                    .lineLimit(1)
                    .fixedSize()
            }
            HStack(alignment: .top, spacing: DimenKids.margin.thinExtra){
                ForEach(self.data.datas) { data in
                    KidsCategoryListItem(data: data)
                }
                ForEach(self.data.sets) { sets in
                    VStack(spacing: DimenKids.margin.thinExtra){
                        ForEach(sets.datas) { data in
                            KidsCategoryListItem(data: data)
                                .frame(width: Self.sizeHalf.width, height: Self.sizeHalf.height)
                        }
                    }
                }
            }
        }
    }
}


struct KidsCategoryListItem:PageView  {
    @EnvironmentObject var naviLogManager:NaviLogManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var data:KidsCategoryListItemData
    @State var image:String? = nil
    var body :some View {
        ZStack(){
            if let img = self.image {
                KFImage(URL(string: img))
                    .resizable()
                    .placeholder {
                        Image(data.defaultImage)
                            .resizable()
                    }
                    .cancelOnDisappear(true)
                    .aspectRatio(contentMode: .fit)
                    .modifier(MatchParent())
            }
        }
        .frame(width: data.size.width, height: data.size.height)
        .onReceive(self.data.$isActive) { _ in
            self.image = self.data.image
        }
        .onTapGesture {
            if data.hasLog {
                self.naviLogManager.actionLog(
                    data.logAction ?? .clickSecondDepthMenu,
                    pageId: data.logPage ,
                    actionBody: data.actionLog,
                    contentBody: data.contentsLog
                )
            }
            
            self.pagePresenter.openPopup(
                PageKidsProvider.getPageObject(.kidsMultiBlock)
                    .addParam(key: .datas, value: data.blocks)
                    .addParam(key: .data, value: data.monthlyData)
                    .addParam(key: .title, value: data.title)
                    .addParam(key: .type, value: data.isTicket ? BlockData.UiType.kidsTicket : nil)
            )
        }
        
    }
}

