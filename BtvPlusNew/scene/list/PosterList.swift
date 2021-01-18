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
    
    func setData(data:ContentItem, cardType:Block.CardType = .smallPoster ,idx:Int = -1) -> PosterData {
        setCardType(cardType)
        title = data.title
        if let poster = data.poster_filename_v {
            image = ImagePath.thumbImagePath(filePath: poster, size: type.size)
        }
        index = idx
        return self
    }
    
    func setData(data:BookMarkItem, cardType:Block.CardType = .smallPoster ,idx:Int = -1) -> PosterData {
        setCardType(cardType)
        title = data.title
        if let poster = data.poster {
            image = ImagePath.thumbImagePath(filePath: poster, size: type.size)
        }
        index = idx
        return self
    }
    
    private func setCardType(_ cardType:Block.CardType){
        switch cardType {
        case .bigPoster: type = .big
        case .smallPoster: type = .small
        default: type = .small
        }
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
    case small, big, banner
    var size:CGSize {
        get{
            switch self {
            case .small: return ListItem.poster.type01
            case .big: return ListItem.poster.type02
            case .banner: return ListItem.poster.type03
            }
        }
    }
        
    var padding:CGFloat {
        get{
            switch self {
            case .small: return Dimen.margin.thinExtra
            case .big: return Dimen.margin.light
            case .banner: return Dimen.margin.light
            }
        }
    }
}

struct PosterList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var viewModel: InfinityScrollModel = InfinityScrollModel()
    @Binding var datas:[PosterData]
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: 0,
            marginHorizontal: Dimen.margin.thin,
            spacing: Dimen.margin.tiny){
            ForEach(self.datas) { data in
                PosterItem( data:data )
                .onTapGesture {
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.synopsis)
                            .addParam(key: .data, value: data)
                    )
                }
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
            VStack(spacing:0){
                if self.data.title != nil {
                    Text(self.data.title!)
                        .modifier(BlackTextStyle(size: Font.size.regular))
                }
                if self.data.subTitle != nil {
                    Text(self.data.subTitle!)
                        .modifier(MediumTextStyle(size: Font.size.thin, color: Color.app.grey))
                }
            }
            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, self.data.type.padding)
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
            PosterList( datas: .constant([
                PosterData().setDummyBanner(0),
                PosterData().setDummy(),
                PosterData().setDummy(),
                PosterData().setDummy()
            ]))
            .environmentObject(PagePresenter()).modifier(MatchParent())
        }
    }
}
#endif

