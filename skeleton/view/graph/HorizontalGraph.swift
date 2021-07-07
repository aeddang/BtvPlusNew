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
    var value: Float = 0.3
    var thumbImg:String? = nil
    
    var guidePercent: Float = 0.0
    var guideImg:String? = nil
    var paddingTop:CGFloat = SystemEnvironment.isTablet ? 8 : 5
    var size:CGSize = CGSize(width: 100, height: 15)
    var color:Color = Color.brand.primary
    var radius:CGFloat = DimenKids.radius.tiny

    var body: some View {
        ZStack(alignment: .top){
            ZStack(alignment: .leading) {
                Spacer()
                    .modifier(MatchParent())
                ZStack(alignment: .topTrailing) {
                    Spacer()
                    .modifier(MatchParent())
                    .background(self.color)
                    .mask(
                        RoundedRectangle(cornerRadius: self.radius)
                    )
                    .padding(.top, self.paddingTop)
                    Spacer()
                    .frame(width: 4, height: 2)
                    .background(Color.app.white.opacity(0.2))
                    .mask(
                        RoundedRectangle(cornerRadius: self.radius)
                    )
                    .padding(.top, DimenKids.margin.micro)
                    .padding(.trailing, size.height*1.2/2 + DimenKids.margin.micro)
                }
                
                .background(self.color.opacity(0.7))
                .mask(
                    RoundedRectangle(cornerRadius: self.radius)
                )
                .frame(width:size.width*CGFloat(self.value), height: size.height)
            }
            .frame(width: size.width, height: size.height)
            .background(self.color.opacity(0.2))
            .mask(
                RoundedRectangle(cornerRadius: self.radius)
            )
            .padding(.top, self.size.height*0.1)
            if let guide = self.guideImg {
                HStack{
                    Spacer()
                        .frame(width:max(size.width*CGFloat(self.guidePercent) - (DimenKids.icon.micro/2),0))
                    Image(guide)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: DimenKids.icon.micro)
                    Spacer()
                }
                .frame(width: size.width)
            }
            HStack{
                Spacer()
                    .frame(width:max(size.width*CGFloat(self.value) - (self.size.height*1.2/2),0))
                if let thumbImg = self.thumbImg {
                    Image(thumbImg)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: self.size.height*1.2,
                               height: self.size.height*1.2)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke( self.color.toneDown(0.15) ,lineWidth: DimenKids.stroke.regular)
                        )
                }
                Spacer()
            }
            .frame(width: size.width)
            
            
            
        }
    }
    
}
#if DEBUG
struct HorizontalGraph_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            HorizontalGraph(
                value: 0.6,
                thumbImg: AssetKids.image.noProfile,
                guidePercent: 0.3,
                guideImg: AssetKids.shape.graphGuideTime
            )
            
        }.frame(width: 100, height: 300)
        .background(Color.app.ivory)
    }
}
#endif
