//
//  font.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/05.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI


extension Font{
    struct customFont {
        public static let light =  Font.custom(Font.family.light, size: Font.size.light)
        public static let regular = Font.custom(Font.family.regular, size: Font.size.regular)
        public static let medium = Font.custom(Font.family.medium, size: Font.size.medium)
        public static let bold = Font.custom(Font.family.bold, size: Font.size.bold)
        public static let black = Font.custom(Font.family.black, size: Font.size.black)
    }
    
    
    struct family {
        public static let thin =  "SKBtvLight"
        public static let light =  "SKBtvLight"
        public static let regular = "SKBtvMedium"
        public static let medium =  "SKBtvMedium"
        public static let bold =  "SKBtvBold"
        public static let black =  "SKBtvBold"
        
        public static let robotoBold = "Roboto-Bold"
        public static let robotoMedium = "Roboto-Medium"
        public static let robotoLight = "Roboto-Light"
    }    
    
    struct size {
        public static let heavy:CGFloat = 40
        public static let black:CGFloat = 32 //*
        public static let bold:CGFloat = 26 //*
        public static let boldExtra:CGFloat = 24 //*
        public static let large:CGFloat = 22 //*
        public static let medium:CGFloat = 20 //*
        public static let mediumExtra:CGFloat = 18 //*
        public static let regular:CGFloat = 16//*
        public static let light:CGFloat = 15 //*
        public static let lightExtra:CGFloat = 14 //*
        public static let thin:CGFloat = 13 //*
        public static let thinExtra:CGFloat = 12 //*
        public static let tiny:CGFloat = 11 //*
        public static let tinyExtra:CGFloat = 10 //*
    }

}
