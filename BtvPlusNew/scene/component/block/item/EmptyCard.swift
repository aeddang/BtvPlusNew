//
//  EmptyCard.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/08/02.
//

import Foundation
import SwiftUI

struct EmptyCard: PageView {
    var icon:String = Asset.image.myEmpty
    var text:String = String.alert.dataError
    var body: some View {
        ZStack(alignment: .bottom){
            Spacer()
                .frame(
                    width: ListItem.card.size.width,
                    height: ListItem.card.size.height)
                .background(Color.app.blueLight)
                .clipShape( RoundedRectangle(cornerRadius: Dimen.radius.light))
            VStack(alignment: .center, spacing: 0){
                Image(icon)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Dimen.icon.heavyUltra, height: Dimen.icon.heavyUltra)
                Text(text)
                    .modifier(MediumTextStyle(size: Font.size.regular, color: Color.app.white))
                    .multilineTextAlignment(.center)
                    .padding(.top, Dimen.margin.mediumExtra)
               
            }
            .padding(.all, Dimen.margin.regular)
        }
        
        
    }//body
}

struct AddCard: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var naviLogManager:NaviLogManager
    var type:CardBlock.ListType? = nil
    var text:String? = nil
    var idx:Int = 1
    var body: some View {
        ZStack(alignment: .center){
            Spacer()
                .frame(
                    width: ListItem.card.size.width,
                    height: ListItem.card.size.height)
                .background(Color.app.blueLight)
                .clipShape( RoundedRectangle(cornerRadius: Dimen.radius.light))
            VStack(alignment: .center, spacing: Dimen.margin.light){
                if let text = self.text {
                    Text(text)
                        .modifier(MediumTextStyle(size: Font.size.regular, color: Color.app.white))
                        .multilineTextAlignment(.center)
                }
                Button(action: {
                    self.naviLogManager.actionLog(
                        .clickCouponPointAdd,
                        actionBody: .init(config: type?.logConfig,  category: "다른할인수단"))
                    self.pagePresenter.openPopup(
                         PageProvider.getPageObject(.myRegistCard)
                            .addParam(key: PageParam.type, value: type)
                            .addParam(key: PageParam.index, value: self.idx)
                     )
                    
                    
                }) {
                    Image(Asset.icon.addCard)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(height: Dimen.icon.regularExtra)
                }
               
            }
            .padding(.all, Dimen.margin.regular)
        }
        
        
    }//body
}



#if DEBUG
struct EmptyCard_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            AddCard(
                
            )
        }
        .frame(width: 350)
        .background(Color.brand.bg)
    }
}
#endif
