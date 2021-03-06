//
//  ConnectButton.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI
struct RatingInfo: View {
    var rating:Double
    var body: some View {
        HStack(alignment: .center , spacing:Dimen.margin.tinyExtra){
            Image( Asset.icon.ratingPrimary )
                .renderingMode(.original).resizable()
                .scaledToFit()
                .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
            Text(self.rating.toPercent())
                .modifier(BoldTextStyle(size: Font.size.light, color: Color.brand.primary))
                .padding(.top, 4)
        }
    }//body
}


#if DEBUG
struct RatingInfo_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            RatingInfo(
                rating: 32.123
            )
        }
    }
}
#endif

