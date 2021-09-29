//
//  EmptyMyData.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/09/29.
//

import Foundation
import SwiftUI

struct EmptyMyData: PageView {
    var icon:String = Asset.image.myEmpty
    var text:String = String.alert.dataError
    var tip:String? = nil
    var body: some View {
        VStack(alignment: .center, spacing: 0){
            Image(icon)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Dimen.icon.heavyUltra, height: Dimen.icon.heavyUltra)
            Text(text)
                .modifier(BoldTextStyle(size: SystemEnvironment.isTablet ? Font.size.thin : Font.size.regular, color: Color.app.greyLight))
                    .multilineTextAlignment(.center)
                    .padding(.top, Dimen.margin.mediumExtra)
            
            if let tip = self.tip{
                Text(tip)
                    .modifier(MediumTextStyle(size: Font.size.lightExtra, color: Color.app.greyMedium))
                    .multilineTextAlignment(.center)
                    .padding(.top, Dimen.margin.light)
            }
        }
        .padding(.all, Dimen.margin.medium)
        
    }//body
}



