//
//  KidProfile.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/03.
//

import Foundation
import SwiftUI

struct KidProfileListEmpty: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var body: some View {
        ZStack{
            Image(AssetKids.shape.profileBgOff)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .modifier(MatchParent())
            VStack(alignment: .center ,spacing:0){
                
                Button(action: {
                    self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.registKid))
                    
                }) {
                    Image( AssetKids.icon.addProfile)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: DimenKids.icon.mediumUltra,
                               height: DimenKids.icon.mediumUltra)
                }
                
                HStack(spacing:DimenKids.margin.micro){
                    Text(String.kidsText.registAddKid)
                            .modifier(BoldTextStyleKids(
                                        size: SystemEnvironment.isTablet ? Font.sizeKids.thin : Font.sizeKids.lightExtra ,
                                        color:  Color.app.brownExtra))
                        
                    
                }
                .padding(.top, DimenKids.margin.thin)
                
            }
        }
        .frame(
            width: DimenKids.item.profileList.width,
            height: DimenKids.item.profileList.height)
        
       
        .onAppear(){
        }
        
    }
}

#if DEBUG
struct KidProfileListEmpty_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            KidProfileListEmpty()
                .environmentObject(PagePresenter())
                
        }
    }
}
#endif
