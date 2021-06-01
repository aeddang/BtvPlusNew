//
//  font.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/05.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct FontKids{
    private static let isPad =  AppUtil.isPad()
    
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
        
    }
    
    struct kern {
        public static let thin:CGFloat =  -0.7
        public static let regular:CGFloat = 0
        public static let large:CGFloat = 0.7
    }
    
    struct size {
        public static let black:CGFloat =  isPad ? 52 : 32
        public static let bold:CGFloat = isPad ? 42 : 26
        public static let large:CGFloat =  isPad ? 30 : 22
        public static let medium:CGFloat = isPad ? 28 : 20
        public static let regular:CGFloat = isPad ? 24 : 16
        public static let light:CGFloat =  isPad ? 21 : 15
        public static let thin:CGFloat = isPad ? 18 : 13
        public static let tiny:CGFloat = isPad ? 16 : 11
        public static let micro:CGFloat = isPad ? 13 : 9
        
    }
    
}
