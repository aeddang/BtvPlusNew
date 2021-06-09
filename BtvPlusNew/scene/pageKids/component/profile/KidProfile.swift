//
//  KidProfile.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/03.
//

import Foundation
//
//  TopTab.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct KidProfile: PageComponent{
   
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    
    @State var profileImg:String = AssetKids.image.noProfile
    @State var title:String? = nil
    var body: some View {
        HStack(alignment: .center ,spacing:0){
            Image(self.profileImg)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: DimenKids.item.profile.width,
                       height: DimenKids.item.profile.height)
            if let title = self.title {
                Text(title)
                    .modifier(BoldTextStyleKids(size: Font.sizeKids.thinExtra, color: Color.app.brownLight))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, DimenKids.margin.thinExtra)
            } else {
                Button(action: {
                    self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.registKid))
                    
                }) {
                    Image(AssetKids.gnbTop.addProfile)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: SystemEnvironment.isTablet ? 186 : 96,
                               height: SystemEnvironment.isTablet ? 32 : 20)
                }
                .padding(.leading, DimenKids.margin.micro)
            }
            
        }
        .onReceive(self.pairing.$kid) { kid in
            if let kid = kid {
                self.profileImg = AssetKids.characterList[kid.characterIdx]
                if let age = kid.age {
                    self.title = kid.nickName + " | " + age.description + String.app.ageCount
                } else {
                    self.title = kid.nickName
                }
            } else {
                self.profileImg = AssetKids.image.noProfile
                self.title = nil
            }
        }
        .onAppear(){
        }
        
    }
}

#if DEBUG
struct KidProfile_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            KidProfile()
                .environmentObject(PagePresenter())
                .environmentObject(Pairing())
            
                
        }
    }
}
#endif
