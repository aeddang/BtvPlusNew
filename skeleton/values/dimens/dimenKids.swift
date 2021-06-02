//
//  dimens.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct DimenKids{
    private static let isPad =  AppUtil.isPad()
    struct margin {
        public static let heavy:CGFloat = isPad ? 100 : 46
        public static let medium:CGFloat = isPad ? 69 : 30
        public static let regular:CGFloat = isPad ? 40 : 20//*
        public static let regularExtra:CGFloat = isPad ? 40 : 18//*
        public static let light:CGFloat = isPad ? 28 : 14
        public static let thin:CGFloat = isPad ? 20 : 10
        public static let tiny:CGFloat = isPad ? 12 : 6
        public static let micro:CGFloat = isPad ? 4 : 2
    }

    struct icon {
        public static let heavy:CGFloat = isPad ? 123 : 70//*
        public static let medium:CGFloat = isPad ? 54 : 40
        public static let regular:CGFloat = isPad ? 48 : 32
        public static let light:CGFloat = isPad ? 30 : 27
        public static let thin:CGFloat = isPad ? 26 : 22
        public static let tiny:CGFloat = isPad ? 21 : 17
        public static let micro:CGFloat = 12
    }
    
    struct tab {
        public static let titleWidth:CGFloat = isPad ? 100 : 60
        public static let heavy:CGFloat = 72
        public static let medium:CGFloat = isPad ? 80 : 56
        public static let regular:CGFloat = isPad ? 63 : 46
        public static let light:CGFloat =  isPad ? 42 : 36
        public static let thin:CGFloat = isPad ? 26 : 18
    }
    
    struct button {
        public static let heavy:CGFloat =  80
        public static let medium:CGFloat = isPad ? 60 : 50
        public static let regular:CGFloat = isPad ? 56 : 40
        public static let light:CGFloat = isPad ? 37 : 32
        public static let thin:CGFloat = isPad ? 24 : 20
        
        public static let heavyRect:CGSize = isPad ? CGSize(width: 130, height: 60) : CGSize(width: 90, height: 42)
        public static let mediumRect:CGSize = isPad ? CGSize(width: 221, height: 73) : CGSize(width: 115, height: 38) //*
        public static let regularRect:CGSize = isPad ? CGSize(width: 78, height: 40) : CGSize(width: 48, height: 25)
        public static let lightRect:CGSize = isPad ? CGSize(width: 61, height: 29) : CGSize(width: 38, height: 20)
       
    }

    struct radius {
        public static let heavy:CGFloat = isPad ? 38 : 20//**
        public static let medium:CGFloat = 14
        public static let regular:CGFloat = 12
        public static let light:CGFloat =  isPad ? 15 : 8//**
        public static let thin:CGFloat = 2
    }
    
    struct bar {
        public static let medium:CGFloat = isPad ? 30 : 20
        public static let regular:CGFloat = 7
    }
    
    struct line {
        public static let heavy:CGFloat = 10
        public static let medium:CGFloat = isPad ? 4 : 3
        public static let regular:CGFloat = isPad ? 3 : 2
        public static let light:CGFloat = 1
    }
    
    struct stroke {
        public static let heavy:CGFloat = isPad ? 10 : 5
        public static let medium:CGFloat = isPad ? 6 : 3
        public static let regular:CGFloat = isPad ? 4 : 2
        public static let light:CGFloat = isPad ? 2 : 1
    }
    
    struct app {
        public static let top:CGFloat = isPad ? 42 : 42 //*
        public static let gnbTop:CGFloat = isPad ? 74 : 74 //*
        public static let pageTop:CGFloat = isPad ? 80 : 80 //*
        public static let keyboard:CGFloat = isPad ? 400 : 300
    }
    
    struct item {
        static let profileGnb:CGSize = CGSize(width: 37, height:  37)//*
        static let profile:CGSize = CGSize(width: 30, height:  30)//*
    }
}

