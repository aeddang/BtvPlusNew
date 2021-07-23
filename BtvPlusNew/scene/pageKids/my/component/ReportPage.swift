//
//  KidProfile.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/03.
//

import Foundation
import SwiftUI

struct ReportPage: PageComponent{
   
    var name:String = ""
    var body: some View {
        VStack(alignment: .trailing){
            HStack( spacing: 0 ){
                Spacer()
                    .modifier(MatchHorizontal(height: 1))
                HStack(alignment: .center, spacing: 0){
                    ZStack(alignment: .leading){
                        Spacer().modifier(MatchHorizontal(height: 1))
                        Text( self.name )
                        .modifier(BoldTextStyleKids(
                                    size: Font.sizeKids.thin,
                                    color:  Color.app.white))
                        }
                        .lineLimit(1)
                    .padding(.leading, DimenKids.margin.thin)
                    Image(AssetKids.icon.sort)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: DimenKids.icon.micro, height: DimenKids.icon.micro)
                }
                .frame(width: SystemEnvironment.isTablet ? 150 : 78)
            }
            Spacer().modifier(MatchParent())
        }
        .padding(.all, DimenKids.margin.tiny)
        .background(Color.kids.primaryLight)
        .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.light))
        
    }
}

#if DEBUG
struct ReportPage_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            ReportPage()
                .environmentObject(PagePresenter())
                .frame(
                    width: 179,
                    height: 187)
        }
    }
}
#endif
