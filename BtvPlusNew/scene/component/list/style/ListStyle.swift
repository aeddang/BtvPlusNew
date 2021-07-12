//
//  ListStyle.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI


struct ListItem{
    private static let isPad =  AppUtil.isPad()
    
    struct poster {
        static let type01:CGSize = isPad ? CGSize(width: 158, height: 224) : CGSize(width: 108, height: 154)
        static let type02:CGSize = isPad ? CGSize(width: 248, height: 354) : CGSize(width: 164, height: 234)
        static let type03:CGSize = isPad ? CGSize(width: 326, height: 224) : CGSize(width: 224, height: 154)
    }
    
    struct video {
        static let size:CGSize = isPad ? CGSize(width: 248, height: 162) : CGSize(width: 164, height: 92)
        static let type01:CGFloat = isPad ? 53 : 35
        static let type02:CGFloat = isPad ? 80 : 52
    }
    
    struct ticket {
        static let type01:CGSize = isPad ? CGSize(width: 197, height: 110) : CGSize(width: 164, height: 92)
        static let type02:CGSize =  isPad ? CGSize(width: 326, height: 224) : CGSize(width: 224, height: 154)
    }
    
    struct thema {
        static let type01:CGSize = isPad ? CGSize(width: 113, height: 113) : CGSize(width: 75, height: 75)
        static let type02:CGSize = isPad ? CGSize(width: 151, height: 174) : CGSize(width: 100, height: 115)
        static let type03:CGSize = isPad ? CGSize(width: 151, height: 151) : CGSize(width: 100, height: 100)
    }
    
    struct banner {
        static let type01:CGSize = isPad ? CGSize(width: 0, height: 100) : CGSize(width: 0, height: 80)
        static let type02:CGSize = CGSize(width: 320, height: 120)
        static let type03:CGSize = CGSize(width: 224, height: 154)
        static let type04:CGSize = isPad ? CGSize(width: 243, height: 231) : CGSize(width: 165, height: 154)
    }
    
    struct character {
        static let size:CGSize = isPad ? CGSize(width: 90, height: 90) : CGSize(width: 62, height: 62)
    }
    
    struct people {
        static let size:CGSize = isPad ? CGSize(width: 99, height: 99) : CGSize(width: 78, height: 78)
    }
    
    struct seris {
        static let type01:CGSize = CGSize(width: 159, height: 89)
        static let type02:CGSize = isPad ? CGSize(width: 247, height: 139) : CGSize(width: 164, height: 92)
    }
    
    struct purchase {
        static let size:CGSize = isPad ?  CGSize(width: 136, height: 194) : CGSize(width: 78, height: 111)
    }
    
    struct stb {
        static let size:CGSize = isPad ? CGSize(width: 72, height: 72) : CGSize(width: 52, height: 52)
    }
    
    struct monthly {
        static let size:CGSize = isPad ? CGSize(width: 130, height: 96) : CGSize(width: 108, height: 80)
    }
    
    struct cate {
        static let size:CGSize = isPad ? CGSize(width: 88, height: 88) :  CGSize(width: 62, height: 62)
    }
    
    struct play {
       static let size:CGSize = CGSize(width: 320, height: 180)
    }
    
    struct watched {
        static let size:CGSize = isPad ? CGSize(width: 176, height: 101) : CGSize(width: 112, height: 64)
    }
    
    struct search {
        static let height:CGFloat = isPad ? 60 : 45
    }
    struct purchaseTicket {
        static let size:CGSize =  CGSize(width: 355, height: 214)
    }
    
    struct card {
        static let size:CGSize =  isPad ? CGSize(width: 374, height: 232) : CGSize(width: 267, height: 166)
    }
    struct alram {
        static let height:CGFloat = 140
    }
    
    struct coupon {
        static let height:CGFloat = isPad ? 170 : 110
    }
   
}


struct ListRowInset: ViewModifier {
    var firstIndex = 1
    var index:Int = -1
    var marginHorizontal:CGFloat = 0
    var spacing:CGFloat =  SystemEnvironment.currentPageType == .btv ? Dimen.margin.thin : DimenKids.margin.thinUltra
    var marginTop:CGFloat = 0
    var bgColor:Color = SystemEnvironment.currentPageType == .btv ? Color.brand.bg : Color.kids.bg
    
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

struct HolizentalListRowInset: ViewModifier {
    var firstIndex = 1
    var index:Int = -1
    var marginVertical:CGFloat = 0
    var spacing:CGFloat =  SystemEnvironment.currentPageType == .btv ? Dimen.margin.thin : DimenKids.margin.thinUltra
    var marginTop:CGFloat = 0
    var bgColor:Color = SystemEnvironment.currentPageType == .btv ? Color.brand.bg : Color.kids.bg
    
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