//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

class PosterData:InfinityData{
    private(set) var image: String? = nil
    private(set) var originImage: String? = nil
    private(set) var title: String? = nil
    private(set) var subTitle: String? = nil
    private(set) var epsdId:String? = nil
    private(set) var prsId:String? = nil
    private(set) var tagData: TagData? = nil
    private(set) var isAdult:Bool = false
    private(set) var watchLv:Int = 0
    fileprivate(set) var isBookmark:Bool? = nil
    private(set) var synopsisType:SynopsisType = .title
    private(set) var type:PosterType = .small
    private(set) var synopsisData:SynopsisData? = nil
    
    func setData(data:ContentItem, cardType:BlockData.CardType = .smallPoster ,idx:Int = -1) -> PosterData {
        setCardType(cardType)
        title = data.title
        watchLv = data.wat_lvl_cd?.toInt() ?? 0
        isAdult = EuxpNetwork.adultCodes.contains(data.adlt_lvl_cd)
        originImage = data.poster_filename_v
        image = ImagePath.thumbImagePath(filePath: data.poster_filename_v, size: type.size, isAdult: self.isAdult)
        tagData = TagData().setData(data: data, isAdult: self.isAdult)
        index = idx
        epsdId = data.epsd_id
        synopsisType = SynopsisType(value: data.synon_typ_cd)
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.sris.rawValue,
            epsdId: data.epsd_id, epsdRsluId: "", prdPrcId: data.prd_prc_id, kidZone:data.kids_yn)
        
        return self
    }
    
    
    func setData(data:PackageContentsItem, prdPrcId:String, cardType:BlockData.CardType = .smallPoster ,idx:Int = -1) -> PosterData {
        setCardType(cardType)
        title = data.title
        synopsisType = SynopsisType(value: data.synon_typ_cd)
        isAdult = EuxpNetwork.adultCodes.contains(data.adlt_lvl_cd)
        watchLv = data.wat_lvl_cd?.toInt() ?? 0
        tagData = TagData().setData(data: data, isAdult: self.isAdult)
        originImage = data.poster_filename_v
        image = ImagePath.thumbImagePath(filePath: data.poster_filename_v, size: type.size, isAdult: self.isAdult)
        
        index = idx
        epsdId = data.epsd_id
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.sris.rawValue,
            epsdId: data.epsd_id, epsdRsluId: "", prdPrcId: prdPrcId , kidZone:nil)
        
        return self
    }
    
    func setData(data:BookMarkItem, cardType:BlockData.CardType = .smallPoster ,idx:Int = -1) -> PosterData {
        setCardType(cardType)
        title = data.title
        epsdId = data.epsd_id
        isAdult = data.adult?.toBool() ?? false
        watchLv = data.level?.toInt() ?? 0
        tagData = TagData().setData(data: data, isAdult: self.isAdult)
        originImage = data.poster
        image = ImagePath.thumbImagePath(filePath: data.poster, size: type.size, isAdult: self.isAdult)
        
        index = idx
        
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.sris.rawValue,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id, prdPrcId: "", kidZone:data.yn_kzone)
        return self
    }
    
    func setData(data:WatchItem, cardType:BlockData.CardType = .smallPoster ,idx:Int = -1) -> PosterData {
        setCardType(cardType)
        title = data.title
        epsdId = data.epsd_id
        isAdult = data.adult?.toBool() ?? false
        watchLv = data.level?.toInt() ?? 0
        tagData = TagData().setData(data: data, isAdult: self.isAdult)
        originImage = data.thumbnail
        image = ImagePath.thumbImagePath(filePath: data.thumbnail, size: type.size, isAdult: self.isAdult)
        
        index = idx
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.sris.rawValue,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id, prdPrcId: "", kidZone:nil)
        return self
    }
    
    func setData(data:CWBlockItem, cardType:BlockData.CardType = .smallPoster ,idx:Int = -1) -> PosterData {
        setCardType(cardType)
        title = data.title
        epsdId = data.epsd_id
        isAdult = EuxpNetwork.adultCodes.contains(data.adlt_lvl_cd)
        watchLv = data.wat_lvl_cd?.toInt() ?? 0
        tagData = TagData().setData(data: data, isAdult: self.isAdult)
        synopsisType = SynopsisType(value: data.synon_typ_cd)
        originImage = data.poster_filename_v
        image = ImagePath.thumbImagePath(filePath: data.poster_filename_v, size: type.size, isAdult: self.isAdult)
        
        index = idx
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.sris.rawValue,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id, prdPrcId: "", kidZone:nil)
        return self
    }
    
    func setData(data:SearchPopularityVodItem, idx:Int = -1) -> PosterData {
        title = data.title
        epsdId = data.epsd_id
        //isAdult = data.adult?.toBool() ?? false
        watchLv = data.level?.toInt() ?? 0
        tagData = TagData().setData(data: data, isAdult: self.isAdult)
        originImage = data.poster
        image = ImagePath.thumbImagePath(filePath: data.poster , size: type.size, isAdult: self.isAdult)
        
        index = idx
        synopsisType = SynopsisType(value: data.synon_typ_cd)
        synopsisData = .init(
            srisId: nil, searchType: EuxpNetwork.SearchType.sris.rawValue,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id, prdPrcId: "", kidZone:nil)
        return self
    }
    
    func setData(data:CategoryVodItem, cardType:BlockData.CardType = .smallPoster ,idx:Int = -1) -> PosterData {
        setCardType(cardType)
        title = data.title
        watchLv = data.level?.toInt() ?? 0
        tagData = TagData().setData(data: data, isAdult: self.isAdult)
        synopsisType = SynopsisType(value: data.synon_typ_cd)
        originImage = data.poster
        image = ImagePath.thumbImagePath(filePath: data.poster, size: type.size, isAdult: self.isAdult)
        
        index = idx
        epsdId = data.epsd_id
        synopsisData = .init(
            srisId: nil, searchType: EuxpNetwork.SearchType.sris.rawValue,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id, prdPrcId: "", kidZone:nil)
        
        return self
    }
    
    func setData(data:CategoryPeopleItem, cardType:BlockData.CardType = .smallPoster ,idx:Int = -1) -> PosterData {
        setCardType(cardType)
        title = data.title
        index = idx
        prsId = data.prs_id
        return self
    }
    
    func setRank(_ idx:Int){
        if self.tagData == nil {
            self.tagData = TagData().setRank(idx)
        } else{
            self.tagData?.setRank(idx)
        }
    }
    
    private func setCardType(_ cardType:BlockData.CardType){
        self.isBookmark = (cardType == .bookmarkedPoster) ? true : nil
        
        switch cardType {
        case .bigPoster: type = .big
        case .smallPoster: type = .small
        default: type = .small
        }
    }
    
    fileprivate func updatedImage(){
        image = ImagePath.thumbImagePath(filePath: self.originImage, size: type.size, isAdult: self.isAdult)
    }
    
    fileprivate func setCardType(width:CGFloat, height:CGFloat, padding:CGFloat) -> PosterData {
        self.type = .cell(CGSize(width: width, height: height), padding)
        return self
    }
    
    func setDummy(_ idx:Int = -1) -> PosterData {
        title = "[Q&A] 이민?레나채널 삭제 안하는 이유?외국인남친?"
        subTitle = "subTitlesubTitlesubTitle"
        index = idx
        return self
    }
    
    func setDummyBig(_ idx:Int = -1) -> PosterData {
        title = "[Q&A] 이민?레나채널 삭제 안하는 이유?외국인남친?"
        subTitle = "subTitlesubTitlesubTitle"
        index = idx
        type = .big
        return self
    }
    
    func setDummyBanner(_ idx:Int = -1) -> PosterData {
        index = idx
        type = .banner
        image = Asset.noImg4_3
        return self
    }
}

enum PosterType {
    case small, big, banner, cell(CGSize, CGFloat)
    var size:CGSize {
        get{
            switch self {
            case .small: return ListItem.poster.type01
            case .big: return ListItem.poster.type02
            case .banner: return ListItem.poster.type03
            case .cell(let size, _ ): return size
            }
        }
    }
}
extension PosterList{
    static let headerSize:Int = 2
    static let spacing:CGFloat = Dimen.margin.tiny
}

struct PosterList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var banners:[BannerData]? = nil
    var datas:[PosterData]
    var contentID:String? = nil
    var useTracking:Bool = false
    var margin:CGFloat = Dimen.margin.thin
    var action: ((_ data:PosterData) -> Void)? = nil
    
   
    @State var subDataSets:[PosterDataSet]? = nil
    
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: 0,
            marginHorizontal: self.margin,
            spacing: 0,
            isRecycle: true, //self.banners?.isEmpty == false ? false : true,
            useTracking: self.useTracking
            ){
            if banners?.isEmpty == false, let banners = self.banners {
                ForEach(banners) { data in
                    BannerItem(data: data)
                        .modifier(HolizentalListRowInset(spacing: Self.spacing))
                }
                if let subDataSets = self.subDataSets {
                    ForEach(subDataSets) {sets in
                        HStack(spacing:Self.spacing){
                            ForEach(sets.datas) { data in
                                PosterItem( data:data )
                                    .onTapGesture {
                                        self.onTap(data: data)
                                    }
                            }
                        }
                        .modifier(HolizentalListRowInset(spacing: Self.spacing))
                    }
                }
            } else {
                ForEach(self.datas) { data in
                    PosterItem( data:data , isSelected: self.contentID == nil
                                    ? false
                                    : self.contentID == data.epsdId)
                        .modifier(HolizentalListRowInset(spacing: Self.spacing))
                        .onTapGesture {
                            self.onTap(data: data)
                        }
                }
            }
        }
        .onAppear{
            guard let banners = self.banners else {return}
            if banners.isEmpty {return}
            self.onBindingData(datas: self.datas)
        }
    }//body
    
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
    }
    
    func onTap(data:PosterData)  {
        if let action = self.action {
            action(data)
        }else{
            if let synopsisData = data.synopsisData {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject( data.synopsisType == .package ? .synopsisPackage : .synopsis)
                        .addParam(key: .data, value: synopsisData)
                        .addParam(key: .watchLv, value: data.watchLv)
                )
            } else {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.person)
                        .addParam(key: .data, value: data)
                        .addParam(key: .watchLv, value: data.watchLv)
                )
            }
        }
    }
}

struct PosterViewList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[PosterData]
    var contentID:String? = nil
    var useTracking:Bool = false
    var hasAuthority:Bool = false
    var margin:CGFloat = Dimen.margin.thin
    var action: ((_ data:PosterData) -> Void)? = nil
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: 0,
            marginHorizontal: self.margin,
            spacing: Dimen.margin.tiny,
            isRecycle:  true,
            useTracking: self.useTracking
            ){
            ForEach(self.datas) { data in
                PosterViewItem( data:data , isSelected: self.contentID == nil
                                ? false
                                : self.contentID == data.epsdId,
                                hasAuthority: self.hasAuthority
                                )
                .onTapGesture {
                    if let action = self.action {
                        action(data)
                    }
                }
            }
        }
    }//body
}


struct PosterDataSet:Identifiable {
    private(set) var id = UUID().uuidString
    var count:Int = 2
    var datas:[PosterData] = []
    var isFull = false
    var index:Int = -1
}

extension PosterSet{
    static let padding:CGFloat = Dimen.margin.thin
    static func listSize(data:PosterDataSet, screenWidth:CGFloat ) -> CGSize{
        let datas = data.datas
        let ratio = datas.first!.type.size.height / datas.first!.type.size.width
        let count = CGFloat(data.count)
        let w = screenWidth - ( padding * 2) 
        let cellW = ( w - (padding*(count-1)) ) / count
        let cellH = round(cellW * ratio)
        
        return CGSize(width: cellW, height: cellH )
    }
}

struct PosterSet: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var pageObservable:PageObservable = PageObservable()
    var data:PosterDataSet
    var screenSize:CGFloat? = nil
    var action: ((_ data:PosterData) -> Void)? = nil
    
    @State var cellDatas:[PosterData] = []
    @State var isUiActive:Bool = true
    var body: some View {
        HStack(spacing: Self.padding){
            if self.isUiActive {
                ForEach(self.cellDatas) { data in
                    PosterItem( data:data )
                    .onTapGesture {
                        if let action = self.action {
                            action(data)
                        }else{
                            if let synopsisData = data.synopsisData {
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject( data.synopsisType == .package ? .synopsisPackage : .synopsis)
                                        .addParam(key: .data, value: synopsisData)
                                        .addParam(key: .watchLv, value: data.watchLv)
                                )
                            } else {
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.person)
                                        .addParam(key: .data, value: data)
                                        .addParam(key: .watchLv, value: data.watchLv)
                                )
                            }
                        }
                        
                    }
                }
                if !self.data.isFull && self.data.count > 1 {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, Self.padding)
        .frame(width: self.screenSize ?? self.sceneObserver.screenSize.width)
        .onAppear {
            if self.data.datas.isEmpty { return }
            let size = Self.listSize(data: self.data, screenWidth: self.screenSize ?? sceneObserver.screenSize.width)
            self.cellDatas = self.data.datas.map{
                $0.setCardType(width: size.width, height: size.height, padding: Self.padding)
            }
        }
        .onReceive(self.pageObservable.$layer ){ layer  in
            switch layer {
            case .bottom : self.isUiActive = false
            case .top, .below : self.isUiActive = true
            }
        }
    }//body
}


struct PosterItem: PageView {
    @EnvironmentObject var repository:Repository
    var data:PosterData
    var isSelected:Bool = false
    @State var isBookmark:Bool? = nil
    var body: some View {
        ZStack(alignment: .topLeading){
            
            ImageView(url: self.data.image, contentMode: .fit, noImg: Asset.noImg9_16)
                .modifier(MatchParent())
            
            if let tag = self.data.tagData {
                Tag(data: tag)
                    .modifier(MatchParent())
            }
            if self.isBookmark != nil , let synop = self.data.synopsisData  {
                BookMarkButton(
                    data:synop,
                    isSimple:true,
                    isBookmark: self.$isBookmark
                ){ ac in
                    self.data.isBookmark = ac
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .overlay(
           Rectangle()
            .stroke(
                self.isSelected ? Color.brand.primary : Color.transparent.clear,
                lineWidth: Dimen.stroke.medium)
        )
        .frame(
            width: self.data.type.size.width,
            height: self.data.type.size.height)
        .onReceive(self.repository.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .updatedWatchLv : self.data.updatedImage()
            default : break
            }
        }
        .background(Color.app.blueLight)
        .clipped()
        .onAppear(){
            self.isBookmark = self.data.isBookmark
        }
        
        
    }
}

struct PosterViewItem: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    var data:PosterData
    var isSelected:Bool = false
    var hasAuthority:Bool = false
    @State var isBookmark:Bool? = nil
    var body: some View {
        VStack( spacing:Dimen.margin.thin){
            PosterItem(data: self.data, isSelected:self.isSelected)
            if self.isSelected {
                FillButton(
                    text: self.hasAuthority ? String.button.directview : String.button.preview,
                    strokeWidth: 1){ _ in
                    
                    if let synopsisData = data.synopsisData {
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject( data.synopsisType == .package ? .synopsisPackage : .synopsis)
                                .addParam(key: .data, value: synopsisData)
                                .addParam(key: .watchLv, value: data.watchLv)
                        )
                    }
                }
            }
        }
    }
    
}


#if DEBUG
struct PosterList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PosterList( datas: [
                PosterData().setDummyBanner(0),
                PosterData().setDummy(),
                PosterData().setDummy(),
                PosterData().setDummy()
            ])
            .environmentObject(PagePresenter()).modifier(MatchParent())
        }
    }
}
#endif
