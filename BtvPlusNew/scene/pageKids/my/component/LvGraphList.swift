//
//  MonthlyGraphBox.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/06.
//

import Foundation
import SwiftUI


struct LvGraphData:Identifiable{
    let id:String = UUID().uuidString
    var thumb:String? = nil
    var thumbText:String? = nil
    var valueText:String = ""
    var value:Float = 0
    var color:Color = Color.app.grey
    
    var title:String? = nil
    var titleColor:Color = Color.app.sepiaLight
    var delay:Double = 0
}

struct LvGraphList: PageComponent{
    var datas:[LvGraphData]
    var body: some View {
        HStack(spacing:DimenKids.margin.thin){
            ForEach(self.datas) { data in
                LvGraphListItem(
                    data: data
                )
                .frame(width: DimenKids.item.graphVertical.width)
            }
        }
    }
}

struct LvGraphListItem: PageComponent{
    var data:LvGraphData
    @State var pct:Float = 0
  
    var body: some View {
        VerticalGraph(
            value: self.pct,
            viewText: self.data.valueText,
            thumbText: self.data.thumbText,
            thumbImg: self.data.thumb,
            title: self.data.title,
            titleColor: self.data.titleColor,
            size: DimenKids.item.graphVertical,
            color: self.data.color)
             
        .onAppear(){
            DispatchQueue.main.asyncAfter(deadline: .now() + self.data.delay ) {
                withAnimation{
                    self.pct = self.data.value
                }
            }
        }
    }
}
