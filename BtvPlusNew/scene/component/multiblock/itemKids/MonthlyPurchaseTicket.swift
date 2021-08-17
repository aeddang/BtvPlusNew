//
//  MonthlyInfo.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/22.
//

import Foundation
import SwiftUI
struct MonthlyPurchaseTicket:PageComponent {
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
   
    var data:MonthlyData
    var body :some View {
        HStack(spacing:0){
            VStack(alignment: .leading, spacing:0){
                Spacer().modifier(MatchHorizontal(height: 0))
                Text(data.text ?? data.title ?? "")
                    .modifier(MediumTextStyleKids(size: Font.sizeKids.thin, color: Color.app.brownDeep))
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, DimenKids.margin.light)
            .modifier(MatchParent())
            VStack(alignment: .leading, spacing:DimenKids.margin.tiny){
                HStack(spacing:DimenKids.margin.micro){
                    if let price = data.price {
                        Image(AssetKids.icon.price)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: DimenKids.icon.microUltra, height: DimenKids.icon.microUltra)
                        Text(price)
                            .modifier(BoldTextStyleKids(size: Font.sizeKids.thinExtra, color: Color.app.brownDeep))
                    }
                }
                RectButtonKids(
                    text: String.button.subscribe,
                    isSelected: true, isFixSize: false){_ in
                    
                    let status = self.pairing.status
                    if status != .pairing {
                        self.appSceneObserver.alert = .needPairing()
                        return
                    }
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.purchase)
                            .addParam(key: .data, value: self.data)
                    )
                    
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding(.horizontal, DimenKids.margin.regular)
            .modifier(MatchVertical(width: SystemEnvironment.isTablet ? 235 : 146 ))
            .background(Color.app.white)
        }
        .frame(height: DimenKids.tab.heavy)
        .background(Color.app.ivoryLight)
        .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.light))
        .modifier(ContentHorizontalEdgesKids())
        
    }

}

#if DEBUG
struct MonthlyPurchaseTicket_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            MonthlyPurchaseTicket(data: MonthlyData())
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver()).frame(width:320,height:100)

        }
    }
}
#endif
