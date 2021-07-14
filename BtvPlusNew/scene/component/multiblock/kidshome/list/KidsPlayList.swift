//
//  KidsHeader.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/13.
//

import Foundation
import SwiftUI

enum KidsPlayType {
    case play, english , tale, create, subject, unknown(String? = nil)
    static func getType(_ value:String?)->KidsPlayType{
        switch value {
        case "512": return .play
        case "513": return .english
        case "514": return .tale
        case "515": return .create
        case "516": return .subject
        default : return .unknown(value)
        }
    }
    var noImage:String {
        get{
            switch self {
            case .play: return AssetKids.image.homeCardBg1
            case .english: return AssetKids.image.homeCardBg2
            case .tale: return AssetKids.image.homeCardBg3
            case .create: return AssetKids.image.homeCardBg4
            case .subject: return AssetKids.image.homeCardBg5
            default : return  AssetKids.image.homeCardBg1
            }
        }
    }
}

class KidsPlayListData: KidsHomeBlockListData {
    private(set) var title:String? = nil
    private(set) var menuId:String? = nil
    private(set) var cwCallId:String? = nil
    
    private(set) var datas:[KidsPlayListItemData] = []
    func setData(data:BlockItem) -> KidsPlayListData{
        self.type = .playList
        
        self.title = data.menu_nm
        self.menuId = data.menu_id
        self.cwCallId = data.cw_call_id_val
        self.datas = data.blocks?.map{KidsPlayListItemData().setData(data: $0)} ?? []
        return self
    }
}

class KidsPlayListItemData: InfinityData {
    private(set) var title:String? = nil
    private(set) var menuId:String? = nil
    private(set) var cwCallId:String? = nil
    private(set) var playType:KidsPlayType = .unknown()
    fileprivate(set) var poster:PosterData? = nil
    private(set) var defaultImage:String = AssetKids.image.homeCardBg1
    private(set) var blocks:[BlockItem] = []
    private(set) var firstMenuId:String? = nil
    private(set) var firstCwCallId:String? = nil
    func setData(data:BlockItem) -> KidsPlayListItemData{
        self.playType = KidsPlayType.getType(data.svc_prop_cd)
        self.defaultImage = self.playType.noImage
        self.title = data.menu_nm
        self.menuId = data.menu_id
        self.cwCallId = data.cw_call_id_val
        self.blocks = data.blocks ?? []
        if let firstItem = data.blocks?.first {
            firstMenuId = firstItem.menu_id
            firstCwCallId = firstItem.cw_call_id_val
        }
        return self
    }
}


struct KidsPlayList:PageView  {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    var data:KidsPlayListData
    @State var title:String = String.kidsText.kidsHomeNoProfile
    var body :some View {
        VStack(alignment: .leading , spacing:DimenKids.margin.thinUltra){
            Text(self.title)
                .modifier(BlockTitleKids())
                .lineLimit(1)
                .fixedSize()
            HStack(spacing: DimenKids.margin.thinExtra){
                ForEach(self.data.datas) { data in
                    KidsPlayListItem(data: data)
                }
            }
        }
        .onReceive(self.pairing.$kid) { kid in
            if let kid = kid {
                self.title = String.app.forSir.replace(kid.nickName) + (data.title ?? "")
            } else {
                self.title = String.kidsText.kidsHomeNoProfile
            }
        }
        
    }
}


extension KidsPlayListItem{
    static let size:CGSize = SystemEnvironment.isTablet ? CGSize(width: 221, height: 257) : CGSize(width: 115, height: 134)
    static let imgSize:CGSize = SystemEnvironment.isTablet ? CGSize(width: 165, height: 230) : CGSize(width: 83, height: 116)
    //mediumRectExtra
}

struct KidsPlayListItem:PageView  {
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    var data:KidsPlayListItemData
    @State var profileImg:String? = nil
    @State var poster:PosterData? = nil
    var body :some View {
        VStack(spacing:DimenKids.margin.light){
            RectButtonKids(
                text: self.data.title ?? "",
                trailIcon: AssetKids.icon.cardMore,
                textModifier: TextModifierKids(
                    family:Font.familyKids.bold,
                    size: Font.sizeKids.tiny,
                    color: Color.app.brownDeep
                ),
                size: DimenKids.button.mediumRectExtra,
                cornerRadius: DimenKids.radius.medium
            
            ){ _ in
                
            }
            ZStack{
                ZStack{
                    if let img = self.poster?.image {
                        ImageView(url:img ,contentMode: .fill, noImg: self.data.defaultImage)
                            .modifier(MatchParent())
                    } else {
                        Image(self.data.defaultImage)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .modifier(MatchParent())
                    }
                     if let tag = self.poster?.tagData {
                        Tag(data: tag).modifier(MatchParent())
                    }
                }
                .frame(
                    width: Self.imgSize.width,
                    height: Self.imgSize.height)
                
                Image(AssetKids.image.cardBlockBg)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .modifier(MatchParent())
            }
            .frame(
                width: Self.size.width,
                height: Self.size.height)
            
        }
        .onReceive(dataProvider.$result) { res in
            if res?.id != self.data.id { return }
            guard let resData = res?.data as? CWGridKids else { return }
            guard let grids = resData.grid else { return }
            guard let block = grids.first?.block?.first else { return }
            let poster = PosterData().setData(data: block)
            self.data.poster = poster
            withAnimation{
                self.poster = poster
            }
        }
        .onAppear(){
            if let poster = self.data.poster {
                withAnimation{
                    self.poster = poster
                }
            } else {
                if let kid = self.pairing.kid {
                    self.dataProvider.requestData(
                        q: .init(id: self.data.id,
                                 type: .getCWGridKids(
                                    kid,
                                    self.data.firstCwCallId,
                                    nil),
                                isOptional: true))
                }
            }
            
        }
    }
}


