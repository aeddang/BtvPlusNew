//
//  ConnectButton.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI
struct RatingPoint: View {
    var rating:Double
    var ratingMax:Double
    var body: some View {
        HStack(alignment: .center , spacing:Dimen.margin.micro){
            Image( Asset.icon.watcha )
                .renderingMode(.original).resizable()
                .scaledToFit()
                .frame(height: Dimen.icon.tiny)
            Text(self.rating.toTruncateDecimal(n: 1) + "/" + self.ratingMax.toTruncateDecimal(n: 0))
                .modifier(BoldTextStyle(size: Font.size.light, color: Color.brand.primary))
                .padding(.top, 1)
        }
    }//body
}


#if DEBUG
struct RatingPoint_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            RatingPoint(
                rating: 3.123,
                ratingMax: 10
            )
        }
    }
}
#endif

