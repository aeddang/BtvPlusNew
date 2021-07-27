//
//  HitchStbItem.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/27.
//

import Foundation
import SwiftUI

struct HitchStbItem: PageView {
    var data:StbData
    var isSelected:Bool
    var body: some View {
        VStack(alignment:.center , spacing:SystemEnvironment.isTablet ? Dimen.margin.tinyExtra : Dimen.margin.tiny){
            Image(data.image)
            .renderingMode(.original)
            .resizable()
            .frame(
                width: SystemEnvironment.isTablet ? Dimen.icon.regular : Dimen.icon.medium,
                height: SystemEnvironment.isTablet ? Dimen.icon.regular : Dimen.icon.medium)
            if let stbName = self.data.stbName {
                Text(stbName)
                    .modifier(MediumTextStyle(
                                size: SystemEnvironment.isTablet ? Font.size.tinyExtra : Font.size.lightExtra,
                                color: Color.app.blackExtra))
                    .lineLimit(1)
            }
            if let macAddress = self.data.macAddress{
                Text(macAddress)
                    .modifier(MediumTextStyle(
                                size: SystemEnvironment.isTablet ? Font.size.micro : Font.size.tinyExtra,
                                color: Color.app.grey))
                    .lineLimit(1)
            }
        }
        .padding(.all, Dimen.margin.micro)
        .modifier(MatchParent())
        .background(self.isSelected ? Color.brand.primary.opacity(0.1) : Color.app.white)
        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.regularExtra))
        .overlay(
            RoundedRectangle(cornerRadius: Dimen.radius.regularExtra)
                .stroke( self.isSelected ? Color.brand.primary : Color.app.greyExtra ,lineWidth: self.isSelected ? 3 : 1 )
        )
    }
}
