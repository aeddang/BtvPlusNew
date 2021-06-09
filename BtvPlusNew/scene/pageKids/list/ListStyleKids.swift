//
//  ListStyleKids.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/09.
//

import Foundation
//
//  ListStyle.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI


struct ListItemKids{
    private static let isPad =  AppUtil.isPad()
    struct videoPlayer {
        static let size:CGSize = isPad ? CGSize(width: 327, height: 199) : CGSize(width: 170, height: 103)
    }
}


struct ListRowInsetKids: ViewModifier {
    var firstIndex = 1
    var index:Int = -1
    var marginHorizontal:CGFloat = 0
    var spacing:CGFloat = DimenKids.margin.thinUltra
    var marginTop:CGFloat = 0
    var bgColor:Color = Color.kids.bg
    
    func body(content: Content) -> some View {
        return content
            .padding(
                .init(
                    top: (index == firstIndex) ? marginTop : 0,
                    leading:  marginHorizontal,
                    bottom: spacing,
                    trailing: marginHorizontal)
            )
            .listRowInsets(
                .init(
                    )
            )
            .listRowBackground(bgColor)
        
    }
}

struct HolizentalListRowInsetKids: ViewModifier {
    var firstIndex = 1
    var index:Int = -1
    var marginVertical:CGFloat = 0
    var spacing:CGFloat = DimenKids.margin.thinUltra
    var marginTop:CGFloat = 0
    var bgColor:Color = Color.kids.bg
    
    func body(content: Content) -> some View {
        return content
            .padding(
                EdgeInsets(
                    top: marginVertical,
                    leading:  (index == firstIndex) ? marginTop : 0,
                    bottom: marginVertical,
                    trailing: spacing)
            )
            .listRowInsets(
                EdgeInsets(
                    top: 0, leading: 0, bottom: 0, trailing: 0
                )
            )

            .listRowBackground(bgColor)
        
    }
}
