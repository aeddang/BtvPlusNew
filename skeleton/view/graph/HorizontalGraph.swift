//
//  ProgressSlider.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/18.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

struct HorizontalGraph: PageView {
    var percent: Float = 0.5
    var unit:String = "%"
    var paddingTop:CGFloat = SystemEnvironment.isTablet ? 8 : 5
    var size:CGSize = CGSize(width: 100, height: 15)
    var color:Color = Color.brand.primary
    var radius:CGFloat = DimenKids.radius.tiny

    var body: some View {
        ZStack(alignment: .leading) {
            ZStack(alignment: .leading) {
                Spacer()
                .modifier(MatchParent())
                .background(self.color)
                .mask(
                    RoundedRectangle(cornerRadius: self.radius)
                )
            }
            .padding(.top, self.paddingTop)
            .background(self.color.opacity(0.7))
            .mask(
                RoundedRectangle(cornerRadius: self.radius)
            )
            .frame(width:size.width*CGFloat(self.percent), height: size.height)
            HStack{
                Spacer()
                
                Spacer()
            }
        }
        .frame(width: size.width, height: size.height)
        .background(self.color.opacity(0.2))
        .mask(
            RoundedRectangle(cornerRadius: self.radius)
        )
    }
    
}
#if DEBUG
struct HorizontalGraph_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            HorizontalGraph(
               
            )
            
        }.frame(width: 100, height: 300)
        .background(Color.app.ivory)
    }
}
#endif
