//
//  AlertsKids.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/07.
//

import Foundation
import SwiftUI

struct ErrorKidsData: PageView {
    var icon:String = Asset.icon.alert
    var text:String = String.alert.apiErrorServer
    var tip:String? = nil
    var body: some View {
        VStack(alignment: .center, spacing: 0){
            Image(icon)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Dimen.icon.heavyUltra, height: Dimen.icon.heavyUltra)
            Text(String.alert.apiErrorServer)
                .modifier(BoldTextStyleKids(
                            size: Font.sizeKids.thin,
                            color:  Color.app.brownDeep))
            if let tip = self.tip{
                Text(tip)
                    .modifier(MediumTextStyleKids(size: Font.sizeKids.thinExtra, color: Color.app.greyLight))
                    .multilineTextAlignment(.leading)
                    .padding(.top, DimenKids.margin.tiny)
            }
        }
        .padding(.all, DimenKids.margin.light)
    }//body
}
