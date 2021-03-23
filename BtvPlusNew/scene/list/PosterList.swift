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
    private(set) var title: String? = nil
    private(set) var subTitle: String? = nil
    private(set) var epsdId:String? = nil
    private(set) var prsId:String? = nil
    private(set) var synopsisType:SynopsisType = .title
    private(set) var type:PosterType = .small
    private(set) var synopsisData:SynopsisData? = nil
    
    func setData(data:ContentItem, cardType:BlockData.CardType = .smallPoster ,idx:Int = -1) -> PosterData {
        setCardType(cardType)
        title = data.title
        if let poster = data.poster_filename_v {
            image = ImagePath.thumbImagePath(filePath: poster, size: type.size)
        }
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
        if let poster = data.poster_filename_v {
            image = ImagePath.thumbImagePath(filePath: poster, size: type.size)
        }
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
        if let poster = data.poster {
            image = ImagePath.thumbImagePath(filePath: poster, size: type.size)
        }
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
        if let poster = data.thumbnail {
            image = ImagePath.thumbImagePath(filePath: poster, size: type.size)
        }
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
        synopsisType = SynopsisType(value: data.synon_typ_cd)
        if let poster = data.poster_filename_v {
            image = ImagePath.thumbImagePath(filePath: poster, size: type.size)
        }
        index = idx
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.sris.rawValue,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id, prdPrcId: "", kidZone:nil)
        return self
    }
    
    func setData(data:SearchPopularityVodItem, idx:Int = -1) -> PosterData {
        title = data.title
        epsdId = data.epsd_id
        if let poster = data.poster {
            image = ImagePath.thumbImagePath(filePath: poster, size: type.size)
        }
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
        synopsisType = SynopsisType(value: data.synon_typ_cd)
        if let poster = data.poster {
            image = ImagePath.thumbImagePath(filePath: poster, size: type.size)
        }
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
    
    private func setCardType(_ cardType:BlockData.CardType){
        switch cardType {
        case .bigPoster: type = .big
        case .smallPoster: type = .small
        default: type = .small
        }
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
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: 0,
            marginHorizontal: self.margin,
            spacing: Dimen.margin.tiny,
            isRecycle: self.banners?.isEmpty == false ? false : true,
            useTracking: self.useTracking
            ){
            if let banners = self.banners {
                ForEach(banners) { data in
                    BannerItem(data: data)
                }
            }
            ForEach(self.datas) { data in
                PosterItem( data:data , isSelected: self.contentID == nil
                                ? false
                                : self.contentID == data.epsdId)
                .onTapGesture {
                    if let action = self.action {
                        action(data)
                    }else{
                        if let synopsisData = data.synopsisData {
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject( data.synopsisType == .package ? .synopsisPackage : .synopsis)
                                    .addParam(key: .data, value: synopsisData)
                            )
                        } else {
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.person)
                                    .addParam(key: .data, value: data)
                            )
                        }
                    }
                }
            }
        }
    }//body
}


struct PosterDataSet:Identifiable {
    private(set) var id = UUID().uuidString
    var count:Int = 3
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
                                )
                            } else {
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.person)
                                        .addParam(key: .data, value: data)
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
        .frame(width: self.sceneObserver.screenSize.width)
        .onAppear {
            if self.data.datas.isEmpty { return }
            let size = Self.listSize(data: self.data, screenWidth: sceneObserver.screenSize.width)
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
    var data:PosterData
    var isSelected:Bool = false
    var body: some View {
        ZStack{
            if self.data.image == nil {
                Image(Asset.noImg9_16)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .modifier(MatchParent())
            } else {
                ImageView(url: self.data.image!, contentMode: .fill, noImg: Asset.noImg9_16)
                    .modifier(MatchParent())
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
        .background(Color.app.blueLight)
        .clipped()
        .onAppear(){
           
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

