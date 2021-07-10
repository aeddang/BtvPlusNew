//
//  MonthlyGraphBox.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/06.
//

import Foundation
import SwiftUI
extension MonthlyGraphBox{
    static let size:CGSize = SystemEnvironment.isTablet ? CGSize(width: 308, height: 294) : CGSize(width: 190, height: 182)
}
struct MonthlyGraphBox: PageComponent{
    var title:String
    var value:String
    var subTitle:String
    var thumbImg:String
    var valuePct:Float = 0
    var guideImg:String
    var guidePct:Float = 0
    var color:Color
    
    var icon:String
    var text:String
    
    var body: some View {
        VStack(spacing:DimenKids.margin.microUltra){
            MonthlyGraph(
                title:self.title,
                value:self.value,
                subTitle:self.subTitle,
                thumbImg:self.thumbImg,
                valuePct:self.valuePct,
                guideImg:self.guideImg,
                guidePct:self.guidePct,
                color:self.color
            )
            HStack(spacing:DimenKids.margin.micro){
                Image(self.icon)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: DimenKids.icon.microUltra,
                           height: DimenKids.icon.microUltra)
                    
                Text(self.text)
                    .modifier(BoldTextStyleKids(
                                size: Font.sizeKids.microUltra,
                                color:  Color.app.yellow))
                    .padding(.top, DimenKids.margin.micro)
            }
        }
        .frame(width: Self.size.width, height: Self.size.height)
        .background(Color.app.white)
        .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.light))
    }
}
