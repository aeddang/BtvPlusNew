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
    struct margin {
        public static let heavy:CGFloat = 46 //*
        public static let heavyExtra:CGFloat = 40 //*
        public static let medium:CGFloat = 30 //*
        public static let mediumExtra:CGFloat = 24 //*
        public static let regular:CGFloat = 20 //*
        public static let regularExtra:CGFloat = 16 //*
        public static let light:CGFloat = 14 //*
        public static let lightExtra:CGFloat = 12 //*
        public static let thin:CGFloat = 10 //*
        public static let thinExtra:CGFloat = 8 //*
        public static let tiny:CGFloat = 6 //*
        public static let tinyExtra:CGFloat = 5 //*
        public static let micro:CGFloat = 2
        
        public static let header:CGFloat = 50 //*
        public static let footer:CGFloat = 42 //*
        //public static let listBottom:CGFloat = 25 //*
    }

    struct icon {
        public static let heavy:CGFloat = 69 //*
        public static let heavyExtra:CGFloat = 58 //*
        public static let mediumUltra:CGFloat = 47 //*
        public static let medium:CGFloat = 40 //*
        public static let mediumExtra:CGFloat = 38  //*
        public static let regular:CGFloat = 36 //*
        public static let regularExtra:CGFloat = 32 //*
        public static let light:CGFloat = 25 //*
        public static let thin:CGFloat = 22 //*
        public static let thinExtra:CGFloat = 20  //*
        public static let tiny:CGFloat = 17//*
        public static let tinyExtra:CGFloat = 14//*
    }
    
    struct tab {
        public static let titleWidth:CGFloat = 60
        public static let heavy:CGFloat = 72
        public static let regular:CGFloat = 46 //*
        public static let light:CGFloat = 42
    }
    
    struct button {
        public static let heavy:CGFloat = 80
        public static let medium:CGFloat = 50 //*
        public static let regular:CGFloat = 40 //*
        public static let regularExtra:CGFloat = 35 //*
        public static let light:CGFloat = 32 //*
        public static let lightExtra:CGFloat = 30//*
        public static let thin:CGFloat = 20//*
        
        public static let heavyRect:CGSize = CGSize(width: 90, height: 42)//*
        public static let mediumRect:CGSize = CGSize(width: 79, height: 30)//*
        public static let mediumExtraRect:CGSize = CGSize(width: 62, height: 30)//*
        public static let regularRect:CGSize = CGSize(width: 48, height: 25)//*
        public static let lightRect:CGSize = CGSize(width: 38, height: 20)//*
    }

    struct radius {
        
        public static let heavy:CGFloat = 25
        public static let regular:CGFloat = 20
        public static let medium:CGFloat = 10//*
        public static let light:CGFloat = 8
        public static let thin:CGFloat = 2//*
    }
    
    struct line {
        public static let heavy:CGFloat = 10
        public static let medium:CGFloat = 3 //*
        public static let regular:CGFloat = 2 //*
        public static let light:CGFloat = 1 //*
    }
    
    struct stroke {
        public static let heavy:CGFloat = 5 //*
        public static let regular:CGFloat = 2 //*
        public static let light:CGFloat = 1 //*
    }
    
    struct app {
       public static let bottom:CGFloat = 60 //*
       public static let top:CGFloat = 80 //*
       public static let pageTop:CGFloat = 62 //*
    }
    
}

