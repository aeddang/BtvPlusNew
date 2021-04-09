//
//  ConnectButton.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI
extension Tooltip {
    static let size = CGSize(width: 97, height: 47)
}


struct Tooltip: PageView {
    var title:String? = nil
    var text:String? = nil
    var body: some View {
        ZStack{
            Image( Asset.shape.tooltip )
                .renderingMode(.original).resizable()
                .scaledToFit()
                .frame(width:Self.size.width, height: Self.size.height)
            VStack(alignment: .center, spacing: Dimen.margin.micro){
                if self.title != nil {
                    Text(self.title!)
                        .modifier(BoldTextStyle(size: Font.size.tinyExtra, color: Color.app.white))
                        .lineLimit(1)
                }
                if self.text != nil {
                    Text(self.text!)
                        .modifier(BoldTextStyle(size: Font.size.tinyExtra, color: Color.app.white))
                        .lineLimit(1)
                }
            }
            .padding(.bottom, Dimen.margin.tinyExtra)
        }
    }//body
}


#if DEBUG
struct Tooltip_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            Tooltip(
               title: "키즈톡톡플러스월",
                text: "편성 종료 D-7"
            )
        }
    }
}
#endif

