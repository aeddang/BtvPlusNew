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
        public static let heavy:CGFloat = isPad ? 90 : 46
        public static let heavyExtra:CGFloat = isPad ? 112 : 52//*
        public static let mediumUltra:CGFloat = isPad ? 60 : 40//*
        public static let medium:CGFloat = isPad ? 55 : 29//*
        public static let mediumExtra:CGFloat = isPad ? 42 : 23//*
        public static let regular:CGFloat = isPad ? 39 : 20//*
        public static let regularExtra:CGFloat = isPad ? 35 : 18//*
        public static let light:CGFloat = isPad ? 27 : 14//*
        public static let lightExtra:CGFloat = isPad ? 25 : 13//*
        public static let thinUltra:CGFloat = isPad ? 20 : 10//*
        public static let thin:CGFloat = isPad ? 18 : 10//*
        public static let thinExtra:CGFloat = isPad ? 14 : 8//*
        public static let tiny:CGFloat = isPad ? 10 : 6//*
        public static let tinyExtra:CGFloat = isPad ? 9 : 5//*
        public static let micro:CGFloat = isPad ? 4 : 2
        public static let microExtra:CGFloat = isPad ? 2 : 1
    }

    struct icon {
        public static let heavy:CGFloat = isPad ? 123 : 76//*
        public static let heavyExtra:CGFloat = isPad ? 110 : 70//*
        public static let mediumUltra:CGFloat = isPad ? 89 : 46//*
        public static let medium:CGFloat = isPad ? 76 : 42//*
        public static let mediumExtra:CGFloat = isPad ? 58 : 36//*
        public static let regular:CGFloat = isPad ? 53 : 32 //*
        public static let regularExtra:CGFloat = isPad ? 50 : 30 //*
        public static let light:CGFloat = isPad ? 50 : 26//*
        public static let thin:CGFloat = isPad ? 40 : 22//*
        public static let thinExtra:CGFloat = isPad ? 39 : 20//*
        public static let tiny:CGFloat = isPad ? 33 : 18//*
        public static let tinyExtra:CGFloat = isPad ? 26 : 16//*
        public static let micro:CGFloat = isPad ? 20 : 10//*
        public static let microExtra:CGFloat = isPad ? 16 : 9//*
    }
    
    struct tab {
        public static let titleWidth:CGFloat = isPad ? 100 : 60
        public static let heavy:CGFloat = 72
        public static let medium:CGFloat = isPad ? 80 : 56
        public static let regular:CGFloat = isPad ? 63 : 46
        public static let light:CGFloat =  isPad ? 63 : 33//*
        public static let lightExtra:CGFloat =  isPad ? 54 : 28//*
        public static let thin:CGFloat = isPad ? 48 : 18 //* pad
    }
    
    struct button {
        public static let heavy:CGFloat =  80
        public static let medium:CGFloat = isPad ? 60 : 50
        public static let regular:CGFloat = isPad ? 67 : 32 //*
        public static let regularExtra:CGFloat = isPad ? 49 : 30 //*
        public static let light:CGFloat = isPad ? 46 : 24 //*
        public static let thin:CGFloat = isPad ? 46 : 24 
        
        public static let heavyRect:CGSize = isPad ? CGSize(width: 258, height: 73) : CGSize(width: 159, height: 38)//*
        public static let mediumRect:CGSize = isPad ? CGSize(width: 221, height: 73) : CGSize(width: 115, height: 38) //*
        public static let regularRect:CGSize = isPad ? CGSize(width: 173, height: 115) : CGSize(width: 90, height: 60) //*
        public static let lightRect:CGSize = isPad ? CGSize(width: 90, height: 60) : CGSize(width: 50, height: 34) //*
       
    }

    struct radius {
        public static let heavy:CGFloat = isPad ? 38 : 20//**
        public static let heavyExtra:CGFloat = isPad ? 33 : 18//*pad
        public static let medium:CGFloat = isPad ? 24 : 17//**
       
        public static let regular:CGFloat = isPad ? 20 : 12
        public static let light:CGFloat =  isPad ? 15 : 8//**
        public static let lightExtra:CGFloat =  isPad ? 9 : 6//**
        public static let thin:CGFloat = 2
        public static let tiny:CGFloat = isPad ? 6 : 4//**
        public static let micro:CGFloat = isPad ? 3 : 2//**
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
      
        public static let heavy:CGFloat = isPad ? 11 : 7 //*
        public static let medium:CGFloat = isPad ? 7 : 4 //*
        public static let mediumExtra:CGFloat = isPad ? 6 : 3 //*
        public static let regular:CGFloat = isPad ? 4 : 2
        public static let light:CGFloat = isPad ? 2 : 1
    }
    
    struct app {
        public static let top:CGFloat = isPad ? 80 : 42 //*
        public static let gnbTop:CGFloat = isPad ? 129 : 74 //*
        public static let pageTop:CGFloat = isPad ? 130 : 80 //*
        public static let keyboard:CGFloat = isPad ? 400 : 300
    }
    
    struct loading {
        static let large:CGSize = isPad ? CGSize(width: 436, height: 530) : CGSize(width: 227, height:  276)//*
        static let small:CGSize = isPad ?  CGSize(width: 60, height: 72) : CGSize(width: 40, height:  48) //*
    }
    
    struct item {
        static let profileRegist:CGSize =  isPad ? CGSize(width: 150, height: 150) : CGSize(width: 78, height:  78)//*
        static let profileGnb:CGSize =  isPad ? CGSize(width: 57, height:  57) : CGSize(width: 37, height:  37)//*
        static let profile:CGSize =  isPad ? CGSize(width: 58, height:  58) : CGSize(width: 30, height:  30)//*
        static let profileList:CGSize =  isPad ? CGSize(width: 259, height:  326) : CGSize(width: 160, height:  201)//*
        
        static let inputNum:CGSize =  isPad ? CGSize(width: 88, height:  88) : CGSize(width: 46, height:  46)//*
        
    }
}

