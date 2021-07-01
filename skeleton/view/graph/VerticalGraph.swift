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
    var percent:Float = 0.0
    var maxValue:Float = 100
    var unit:String = "%"
    var thumbText:String? = nil
    var thumbImg:String? = nil
    var title:String? = nil
    var titleColor:Color = Color.app.brownLight
    var size:CGSize = CGSize(width: 28, height: 85)
    var color:Color = Color.brand.primary
    var radius:CGFloat = DimenKids.radius.tiny

    var body: some View {
        VStack(alignment: .center, spacing:DimenKids.margin.tiny) {
            ZStack(alignment: .bottom){
                VStack(alignment: .center, spacing:0) {
                    Spacer()
                    if let thumbText = self.thumbText {
                        ZStack{
                            Image(AssetKids.shape.graphAverage)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor( self.color )
                                .frame(height: self.size.width)
                                .padding(.bottom, DimenKids.margin.micro)
                            
                            Text(thumbText)
                                .modifier(BoldTextStyleKids(size: Font.sizeKids.tinyExtra, color: Color.app.white))
                                .padding(.bottom, self.size.width/3)
                        }
                        .padding(.bottom, -DimenKids.margin.micro)
                    }
                    if let thumbImg = self.thumbImg {
                        ZStack(){
                            Image(AssetKids.shape.graphThumbBg)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(self.color)
                                .frame(height: self.size.width)
                                .padding(.bottom, DimenKids.margin.micro)
                            Image(thumbImg)
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .padding(.all, DimenKids.stroke.medium)
                                .frame(width: self.size.width,
                                       height: self.size.width)
                                .clipShape(Circle())
                                .padding(.bottom, self.size.width/3)
                        }
                        .padding(.bottom, -DimenKids.margin.micro)
                    }
                    ZStack(alignment: .bottom) {
                        Spacer()
                        .modifier(MatchParent())
                            .background(
                                (self.percent == 0 ? Color.app.grey : self.color).opacity(0.8))
                        .mask(
                            ZStack(alignment: .bottom){
                                RoundedRectangle(cornerRadius: self.radius)
                                Rectangle().modifier(MatchHorizontal(height: self.radius))
                            }
                        )
                    }
                    .padding(.top, self.radius)
                    .background((self.percent == 0 ? Color.app.grey : self.color).opacity(0.5))
                    .mask(
                        ZStack(alignment: .bottom){
                            RoundedRectangle(cornerRadius: self.radius)
                            Rectangle().modifier(MatchHorizontal(height: self.radius))
                        }
                    )
                    .overlay(
                        RoundTopRectMask(radius: self.radius)
                            .stroke( self.percent == 0 ? Color.app.grey : self.color ,lineWidth: 1 )
                    )
                    .frame(width: size.width, height: max(self.radius,size.height*CGFloat(self.percent)))
                    .padding(.top, self.percent == 0 ? self.radius + Font.sizeKids.tinyExtra : 0)
                }
                Text( Int(round(self.maxValue * self.percent)).description + self.unit )
                    .modifier(BoldTextStyleKids(
                                size: Font.sizeKids.microUltra,
                                color: self.percent == 0 ? Color.app.grey : Color.app.white))
                    .padding(.bottom, self.percent == 0
                                ? (self.radius + DimenKids.margin.micro) : DimenKids.margin.micro)
            }
            .clipped()
            if let title = self.title {
                Text(title)
                    .modifier(BoldTextStyleKids(size: Font.sizeKids.microUltra, color: self.titleColor))
            }
        }
    }
    
}
#if DEBUG
struct VerticalGraph_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            VerticalGraph(
                percent: 0.6,
                maxValue: 100,
                unit: "%",
                thumbText: "또래평균",
                thumbImg: AssetKids.image.noProfile,
                title: "LV3"
            )
            
        }.frame(width: 100, height: 400)
        .background(Color.app.ivory)
    }
}
#endif
