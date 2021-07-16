//
//  AlertsKids.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/07.
//

import Foundation
import SwiftUI

struct ErrorKidsData: PageView {
    var icon:String? = Asset.icon.alert
    var text:String = String.alert.apiErrorServer
    var tip:String? = nil
    var body: some View {
        VStack(alignment: .center, spacing: DimenKids.margin.regular){
            if let icon = self.icon {
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.app.sepia)
                    .frame(width: DimenKids.icon.mediumUltra, height:  DimenKids.icon.mediumUltra)
            }
            Text(self.text)
                .modifier(BoldTextStyleKids(
                            size: Font.sizeKids.light,
                            color:  Color.app.sepia))
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

