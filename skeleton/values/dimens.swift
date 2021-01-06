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
        public static let medium:CGFloat = 30 //*
        public static let regular:CGFloat = 20 //*
        public static let regularExtra:CGFloat = 16 //*
        public static let light:CGFloat = 14 //*
        public static let lightExtra:CGFloat = 12 //*
        public static let thin:CGFloat = 10 //*
        public static let thinExtra:CGFloat = 8 //*
        public static let tiny:CGFloat = 6 //*
        public static let tinyExtra:CGFloat = 2 //*
        
        public static let header:CGFloat = 50 //*
        public static let footer:CGFloat = 42 //*
        //public static let listBottom:CGFloat = 25 //*
    }

    struct icon {
        public static let heavy:CGFloat = 50
        public static let medium:CGFloat = 40 //*
        public static let regular:CGFloat = 36 //*
        public static let regularExtra:CGFloat = 38  //*
        public static let light:CGFloat = 25 //*
        public static let thin:CGFloat = 22 //*
        public static let thinExtra:CGFloat = 20  //*
        public static let tiny:CGFloat = 8
    }
    
    struct tab {
        public static let titleWidth:CGFloat = 60
        public static let heavy:CGFloat = 80
        public static let regular:CGFloat = 46 //*
        public static let light:CGFloat = 42
    }
    
    struct button {
       
        public static let heavy:CGFloat = 80
        public static let medium:CGFloat = 50 //*
        public static let regular:CGFloat = 40 //*
        public static let light:CGFloat = 31
        public static let thin:CGFloat = 28
    }

    struct radius {
        
        public static let heavy:CGFloat = 25
        public static let regular:CGFloat = 20
        public static let medium:CGFloat = 10
        public static let light:CGFloat = 8
        public static let thin:CGFloat = 5
    }
    
    struct line {
        public static let heavy:CGFloat = 10
        public static let regular:CGFloat = 3
        public static let light:CGFloat = 1
    }
    
    struct stroke {
        public static let heavy:CGFloat = 3
        public static let regular:CGFloat = 2 //*
        public static let light:CGFloat = 1
    }
    
    struct app {
       public static let bottom:CGFloat = 60
       public static let top:CGFloat = 80
       public static let pageTop:CGFloat = 62
    }
    
}

