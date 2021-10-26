//
//  HitchStbItem.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/27.
//

import Foundation
import SwiftUI

struct HitchPairingItem: PageView {
    enum PairingType {
        case wifi, btv, user
        var icon:String{
            get{
                switch self {
                case .wifi: return Asset.icon.pairingWifi2
                case .btv: return Asset.icon.pairingBtv2
                case .user: return Asset.icon.pairingUser2
                }
            }
        }
        var text:String{
            get{
                switch self {
                case .wifi: return String.pairingHitch.typeLeading
                case .btv: return String.pairingHitch.typeLeading
                case .user: return String.pairingHitch.typeLeading2
                }
            }
        }
        var subText:String {
            get{
                switch self {
                case .wifi: return String.pairingHitch.wifi
                case .btv: return String.pairingHitch.btv
                case .user: return String.pairingHitch.user
                }
            }
        }
    }
    var type:PairingType
    var isSelected:Bool
    var body: some View {
        VStack(alignment:.center , spacing:Dimen.margin.micro){
            Image(self.type.icon)
                .renderingMode(.original)
                .resizable()
                .frame(
                    width: SystemEnvironment.isTablet ? Dimen.icon.regular : Dimen.icon.medium,
                    height: SystemEnvironment.isTablet ? Dimen.icon.regular : Dimen.icon.medium)
            Text(self.type.text)
                .modifier(MediumTextStyle(
                            size: SystemEnvironment.isTablet ? Font.size.microUltra : Font.size.thinExtra,
                            color: Color.app.blackExtra))
                .lineLimit(1)
                .padding(.top, SystemEnvironment.isTablet ? Dimen.margin.microUltra : Dimen.margin.tiny)
            Text(self.type.subText)
                .modifier(BoldTextStyle(
                             size: SystemEnvironment.isTablet ? Font.size.microUltra : Font.size.thinExtra,
                             color: Color.app.blackExtra))
                .lineLimit(1)
        }
        .padding(.all, Dimen.margin.micro)
        .frame(
            width: SystemEnvironment.isTablet ? 122 : 105,
            height: SystemEnvironment.isTablet ? 122 : 105)
        .background(Color.brand.primary.opacity(0.1) )
        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.regularExtra))
        .overlay(
            RoundedRectangle(cornerRadius: Dimen.radius.regularExtra)
                .stroke( Color.brand.primary.opacity(self.isSelected ? 1.0 : 0.3)  ,lineWidth: self.isSelected ? 3 : 1 )
        )
    }
}
