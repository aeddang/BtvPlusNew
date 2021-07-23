//
//  KidsHeader.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/13.
//

import Foundation
import SwiftUI

class KidsCategoryItemData: KidsHomeBlockListData {
    private(set) var title:String? = nil
    private(set) var svcPropCd:String? = nil
    private(set) var playType:KidsPlayType = .unknown()
    private(set) var blocks:[BlockItem] = []
    fileprivate(set) var poster:KidStudyRecommandData? = nil
    func setData(data:BlockItem) -> KidsCategoryItemData{
        self.playType = KidsPlayType.getType(data.svc_prop_cd)
       
        self.blocks = data.blocks ?? [data]
        self.type = .cateHeader
        self.title = data.menu_nm
        self.svcPropCd = data.svc_prop_cd

        return self
    }
    
    func setData(data:KidsPlayListItemData){
        self.blocks = data.blocks
    }
    func setData(datas:[BlockItem]?){
        self.blocks = datas ?? self.blocks
    }
}

class KidStudyRecommandData:Identifiable {
    let id:String = UUID().uuidString
    var image:String? = nil
    var svcPropCd:String = ""
    
    func setData(data:RecommendMenu) -> KidStudyRecommandData {
        self.image = ImagePath.thumbImagePath(filePath: data.ph_poster_url, size: ListItemKids.poster.type01)
        self.svcPropCd = data.svc_prop_cd ?? ""
        return self
    }
}

extension KidsCategoryItem{
    static let size:CGSize = SystemEnvironment.isTablet ? CGSize(width: 210, height: 344) : CGSize(width: 111, height: 179)
    static let imageSize:CGSize = SystemEnvironment.isTablet ? CGSize(width: 160, height: 222) : CGSize(width: 83, height: 116)
    static let imagePos:CGPoint = SystemEnvironment.isTablet ? CGPoint(x: 34, y: 10) : CGPoint(x: 17, y: 5)
    static let profile:CGSize = SystemEnvironment.isTablet ? CGSize(width: 130, height: 282) : CGSize(width:68, height: 153)
    static let profilePos:CGPoint = SystemEnvironment.isTablet ? CGPoint(x: 161, y: -26) : CGPoint(x: 84, y: -20)
}



struct KidsCategoryItem:PageView  {
   
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    var data:KidsCategoryItemData
    @State var profileImg:String? = nil
    @State var poster:KidStudyRecommandData? = nil
    
    var body :some View {
        ZStack(alignment: .bottomLeading){
            ZStack(alignment:.topLeading){
                ZStack(alignment:.topLeading){
                    if let img = self.poster?.image {
                        ImageView(url:img ,contentMode: .fit, noImg: AssetKids.noImg9_16, opacity: 1.0)
                            .modifier(MatchParent())
                    } else {
                        Image(self.data.playType.noImage)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .modifier(MatchParent())
                    }
                }
                .frame(
                    width: Self.imageSize.width,
                    height: Self.imageSize.height)
                .padding(.leading, Self.imagePos.x)
                .padding(.top, Self.imagePos.y)
                Image(AssetKids.image.cateBlockBg)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .modifier(MatchParent())
                
                if let title = self.data.title {
                    VStack(alignment: .center){
                        Spacer()
                        Text(title)
                            .modifier(BoldTextStyleKids(size: Font.sizeKids.thin, color:Color.app.brownDeep))
                            .lineLimit(1)
                            .padding(.horizontal, DimenKids.margin.thin)
                            .padding(.bottom, DimenKids.margin.medium)
                    }
                    .modifier(MatchParent())
                }
            }
            .frame(
                width: Self.size.width,
                height: Self.size.height)
            
            if let profileImg = self.profileImg {
            Image( profileImg )
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(
                    width: Self.profile.width,
                    height: Self.profile.height)
                .padding(.leading, Self.profilePos.x)
                .padding(.bottom, Self.profilePos.y)
            }
        }
        .frame(height: Self.size.height)
        .onTapGesture {
            self.pagePresenter.openPopup(
                PageKidsProvider.getPageObject(.kidsMultiBlock)
                    .addParam(key: .datas, value: data.blocks)
                    .addParam(key: .title, value: data.title)
                    .addParam(key: .type, value: data.playType)
            )
        }
        .onReceive(self.pairing.$kid) { kid in
            self.update(kid: kid)
        }
        .onReceive(self.pairing.$event){ evt in
            guard let evt = evt else { return }
            switch evt {
            case .editedKids :
                self.update(kid: self.pairing.kid)
            default: break
            }
        }
        .onReceive(self.pairing.$kidStudyData) { data in
            guard let studyData = data  else {
                self.data.poster = nil
                return
            }
            if let recommandData = studyData.recomm_menus?.first(where: {$0.svc_prop_cd == self.data.svcPropCd}) {
                let poster = KidStudyRecommandData().setData(data: recommandData)
                withAnimation{
                    self.poster = poster
                }
            } else {
                self.data.poster = nil
            }
        }
        .onReceive(dataProvider.$result) { res in
        
        }
        .onAppear(){
            if let playListData = self.dataProvider.bands.kidsGnbModel.playListData {
                if let find = playListData.datas.first(where: {$0.playType == self.data.playType}){
                    self.data.setData(data: find)
                }
            } else {
                if let findHome = self.dataProvider.bands.kidsGnbModel.home?
                    .blocks?.first(where: {$0.btm_bnr_blk_exps_cd == KidsHomeBlockData.code}){
        
                    if let playListData = findHome.blocks?.first(where: {$0.btm_bnr_blk_exps_cd == KidsPlayListData.code}) {
                        if let find = playListData.blocks?.first(where: {KidsPlayType.getType($0.svc_prop_cd) == self.data.playType}) {
                            self.data.setData(datas: find.blocks)
                        }
                    }
                    
                }
            }
        }
    }
    
    private func update(kid:Kid?) {
        if let kid = kid {
            self.profileImg = AssetKids.characterCateList[kid.characterIdx]
        } else {
            self.profileImg = nil
        }
    }
}
