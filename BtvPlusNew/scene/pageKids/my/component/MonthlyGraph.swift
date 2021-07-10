//
//  MonthlyGraphBox.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/06.
//

import Foundation
import SwiftUI

struct MonthlyGraph: PageComponent{
    var title:String
    var value:String
    var subTitle:String
    var thumbImg:String
    var valuePct:Float
    var guideImg:String? = nil
    var guidePct:Float = 0
    var color:Color
    var body: some View {
        VStack(spacing:0){
            Text(self.title)
                .modifier(BoldTextStyleKids(
                            size: Font.sizeKids.tinyExtra,
                            color:  Color.app.brownDeep))
            Text(self.value)
                .modifier(BoldTextStyleKids(
                            size: Font.sizeKids.regular,
                            color:  Color.app.brownDeep))
                .padding(.top, DimenKids.margin.thinExtra)
            Text(self.subTitle)
                .modifier(BoldTextStyleKids(
                            size: Font.sizeKids.microUltra,
                            color:  Color.app.sepia))
                .padding(.top, DimenKids.margin.micro)
            HorizontalGraph(
                value: self.valuePct,
                thumbImg: self.thumbImg,
                guidePercent: self.guidePct,
                guideImg: self.guideImg,
                size: DimenKids.item.graphHorizontal,
                color: self.color
            )
            .padding(.top, DimenKids.margin.thin)
        }
    }
}
