//
//  ValueInfo.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/19.
//

import Foundation
import SwiftUI
struct GuideViewData {
    var img:String? = nil
    var title:String? = nil
    var text:String? = nil
    var info:String? = nil
    var margin:CGFloat = 0
}


struct GuideView: PageComponent, Identifiable{
    let id:String = UUID().uuidString
    var data:GuideViewData
   
    var body: some View {
        VStack(alignment:.leading , spacing:0){
            if let img = self.data.img {
                Image(img)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .top)
                    .padding(.bottom, Dimen.margin.regular)
                    .padding(.horizontal, self.data.margin)
            }
            if let title = self.data.title {
                Text(title)
                    .modifier(MediumTextStyle(size: Font.size.mediumExtra, color: Color.brand.primary))
                    .padding(.bottom, Dimen.margin.thin)
                    .padding(.horizontal, Dimen.margin.regular)
            }
            if let text = self.data.text {
                Text(text)
                    .modifier(MediumTextStyle(size: Font.size.medium, color: Color.app.white))
                    .padding(.bottom, Dimen.margin.light)
                    .padding(.horizontal, Dimen.margin.regular)
            }
            if let info = self.data.info {
                Text(info)
                    .modifier(MediumTextStyle(size: Font.size.regular, color: Color.app.grey))
                    .padding(.horizontal, Dimen.margin.regular)
            }
        }
        .modifier(MatchParent())
    }//body
}


#if DEBUG
struct GuideView_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            GuideView(
                data: .init(img: Asset.source.pairingTutorial01, title: "title", text: "text", info: "info")
            )
        }.background(Color.brand.bg)
    }
}
#endif
