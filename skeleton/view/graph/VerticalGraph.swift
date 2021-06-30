//
//  ProgressSlider.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/18.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

struct VerticalGraph: PageView {
    var percent: Float = 0.5
    var unit:String = "%"
   
    var size:CGSize = CGSize(width: 28, height: 85)
    var color:Color = Color.brand.primary
    var radius:CGFloat = DimenKids.radius.tiny

    var body: some View {
        VStack(alignment: .center) {
            ZStack(alignment: .leading) {
                Spacer()
                .modifier(MatchParent())
                .background(self.color.opacity(0.8))
                .mask(
                    ZStack(alignment: .bottom){
                        RoundedRectangle(cornerRadius: self.radius)
                        Rectangle().modifier(MatchHorizontal(height: self.radius))
                    }
                )
            }
            .padding(.top, self.radius)
            .background(self.color.opacity(0.5))
            .mask(
                ZStack(alignment: .bottom){
                    RoundedRectangle(cornerRadius: self.radius)
                    Rectangle().modifier(MatchHorizontal(height: self.radius))
                }
            )
            .overlay(
                RoundTopRectMask(radius: self.radius)
                .stroke( self.color ,lineWidth: 1 )
            )
            .frame(width: size.width, height: size.height*CGFloat(self.percent))
        }
    }
    
}
#if DEBUG
struct VerticalGraph_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            VerticalGraph(
               
            )
            
        }.frame(width: 100, height: 300)
        .background(Color.app.ivory)
    }
}
#endif
