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
    func setData(data:ContentItem, cardType:BlockData.CardType = .squareThema, idx:Int = -1) -> TicketData {
        title = data.title
        if let thumb = data.poster_filename_h {
            image = ImagePath.thumbImagePath(filePath: thumb, size: type.size, convType: .alpha ) ?? image
        }
        index = idx
        return self
    }
    
    func setData(data:BlockItem, cardType:BlockData.CardType = .squareThema, idx:Int = -1) -> TicketData {
        type = data.blk_typ_cd == "30" ? .big : .small
        title = data.menu_nm
        if let thumb = data.bnr_off_img_path {
            image = ImagePath.thumbImagePath(filePath: thumb, size: type.size, convType:  .alpha ) ?? image
        }
        if let thumb = data.ppm_join_off_img_path {
            joinImage = ImagePath.thumbImagePath(filePath: thumb, size: ListItem.monthly.size)
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

struct TicketList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
   
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[TicketData]
    var useTracking:Bool = false
    var margin:CGFloat = Dimen.margin.thin
    
    @State var subDatas:[PosterData]? = nil
    
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: 0,
            marginHorizontal: self.margin ,
            spacing: Dimen.margin.tiny,
            isRecycle: false,
            useTracking: self.useTracking
            ){
            ForEach(self.datas) { data in
                TicketItem( data:data )
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
                                    .addParam(key: .title, value: data.title)
                                    .addParam(key: .data, value: data.blocks)
                            )
                        } else {
                            let block = BlockData().setDate(data.blocks!.first!)
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
            if let subDatas = self.subDatas {
                ForEach(subDatas) { data in
                    PosterItem( data:data )
                    .onTapGesture {
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.synopsis)
                                .addParam(key: .data, value: data.synopsisData)
                        )
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
            self.subDatas = first.subDatas
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
                        self.subDatas = first.subDatas
                    }
                }
            }
        }
    }//body
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
                .loadImmediately()
                .aspectRatio(contentMode: .fill)
                .modifier(MatchParent())
        }
        .frame(
            width: self.data.type.size.width,
            height: self.data.type.size.height)
       
        .onAppear(){
            self.image = self.data.getImage()
        }
        .onReceive(self.pairing.authority.$purchaseLowLevelTicketList){ list in
            guard let list = list else { return }
            self.data.isSubJoin = (list.first(where: {$0.prod_id == self.data.prodId}) != nil)
            let willImage = self.data.getImage()
            if willImage != self.image {
                self.image = willImage
            }
        }
        .onReceive(self.pairing.authority.$purchaseTicketList){ list in
            guard let list = list else { return }
            self.data.isJoin = (list.first(where: {$0.prod_id == self.data.prodId}) != nil)
            let willImage = self.data.getImage()
            if willImage != self.image {
                self.image = willImage
            }
           
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
