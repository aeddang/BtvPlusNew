//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

class PosterData:InfinityData{
    private(set) var image: String = Asset.noImg9_16
    private(set) var title: String? = nil
    private(set) var subTitle: String? = nil
    private(set) var type:PosterType = .small
    private(set) var synopsisData:SynopsisData? = nil
    
    func setData(data:ContentItem, cardType:BlockData.CardType = .smallPoster ,idx:Int = -1) -> PosterData {
        setCardType(cardType)
        title = data.title
        if let poster = data.poster_filename_v {
            image = ImagePath.thumbImagePath(filePath: poster, size: type.size)
        }
        index = idx
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.sris.rawValue,
            epsdId: data.epsd_id, epsdRsluId: "", prdPrcId: data.prd_prc_id, kidZone:data.kids_yn)
        
        return self
    }
    
    func setData(data:BookMarkItem, cardType:BlockData.CardType = .smallPoster ,idx:Int = -1) -> PosterData {
        setCardType(cardType)
        title = data.title
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
        if let poster = data.poster_filename_v {
            image = ImagePath.thumbImagePath(filePath: poster, size: type.size)
        }
        index = idx
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.sris.rawValue,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id, prdPrcId: "", kidZone:nil)
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
    var datas:[PosterData]
    var useTracking:Bool = false
    var margin:CGFloat = Dimen.margin.thin
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: 0,
            marginHorizontal: self.margin,
            spacing: Dimen.margin.tiny,
            isRecycle: true,
            useTracking: self.useTracking
            ){
            ForEach(self.datas) { data in
                PosterItem( data:data )
                .onTapGesture {
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.synopsis)
                            .addParam(key: .data, value: data.synopsisData)
                    )
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
    static func listSize(data:PosterDataSet, screenWidth:CGFloat) -> CGSize{
        let datas = data.datas
        let ratio = datas.first!.type.size.height / datas.first!.type.size.width
        let count = CGFloat(data.count)
        let w = screenWidth - ( padding * 2)
        let cellW = ( w - (padding*(count-1)) ) / count
        let cellH = cellW * ratio
        
        return CGSize(width: cellW, height: cellH )
    }
}

struct PosterSet: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    var data:PosterDataSet
    @State var cellDatas:[PosterData] = []
    var body: some View {
        HStack(spacing: Self.padding){
            ForEach(self.cellDatas) { data in
                PosterItem( data:data )

                .onTapGesture {
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.synopsis)
                            .addParam(key: .data, value: data.synopsisData)
                    )
                }
            }
            if !self.data.isFull {
                Spacer()
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
    }//body
}

struct PosterItem: PageView {
    var data:PosterData
    var body: some View {
        ZStack{
            ImageView(url: self.data.image, contentMode: .fit, noImg: Asset.noImg9_16)
                .modifier(MatchParent())
        }
        .frame(
            width: self.data.type.size.width,
            height: self.data.type.size.height)
        .background(Color.app.blueLight)
        .clipped()
        
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

