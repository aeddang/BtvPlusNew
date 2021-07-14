//
//  KidsHeader.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/13.
//

import Foundation
import SwiftUI

class KidsMyItemData: KidsHomeBlockListData {
    func setData(data:BlockItem) -> KidsMyItemData{
        self.type = .myHeader
        return self
    }
}
extension KidsMyItem{
    static let size:CGSize = SystemEnvironment.isTablet ? CGSize(width: 196, height: 339) : CGSize(width: 101, height: 177)
    static let profile:CGSize = SystemEnvironment.isTablet ? CGSize(width: 103, height: 103) : CGSize(width: 55, height: 55)
    static let profileTop:CGFloat = SystemEnvironment.isTablet ? 22 : 38
}

struct KidsMyItem:PageView  {
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    var data:KidsMyItemData
    @State var profileImg:String? = nil
    @State var nick:String = ""
    @State var age:String = ""
    var body :some View {
        ZStack(alignment: .top){
            
            Image( profileImg == nil ? AssetKids.image.myBlockBgEmpty :  AssetKids.image.myBlockBg)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(
                    width: Self.size.width,
                   height: Self.size.height)
                .padding(.top, Self.profileTop)
            
            if let profile = self.profileImg {
                ZStack(alignment: .bottom){
                    Image(profile)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Self.profile.width,
                               height: Self.profile.height)
                    HStack( spacing: DimenKids.margin.microExtra){
                        Text(self.nick)
                            .modifier(BoldTextStyleKids(size: Font.sizeKids.microUltra, color: Color.app.white))
                            .lineLimit(1)
                        Text(self.age)
                            .modifier(BoldTextStyleKids(size: Font.sizeKids.microUltra, color: Color.app.white))
                            .fixedSize()
                    }
                    .padding(.vertical, DimenKids.margin.microExtra)
                    .padding(.horizontal, DimenKids.margin.tiny)
                    .background(Color.app.brownDeep)
                    .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.regular))
                    .padding(.bottom, -DimenKids.margin.tinyExtra)
                }
                .padding(.top, DimenKids.margin.light)
            }
        }
        .onReceive(self.pairing.$kid) { kid in
            if let kid = kid {
                self.profileImg = AssetKids.characterGnbList[kid.characterIdx]
                self.nick = kid.nickName
                
                if let age = kid.age {
                    self.age = "(" + age.description + String.app.ageCount + ")"
                } else {
                    self.age = ""
                }
                
            } else {
                self.profileImg = nil
                self.nick = ""
                self.age = ""
            }
        }
        .onTapGesture {
            let status = self.pairing.status
            if status != .pairing {
                self.appSceneObserver.alert = .needPairing()
                return
            }
            if self.pairing.kids.isEmpty {
                self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.editKid))
            } else if self.pairing.kid == nil {
                self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.kidsProfileManagement))
            } else {
                self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.kidsMy))
            }
        }
    }
}
