//
//  ConnectButton.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI

struct TooltipBottom: PageView {
    var text:String = ""
    var close:() -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            Image( Asset.shape.topTooltip )
                .renderingMode(.original).resizable()
                .scaledToFit()
                .frame(width:Dimen.icon.micro, height: Dimen.icon.micro)
                .padding(.leading,
                         SystemEnvironment.isTablet
                            ? Dimen.margin.thinExtra : Dimen.margin.lightExtra)
            HStack(alignment: .center, spacing: 0){
                Text(self.text)
                    .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.white))
                    .fixedSize(horizontal: true, vertical: false)
                    .lineLimit(1)
                    .padding(.all, SystemEnvironment.isTablet ? Dimen.margin.tiny : Dimen.margin.thin)
                Image(Asset.icon.close)
                .renderingMode(.original).resizable()
                .scaledToFit()
                .frame(width: Dimen.icon.thinExtra, height: Dimen.icon.thinExtra)
                    .padding(.trailing,
                             SystemEnvironment.isTablet ? Dimen.margin.tinyExtra : Dimen.margin.tiny)
            }
            .background(Color.brand.primary)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.heavy))
            .padding(.top, -5)
        }
        .onTapGesture {
            self.close()
        }
    }//body
}


#if DEBUG
struct TooltipBottom_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            TooltipBottom(
                text: "편성 종료 D-7"
            ){
                
            }
        }
    }
}
#endif

