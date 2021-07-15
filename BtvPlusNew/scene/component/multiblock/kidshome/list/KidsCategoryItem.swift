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
   
    fileprivate(set) var poster:KidStudyRecommandData? = nil
    func setData(data:BlockItem) -> KidsCategoryItemData{
        self.type = .cateHeader
        self.title = data.menu_nm
        self.svcPropCd = data.svc_prop_cd
       
        return self
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
    @EnvironmentObject var appSceneObserver:AppSceneObserver
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
                        Image(AssetKids.noImg9_16)
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
            if self.pairing.kids.isEmpty {
                self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.editKid))
            } else if self.pairing.kid == nil {
                self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.kidsProfileManagement))
            } else {
                self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.kidsMy))
            }
        }
        .onReceive(self.pairing.$kid) { kid in
            if let kid = kid {
                self.profileImg = AssetKids.characterCateList[kid.characterIdx]
            } else {
                self.profileImg = nil
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
        .onAppear(){
            
            
        }
        
    }
}
