//
//  MonthlyInfo.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/22.
//

import Foundation
import SwiftUI
struct MonthlyGuide:PageComponent {
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    
    var data: PurchaseTicketData 
    var body :some View {
        HStack(spacing:0){
            HStack(spacing:DimenKids.margin.tiny){
                Image(AssetKids.gnbTop.monthly)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(width: DimenKids.icon.thin, height: DimenKids.icon.thin)
                Text(String.app.ppmSubscribe)
                    .modifier(BoldTextStyleKids(size: Font.sizeKids.lightExtra, color: Color.app.brownDeep))
                
                if let period = data.period {
                    Text("|")
                        .modifier(BoldTextStyleKids(size: Font.sizeKids.lightExtra, color: Color.app.brownDeep.opacity(0.6)))
                    Text(period)
                        .modifier(BoldTextStyleKids(size: Font.sizeKids.lightExtra, color: Color.app.sepiaDeep))
                }
            }
            .padding(.horizontal, DimenKids.margin.thin)
            .frame(height: DimenKids.tab.regular)
            .background(Color.app.ivoryLight)
            .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.light))
            Spacer()
        }
        .modifier(ContentHorizontalEdgesKids())
        
    }

}

#if DEBUG
struct MonthlyGuide_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            MonthlyGuide(data: PurchaseTicketData())
                .environmentObject(PagePresenter()).frame(width:320,height:100)

        }
    }
}
#endif
