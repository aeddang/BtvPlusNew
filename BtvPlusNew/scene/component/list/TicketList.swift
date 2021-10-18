//
//  ThemaList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import struct Kingfisher.KFImage

class TicketData:InfinityData{
    private(set) var image: String = Asset.noImg16_9
    private(set) var joinImage: String? = nil
    private(set) var title: String? = nil
    private(set) var subTitle: String? = nil
    private(set) var isAdult:Bool = false
    private(set) var count: String = "0"
    private(set) var type:TicketType = .small
    private(set) var menuId: String? = nil
    private(set) var blocks:[BlockItem]? = nil
    private(set) var prodId: String? = nil
    private(set) var prodTypeCd: String? = nil
    
    fileprivate(set) var isJoin: Bool = false
    fileprivate(set) var isSubJoin: Bool = false
    fileprivate(set) var subDatas:[PosterData]? = nil
    var hasAuth :Bool {
        get{
            return isJoin || isSubJoin
        }
    }
    func setData(data:ContentItem, cardType:BlockData.CardType = .squareThema, posters:[PosterData]? = nil, idx:Int = -1) -> TicketData {
        title = data.title
        subDatas = posters
        isAdult = EuxpNetwork.adultCodes.contains(data.adlt_lvl_cd)
        if let thumb = data.poster_filename_h {
            image = ImagePath.thumbImagePath(filePath: thumb, size: type.size, convType: .alpha ) ?? image
        }
        index = idx
        return self
    }
    
    func setData(data:BlockItem, cardType:BlockData.CardType = .squareThema, posters:[PosterData]? = nil, idx:Int = -1) -> TicketData {
        type = data.blk_typ_cd == "30" ? .big : .small
        title = data.menu_nm
        subDatas = posters
        isAdult = data.lim_lvl_yn?.toBool() ?? false
        if let thumb = data.bnr_off_img_path {
            image = ImagePath.thumbImagePath(filePath: thumb, size: type.size, convType:  .alpha ) ?? image
        }
        if let thumb = data.ppm_join_off_img_path {
            joinImage = ImagePath.thumbImagePath(filePath: thumb, size: type.size, convType:  .alpha)
        }
        
        index = idx
        blocks = data.blocks
        menuId = data.menu_id
        prodId = data.prd_prc_id
        prodTypeCd = data.prd_typ_cd
    
        return self
    }
    
    func getImage() -> String {
        if self.hasAuth {
            return  joinImage ?? image
        } else {
            return  image
        }
    }
    
    func setDummy(_ idx:Int = -1) -> TicketData {
        title = "THEMA"
        subTitle = "subTitlesubTitlesubTitle"
        index = idx
        return self
    }
    func setDummyCircle(_ idx:Int = -1) -> TicketData {
        title = "THEMA"
        subTitle = "subTitlesubTitlesubTitle"
        index = idx
        type = .small
        return self
    }
}

enum TicketType {
    case small, big
    var size:CGSize {
        get{
            switch self {
            case .small: return ListItem.ticket.type01
            case .big: return ListItem.ticket.type02
            }
        }
    }
}

extension TicketList{
    static let headerSize:Int = 2
    static let spacing:CGFloat = Dimen.margin.tiny
}

struct TicketList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
   
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var data: BlockData? = nil
    var datas:[TicketData]
    var useTracking:Bool = false
    
   
    @State var subDatas:[PosterData]? = nil
    @State var subDataSets:[PosterDataSet]? = nil
    var headerSize:Int = 2
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: 0,
            marginHorizontal: Dimen.margin.thin ,
            spacing: 0,
            isRecycle: true,
            useTracking: self.useTracking
            ){
            
            ForEach(self.datas) { data in
                TicketItem( data:data )
                    .modifier(HolizentalListRowInset(spacing: Self.spacing))
                    .accessibility(label: Text(data.title ?? ""))
                    .onTapGesture {
                        if !data.hasAuth {
                            let status = self.pairing.status
                            if status != .pairing {
                                self.appSceneObserver.alert = .needPairing()
                                return
                            }
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.purchase)
                                    .addParam(key: .data, value: data)
                            )
                            return
                        }
                        
                        if data.blocks != nil && data.blocks?.isEmpty == false {
                            if data.blocks!.count > 1 {
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.multiBlock)
                                        .addParam(key: .id, value: data.menuId)
                                        .addParam(key: .title, value: data.title)
                                        .addParam(key: .data, value: data.blocks)
                                )
                            } else {
                                let block = BlockData().setData(data.blocks!.first!)
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.categoryList)
                                        .addParam(key: .title, value: block.name)
                                        .addParam(key: .id, value: block.menuId)
                                        .addParam(key: .type, value: block.uiType )
                                )
                            }
                        }else{
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.categoryList)
                                    .addParam(key: .title, value: data.title)
                                    .addParam(key: .id, value: data.menuId)
                                    .addParam(key: .type, value: CateBlock.ListType.poster)
                            )
                        }
                }
            }
            if let subDataSets = self.subDataSets {
                ForEach(subDataSets) {sets in
                    HStack(spacing:Self.spacing){
                        ForEach(sets.datas) { data in
                            PosterItem( data:data )
                                .frame(width:ListItem.poster.type01.width)
                                .onTapGesture {
                                    self.onTap(data: data)
                                }
                        }
                    }
                    .modifier(HolizentalListRowInset(spacing: Self.spacing))
                }
            }
            if let subDatas = self.subDatas {
                if Self.headerSize < subDatas.count {
                    HStack(spacing:0){
                        ForEach( subDatas[0...Self.headerSize]) { data in
                            PosterItem( data:data )
                                .frame(width:ListItem.poster.type01.width)
                                .modifier(HolizentalListRowInset(spacing: Self.spacing))
                                .onTapGesture {
                                    self.onTap(data: data)
                                }
                        }
                    }
                    
                    ForEach( subDatas[(Self.headerSize+1)...(subDatas.count-1)]) { data in
                        PosterItem( data:data )
                            .frame(width:ListItem.poster.type01.width)
                            .modifier(HolizentalListRowInset(spacing: Self.spacing))
                            .onTapGesture {
                                self.onTap(data: data)
                            }
                    }
                } else {
                    ForEach(subDatas) { data in
                        PosterItem( data:data )
                            .frame(width:ListItem.poster.type01.width)
                            .modifier(HolizentalListRowInset(spacing: Self.spacing))
                            .onTapGesture {
                                self.onTap(data: data)
                            }
                    }
                }
            }
            
        }
        .onReceive(dataProvider.$result) { res in
            guard let data = res?.data as? GridEvent else { return }
            guard let first = self.datas.first else { return }
            guard let id = first.menuId else { return }
            if res?.id != id {return}
            first.subDatas = data.contents?.map{PosterData().setData(data: $0)}
            self.onBindingData(datas: first.subDatas)
            
        }
        .onAppear{
            if let first = self.datas.first {
                if first.type == .big {
                    guard let id = first.menuId else { return }
                    if first.subDatas == nil {
                        self.dataProvider.requestData(
                            q:.init(id:id, type:.getGridEvent(id))
                        )
                    }else{
                        self.onBindingData(datas: first.subDatas)
                    }
                }
            }
        }
    }//body
    
    func onTap(data:PosterData)  {
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.synopsis)
                .addParam(key: .data, value: data.synopsisData)
        )
    }
    
    func onBindingData(datas:[PosterData]?)  {
        let count:Int = 2
        var rows:[PosterDataSet] = []
        var cells:[PosterData] = []
        var total = self.datas.count
        datas?.forEach{ d in
            if cells.count < count {
                cells.append(d)
            }else{
                rows.append(
                    PosterDataSet( count: count, datas: cells, isFull: true, index: total)
                )
                cells = [d]
                total += 1
            }
        }
        if !cells.isEmpty {
            rows.append(
                PosterDataSet( count: count, datas: cells,isFull: cells.count == count, index: total)
            )
        }
        
        self.subDataSets = rows
        self.data?.posters = datas
    }
}

struct TicketItem: PageView {
    @EnvironmentObject var pairing:Pairing
    @State var image:String? = nil
    var data:TicketData
    var body: some View {
        ZStack{
            KFImage(URL(string: self.image ?? ""))
                .resizable()
                .placeholder {
                    Image(Asset.noImg1_1)
                        .resizable()
                }
                .cancelOnDisappear(true)
                .aspectRatio(contentMode: .fit)
                .modifier(MatchParent())
            
        }
        .frame(
            width: self.data.type.size.width,
            height: self.data.type.size.height)
       
        .onAppear(){
            self.image = self.data.getImage()
            //self.pairing.authority.requestAuth(.updateMyinfo(isReset: false))
        }
        .onReceive(self.pairing.authority.$event){ evt in
            guard let evt = evt else { return }
            switch evt {
            case .updatedMyinfo, .updatedMyTicketInfo :
                if let list = self.pairing.authority.purchaseLowLevelTicketList {
                    self.updateList(list:list, isSub: true)
                }
                if let list = self.pairing.authority.purchaseTicketList {
                    self.updateList(list:list, isSub: false)
                }
                break
            default : break
            }
        }
        .onReceive(self.pairing.authority.$purchaseLowLevelTicketList){ list in
            guard let list = list else { return }
            self.updateList(list:list, isSub: true)
        }
        .onReceive(self.pairing.authority.$purchaseTicketList){ list in
            guard let list = list else { return }
            self.updateList(list:list, isSub: false)
           
        }
        .onReceive(self.pairing.authority.$monthlyPurchaseInfo){ _ in
            //guard let list = self.pairing.authority.monthlyPurchaseList else { return }
            //self.updateList(list:list)
        }
        .onReceive(self.pairing.authority.$periodMonthlyPurchaseInfo){ _ in
           // guard let list = self.pairing.authority.periodMonthlyPurchaseList else { return }
            //self.updateList(list:list)
        }
    }
    
    
    private func updateList(list: [MonthlyInfoItem], isSub:Bool){
        if isSub {
            self.data.isSubJoin = (list.first(where: {$0.prod_id == self.data.prodId}) != nil)
        } else {
            self.data.isJoin = (list.first(where: {$0.prod_id == self.data.prodId}) != nil)
        }
        
        let willImage = self.data.getImage()
        if willImage != self.image {
            self.image = willImage
        }
    }
    private func updateList(list: [ PurchaseFixedChargeItem]){
        self.data.isSubJoin = (list.first(where: {$0.prod_id == self.data.prodId}) != nil)
        let willImage = self.data.getImage()
        if willImage != self.image {
            self.image = willImage
        }
    }
   
    private func updateList(list: [PurchaseFixedChargePeriodItem]){
        self.data.isSubJoin = (list.first(where: {$0.prod_id == self.data.prodId}) != nil)
        let willImage = self.data.getImage()
        if willImage != self.image {
            self.image = willImage
        }
    }
  
}

#if DEBUG
struct TicketList_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            TicketList( datas: [
                TicketData().setDummy(0),
                TicketData().setDummyCircle(),
                TicketData().setDummy(),
                TicketData().setDummy()
            ])
            .environmentObject(PagePresenter()).frame(width:320,height:600)
        }
    }
}
#endif
