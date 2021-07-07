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
    var value:Float = 0.0
    var maxValue:Float = 1
    var viewText:String? = nil
    var unit:String = ""
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
                                
                                .frame(width: self.size.width ,
                                       height: self.size.width )
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke( self.value == 0 ? Color.app.grey : self.color ,lineWidth: DimenKids.stroke.regular )
                                )
                                
                                .padding(.bottom, self.size.width/3)
                        }
                        .padding(.bottom, -DimenKids.margin.micro)
                    }
                    ZStack(alignment: .bottom) {
                        Spacer()
                        .modifier(MatchParent())
                            .background(
                                (self.value == 0 ? Color.app.grey : self.color).opacity(0.8))
                        .mask(
                            ZStack(alignment: .bottom){
                                RoundedRectangle(cornerRadius: self.radius)
                                Rectangle().modifier(MatchHorizontal(height: self.radius))
                            }
                        )
                    }
                    .padding(.top, self.radius)
                    .background((self.value == 0 ? Color.app.grey : self.color).opacity(0.5))
                    .mask(
                        ZStack(alignment: .bottom){
                            RoundedRectangle(cornerRadius: self.radius)
                            Rectangle().modifier(MatchHorizontal(height: self.radius))
                        }
                    )
                    .overlay(
                        RoundTopRectMask(radius: self.radius)
                            .stroke( self.value == 0 ? Color.app.grey : self.color ,lineWidth: DimenKids.stroke.light )
                    )
                    .frame(width: size.width, height: max(self.radius,size.height*CGFloat(self.value)))
                    .padding(.top, self.value == 0 ? self.radius + Font.sizeKids.tinyExtra : 0)
                    
                }
                Text( self.viewText ??  Int(round(self.maxValue * self.value)).description + self.unit  )
                    .modifier(BoldTextStyleKids(
                                size: Font.sizeKids.microUltra,
                                color: self.value == 0 ? Color.app.grey : Color.app.white))
                    .padding(.bottom,
                              self.value == 0 ? (self.radius + DimenKids.margin.micro) : DimenKids.margin.micro
                    )
            }
            .padding(.horizontal, DimenKids.stroke.regular)
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
                value: 0.6,
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
