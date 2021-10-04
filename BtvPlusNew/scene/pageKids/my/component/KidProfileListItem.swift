//
//  KidProfile.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/03.
//

import Foundation
import SwiftUI



struct KidProfileListItem: PageComponent{
    @EnvironmentObject var naviLogManager:NaviLogManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var data:Kid
    var isSelected:Bool = false
    
    @State var profileImg:String = AssetKids.image.noProfile
    @State var title:String? = nil
    @State var age:String? = nil
    @State var gender:String? = nil
   
    var body: some View {
        ZStack{
            Image(self.isSelected ? AssetKids.shape.profileBgOn : AssetKids.shape.profileBgOff)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .modifier(MatchParent())
            VStack(alignment: .center ,spacing:0){
                ZStack(alignment: .bottomTrailing){
                    Image(self.profileImg)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: DimenKids.item.profileRegist.width,
                               height: DimenKids.item.profileRegist.height)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                            .stroke(Color.app.white,lineWidth: DimenKids.stroke.mediumExtra)
                        )
                        .padding(.horizontal, DimenKids.margin.micro)
                    Image(self.isSelected ? AssetKids.icon.crownOn : AssetKids.icon.crownOff)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: DimenKids.icon.light,
                               height: DimenKids.icon.light)
                        
                }
                
                HStack(spacing:DimenKids.margin.micro){
                    if let title = self.title {
                        Text(title)
                            .modifier(BoldTextStyleKids(
                                        size: SystemEnvironment.isTablet ? Font.sizeKids.thin : Font.sizeKids.regularExtra ,
                                        color: self.isSelected ? Color.app.white : Color.app.brownExtra))
                            .padding(.leading, DimenKids.icon.tinyExtra)
                    }
                    Button(action: {
                        self.naviLogManager.actionLog(
                            .clickProfileEdit,
                            actionBody: .init(menu_name:String.kidsTitle.registKidManagement, category:"프로필수정"))
                        
                        self.pagePresenter.openPopup(
                            PageKidsProvider.getPageObject(.editKid)
                                .addParam(key: .data, value: self.data)
                        )
                        
                    }) {
                        Image(self.isSelected ? AssetKids.icon.editProfileOn : AssetKids.icon.editProfileOff)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: DimenKids.icon.tinyExtra,
                                   height: DimenKids.icon.tinyExtra)
                    }
                }
                .padding(.top, DimenKids.margin.thin)
                if let gender = self.gender, let age = self.age {
                    Text(gender + " | " + age)
                        .modifier(BoldTextStyleKids(
                                    size: SystemEnvironment.isTablet ? Font.sizeKids.microUltra : Font.sizeKids.tinyExtra ,
                                    color: self.isSelected ? Color.app.white : Color.app.brownExtra))
                        .padding(.top, DimenKids.margin.thin)
                }
            }
        }
        .frame(
            width: DimenKids.item.profileList.width,
            height: DimenKids.item.profileList.height)
        
        .onReceive(self.data.$age) { age in
            guard let age = age else {return}
            self.age = age.description + String.app.ageCount
        }
        .onReceive(self.data.$characterIdx) { idx in
            self.profileImg = AssetKids.characterList[idx]
            self.gender = self.data.gender
        }
        .onReceive(self.data.$nickName) { name in
            self.title = name
        }
        .onAppear(){
        }
        
    }
}

#if DEBUG
struct KidProfileListItem_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            KidProfileListItem(data: Kid())
                .environmentObject(PagePresenter())
                
        }
    }
}
#endif
