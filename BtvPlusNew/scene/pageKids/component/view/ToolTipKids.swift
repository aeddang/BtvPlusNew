//
//  ConnectButton.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI
extension TooltipKids {
    static let size = SystemEnvironment.isTablet ?  CGSize(width: 270, height: 61) : CGSize(width: 141, height: 32)
}


struct TooltipKids: PageView {
    var title:String? = nil
    var text:String? = nil
    var body: some View {
        ZStack{
            Image( AssetKids.shape.tooltip )
                .renderingMode(.original).resizable()
                .scaledToFit()
                .frame(width:Self.size.width, height: Self.size.height)
            HStack(alignment: .center, spacing: Dimen.margin.micro){
                if self.title != nil {
                    Text(self.title!)
                        .modifier(BoldTextStyleKids(size: Font.sizeKids.thinExtra, color: Color.kids.primary))
                        .lineLimit(1)
                }
                if self.text != nil {
                    Text(self.text!)
                        .modifier(BoldTextStyleKids(size: Font.sizeKids.thinExtra, color: Color.kids.primary))
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, DimenKids.margin.tiny)
        }
    }//body
}


#if DEBUG
struct TooltipKids_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            TooltipKids(
               title: "키즈톡톡플러스월",
                text: "편성 종료 D-7"
            )
        }
    }
}
#endif

