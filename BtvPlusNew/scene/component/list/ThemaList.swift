//
//  ThemaList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

class ThemaData:InfinityData{
    private(set) var originImage: String? = nil
    private(set) var image: String? = nil
    private(set) var title: String? = nil
    private(set) var subTitle: String? = nil
    private(set) var isAdult:Bool = false
    private(set) var isLock:Bool = false
    private(set) var count: String = "0"
    private(set) var type:ThemaType = .square
    private(set) var menuId: String? = nil
    private(set) var usePrice:Bool = true
    private(set) var blocks:[BlockItem]? = nil
    private(set) var cateType:CateBlock.ListType = .poster
    private(set) var contentLog:MenuNaviContentsBodyItem? = nil
    private(set) var menuNm:String? = nil
    var logPosition:String? = nil
    init(usePrice:Bool = true) {
        self.usePrice = usePrice
        super.init()
    }
    
    func setData(data:ContentItem, cardType:BlockData.CardType = .squareThema, idx:Int = -1) -> ThemaData {
    
        setCardType(cardType)
        isAdult = EuxpNetwork.adultCodes.contains(data.adlt_lvl_cd)
        isLock = !SystemEnvironment.isImageLock ? false : isAdult
        title = data.title
        originImage = data.poster_filename_h
        image = ImagePath.thumbImagePath(filePath: data.poster_filename_h, size: type.size, isAdult:isAdult, convType:.alpha)

        index = idx
        return self.setNaviLog(data: data)
    }
    
    func setNaviLog(data:ContentItem) -> ThemaData {
        self.contentLog = MenuNaviContentsBodyItem(
            type: "thema",
            title: self.title,
            channel_name: nil,
            genre_text: nil,
            genre_code: data.meta_typ_cd,
            paid: nil,
            purchase: nil,
            episode_id: data.epsd_id,
            episode_resolution_id: nil,
            product_id: data.prd_prc_id,
            purchase_type: nil,
            monthly_pay: nil,
            list_price: data.prd_prc?.number?.description ?? nil,
            payment_price: nil
        )
        return self
    }
    
    func setData(data:BlockItem, cardType:BlockData.CardType = .squareThema, idx:Int = -1) -> ThemaData {
        setCardType(cardType)
        setCateType(data.pst_exps_typ_cd)
        isAdult = data.lim_lvl_yn?.toBool() ?? false
        isLock = !SystemEnvironment.isImageLock ? false : isAdult
        title = data.menu_nm
        originImage = data.bnr_off_img_path
        image = ImagePath.thumbImagePath(filePath: data.bnr_off_img_path, size: type.size, isAdult:isAdult, convType:.alpha)
       
        index = idx
        blocks = data.blocks
        menuId = data.menu_id
        menuNm = data.menu_nm
        return self
    }
    
    
    
    private func setCardType(_ cardType:BlockData.CardType){
        switch cardType {
        case .circleTheme: type = .small
        case .bigTheme: type = .big
        default: type = .square
        }
    }
    private func setCateType(_ poster:String?){
        switch poster {
        case "10", "30": cateType = .video
        default: cateType = .poster
        }
    }
    
    func setDummy(_ idx:Int = -1) -> ThemaData {
        title = "THEMA"
        subTitle = "subTitlesubTitlesubTitle"
        index = idx
        return self
    }
    func setDummyCircle(_ idx:Int = -1) -> ThemaData {
        title = "THEMA"
        subTitle = "subTitlesubTitlesubTitle"
        index = idx
        type = .small
        return self
    }
    fileprivate func updatedImage(){
        image = ImagePath.thumbImagePath(filePath: self.originImage, size: type.size, isAdult: self.isAdult)
    }
}

enum ThemaType {
    case square, small, big
    var size:CGSize {
        get{
            switch self {
            case .small: return ListItem.thema.type01
            case .big: return ListItem.thema.type02
            case .square: return ListItem.thema.type03
            }
        }
    }
    var spacing:CGFloat {
        get{
            switch self {
            case .small: return Dimen.margin.thinExtra
            case .big: return Dimen.margin.lightExtra
            case .square: return Dimen.margin.tiny
            }
        }
    }
    var isCircle:Bool {
        get{
            switch self {
            case .small: return true
            case .big: return true
            case .square: return false
            }
        }
    }
}

struct ThemaList: PageComponent{
    @EnvironmentObject var naviLogManager:NaviLogManager
    @EnvironmentObject var pagePresenter:PagePresenter
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var banners:[BannerData]? = nil
    var blockData: BlockData? = nil
    var datas:[ThemaData]
    var useTracking:Bool = false
    var margin:CGFloat = Dimen.margin.thin
    var action: ((_ data:ThemaData) -> Void)? = nil
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: 0,
            marginHorizontal: self.margin ,
            spacing: datas.isEmpty ? 0 : datas[0].type.spacing,
            isRecycle: true,
            useTracking: self.useTracking
            ){
            if let banners = self.banners {
                ForEach(banners) { data in
                    BannerItem(data: data)
                }
            }
            ForEach(self.datas) { data in
                ThemaItem( data:data )
                .accessibility(label: Text(data.title ?? ""))
                .onTapGesture {
                    var actionBody = MenuNaviActionBodyItem()
                    actionBody.menu_id = blockData?.menuId ?? ""
                    actionBody.menu_name = blockData?.name ?? ""
                    actionBody.position = data.logPosition
                    actionBody.config = ""
                    self.naviLogManager.actionLog(.clickContentsView,
                                                  actionBody: actionBody, contentBody:data.contentLog)
                    
                    if let action = self.action {
                        action(data)
                    }else{
                        if data.blocks != nil && data.blocks?.isEmpty == false {
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.multiBlock)
                                    .addParam(key: .id, value: data.menuId)
                                    .addParam(key: .title, value: data.title)
                                    .addParam(key: .data, value: data.blocks)
                                    .addParam(key: .isFree, value:!data.usePrice)
                            )
                        }else{
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.categoryList)
                                    .addParam(key: .title, value: data.title)
                                    .addParam(key: .id, value: data.menuId)
                                    .addParam(key: .type, value: data.cateType)
                                    .addParam(key: .isFree, value:!data.usePrice)
                            )
                        }
                    }
                }
            }
        }
    }//body
}

struct ThemaItem: PageView {
    @EnvironmentObject var repository:Repository
    var data:ThemaData
    var body: some View {
        ZStack{
            ImageView(url: self.data.image, contentMode: .fit, noImg: Asset.noImg1_1)
                .modifier(MatchParent())
            
            if self.data.isLock {
                VStack(alignment: .center, spacing: Dimen.margin.thin){
                    Image(Asset.icon.itemRock)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:Dimen.icon.light, height: Dimen.icon.light)
                    Text(String.app.lockAdult)
                        .modifier(MediumTextStyle(size: Font.size.tiny))
                        
                }
            }
        }
        .frame(
            width: self.data.type.size.width,
            height: self.data.type.size.height)
        .clipped()
        .onReceive(self.repository.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .updatedWatchLv : self.data.updatedImage()
            default : break
            }
        }
    }
}

#if DEBUG
struct ThemaList_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            ThemaList( datas: [
                ThemaData().setDummy(0),
                ThemaData().setDummyCircle(),
                ThemaData().setDummy(),
                ThemaData().setDummy()
            ])
            .environmentObject(PagePresenter()).frame(width:320,height:600)
        }
    }
}
#endif
