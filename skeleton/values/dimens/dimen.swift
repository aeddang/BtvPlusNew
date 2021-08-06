//
//  dimens.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct Dimen{
    private static let isPad =  AppUtil.isPad()
    struct margin {
        
        public static let heavy:CGFloat = isPad ? 100 : 46 //*
        public static let heavyExtra:CGFloat = isPad ? 76 : 40 //*
        public static let mediumUltra:CGFloat = isPad ? 72 : 35 //*
        public static let medium:CGFloat = isPad ? 69 : 30 //*
        public static let mediumExtra:CGFloat = isPad ? 45 : 24 //*
        public static let regular:CGFloat = isPad ? 40 : 20 //*
        public static let regularExtra:CGFloat = isPad ? 32 : 16 //*
        public static let light:CGFloat = isPad ? 28 : 14 //*
        public static let lightExtra:CGFloat = isPad ? 24 : 12 //*
        public static let thin:CGFloat = isPad ? 20 : 10 //*
        public static let thinExtra:CGFloat = isPad ? 16 : 8 //*
        public static let tiny:CGFloat = isPad ? 12 : 6 //*
        public static let tinyExtra:CGFloat = isPad ? 8 : 5 //*
        public static let micro:CGFloat = isPad ? 4 : 2
        public static let microExtra:CGFloat = isPad ? 2 : 1
      
    }

    struct icon {
        public static let heavyUltra:CGFloat = isPad ? 198 : 157 //*
        public static let heavy:CGFloat = isPad ? 123 : 69 //*
        public static let heavyExtra:CGFloat = isPad ? 98 : 58 //*
        public static let mediumUltra:CGFloat = isPad ? 84 : 48 //*
        public static let medium:CGFloat = isPad ? 54 : 40 //*
        public static let mediumExtra:CGFloat = isPad ? 52 : 38  //*
        public static let regular:CGFloat = isPad ? 48 : 36 //*
        public static let regularExtra:CGFloat = isPad ? 38 : 32 //*
        public static let light:CGFloat = isPad ? 30 : 25 //*
        public static let lightExtra:CGFloat = isPad ? 28 : 23 //*
        public static let thin:CGFloat = isPad ? 26 : 22 //*
        public static let thinExtra:CGFloat = isPad ? 24 : 20  //*
        public static let tiny:CGFloat = isPad ? 21 : 17//*
        public static let tinyExtra:CGFloat = isPad ? 18 : 14//*
        public static let micro:CGFloat = 12//*
        public static let microExtra:CGFloat = 6//*
    }
    
    struct tab {
        public static let titleWidth:CGFloat = isPad ? 100 : 60
       
        public static let heavy:CGFloat = 72//*
        public static let heavyExtra:CGFloat = isPad ? 94 : 66//*
        public static let medium:CGFloat = isPad ? 80 : 56 //*
        public static let regular:CGFloat = isPad ? 63 : 46 //*
        public static let regularExtra:CGFloat = isPad ? 52 : 38 //*
        public static let light:CGFloat =  isPad ? 42 : 36//*
        public static let lightExtra:CGFloat = isPad ? 30 : 24//*
        public static let thin:CGFloat = isPad ? 26 : 18 //*
    }
    
    struct button {
        public static let heavy:CGFloat =  80 //*
        public static let heavyExtra:CGFloat = isPad ? 76 : 64 //*
        public static let medium:CGFloat = isPad ? 60 : 50 //*
        public static let regular:CGFloat = isPad ? 56 : 40 //*
        public static let regularExtra:CGFloat = isPad ? 42 : 35 //*
        public static let light:CGFloat = isPad ? 37 : 32 //*
        public static let lightExtra:CGFloat = isPad ? 35 : 30//*
        public static let thin:CGFloat = isPad ? 24 : 20//*
        
        public static let heavyRect:CGSize = isPad ? CGSize(width: 130, height: 60) : CGSize(width: 90, height: 42)//*
        public static let mediumRect:CGSize = isPad ? CGSize(width: 130, height: 52) : CGSize(width: 79, height: 30)//*
        public static let mediumExtraRect:CGSize = isPad ? CGSize(width: 120, height: 52) : CGSize(width: 62, height: 30)//*
        public static let regularRect:CGSize = isPad ? CGSize(width: 78, height: 40) : CGSize(width: 48, height: 25)//*
        public static let lightRect:CGSize = isPad ? CGSize(width: 61, height: 29) : CGSize(width: 38, height: 20)//*
        
        public static let regularHorizontal:CGFloat = isPad ?  374 : 259
       
    }

    struct radius {
        
        public static let heavy:CGFloat = isPad ? 40 : 20//*
        public static let medium:CGFloat = 14
        public static let regular:CGFloat = 12
        public static let regularExtra:CGFloat = isPad ? 15 : 10//*
        public static let light:CGFloat = 5
        public static let thin:CGFloat = 2
    }
    
    struct bar {
        public static let medium:CGFloat = isPad ? 30 : 20//*
        public static let regular:CGFloat = 7 //*
    }
    
    struct line {
        public static let heavy:CGFloat = isPad ? 24 : 22 //*
        public static let heavyExtra:CGFloat = isPad ? 19 : 12 //*
        public static let medium:CGFloat = isPad ? 4 : 3 //*
        public static let regular:CGFloat = isPad ? 3 : 2 //*
        public static let light:CGFloat = 1 //*
    }
    
    struct stroke {
        public static let heavy:CGFloat = isPad ? 10 : 5 //*
        public static let medium:CGFloat = isPad ? 6 : 3 //*
        public static let regular:CGFloat = isPad ? 4 : 2 //*
        public static let light:CGFloat = isPad ? 2 : 1 //*
    }
    
    struct app {
        public static let bottom:CGFloat = isPad ? 65 : 60 //*
        public static let top:CGFloat = isPad ? 86 : 80 //*
        public static let pageTop:CGFloat = isPad ? 64 : 62 //*
        public static let keyboard:CGFloat = isPad ? 400 : 300
    }
    
    struct item {
        static let profile:CGSize = CGSize(width: 110, height: 110)
    }
    
    struct popup {
        public static let regular:CGFloat = isPad ? 346.0 : 247.0
    }
}

