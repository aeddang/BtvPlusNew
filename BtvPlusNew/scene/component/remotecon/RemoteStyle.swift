//
//  RemoteStyle.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/05/12.
//

import Foundation
import SwiftUI

struct RemoteStyle{
    private static let isPad =  AppUtil.isPad()
    static let effectTime:Double = 0.3
    
    struct button {
        static let heavy:CGFloat = isPad ? 91 : 83 //*
        static let heavyExtra:CGFloat = isPad ? 73 : 66 //*
        static let medium:CGFloat = isPad ? 52 : 48 //*
        static let regular:CGFloat = isPad ? 46 : 42 //*
        static let light:CGFloat = isPad ? 40 : 36 //*
        static let thin:CGFloat = isPad ? 30 : 24//*
    }
    
    struct icon {
        static let onAir:CGSize = isPad ? CGSize(width: 39, height: 18) : CGSize(width: 35, height: 16)
        static let age:CGFloat = isPad ? 27 : 22
    }
    
    struct ui {
        static let size:CGSize = isPad ? CGSize(width: 395, height: 812) : CGSize(width: 375, height: 667)
        static let center:CGSize = isPad ? CGSize(width: 175, height: 177) : CGSize(width: 160, height: 161)
        static let verticalButton:CGSize = isPad ? CGSize(width: 70, height: 178) : CGSize(width: 63, height: 162)
        static let topBoxHeight:CGFloat = isPad ? 60 : 40
        static let playBoxHeight:CGFloat = isPad ? 126 : 107
        static let uiBoxHeight:CGFloat = isPad ? 235 : 195
    }

    struct fontSize {
        static let title:CGFloat = isPad ? Font.size.lightExtra : Font.size.mediumExtra
        static let subTitle:CGFloat = isPad ? Font.size.thin : Font.size.regular
        static let subText:CGFloat = isPad ? Font.size.tinyExtra : Font.size.thin
    }

    struct margin {
        static let regular:CGFloat = isPad ? 30 : 20 //*
        static let light:CGFloat = isPad ? 18 : 16 //*
        static let thin:CGFloat = isPad ? 12 : 10//
        static let tiny:CGFloat = isPad ? 8 : 6//**
    }
}
