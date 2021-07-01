//
//  KidProfile.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/03.
//

import Foundation
import SwiftUI



struct KidProfileBox: PageComponent{
   
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var data:Kid
    var isEmpty:Bool = false
    
    @State var profileImg:String = AssetKids.image.noProfile
    @State var title:String? = nil
    @State var age:String? = nil
   
   
    var body: some View {
        ZStack{
            Image( AssetKids.shape.profileBg)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .modifier(MatchParent())
            VStack(alignment: .center ,spacing:DimenKids.margin.light){
                Image(self.isEmpty ? AssetKids.image.noProfile : self.profileImg)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: DimenKids.item.profileBoxImg.width,
                           height: DimenKids.item.profileBoxImg.height)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                        .stroke(Color.app.white,lineWidth: DimenKids.stroke.mediumExtra)
                    )
                    .padding(.top, self.isEmpty ? DimenKids.margin.tiny : 0)
                if self.isEmpty {
                    Text(String.kidsText.kidsMyNoProfile)
                        .modifier(
                            BoldTextStyleKids(
                                size: SystemEnvironment.isTablet ? Font.sizeKids.tiny : Font.sizeKids.thin ,
                                color: Color.app.white ))
                        .multilineTextAlignment(.center)
                    
                } else {
                    HStack(alignment: .center ,spacing:DimenKids.margin.micro){
                        if let title = self.title {
                            Text(title)
                                .modifier(
                                    BoldTextStyleKids(
                                        size: SystemEnvironment.isTablet ? Font.sizeKids.tiny : Font.sizeKids.thin ,
                                        color: Color.app.white ))
                                .lineLimit(1)
                        }
                        Spacer()
                            .modifier(LineVertical(width: DimenKids.line.light, opacity: 0.6))
                            .frame(height:DimenKids.margin.thin)
                        
                        if let age = self.age {
                            Text(age)
                                .modifier(
                                    BoldTextStyleKids(
                                        size: SystemEnvironment.isTablet ? Font.sizeKids.tiny : Font.sizeKids.thin ,
                                        color: Color.app.white ))
                                .lineLimit(1)
                                .fixedSize()
                        }
                    }
                }
            }
        }
        .frame(
            width: DimenKids.item.profileBox.width,
            height: DimenKids.item.profileBox.height)
        
        .onReceive(self.data.$age) { age in
            guard let age = age else {return}
            self.age = age.description + String.app.ageCount
        }
        .onReceive(self.data.$characterIdx) { idx in
            self.profileImg = AssetKids.characterList[idx]
        }
        .onReceive(self.data.$nickName) { name in
            self.title = name
        }
        .onAppear(){
        }
        
    }
}

#if DEBUG
struct KidProfileListBox_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            KidProfileBox(data: Kid(), isEmpty:false)
                .environmentObject(PagePresenter())
                
        }
    }
}
#endif
