//
//  colors.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
extension Color {
    init(rgb: Int) {
        let r = Double((rgb >> 16) & 0xFF)/255.0
        let g = Double((rgb >> 8) & 0xFF)/255.0
        let b = Double((rgb ) & 0xFF)/255.0
        self.init(
            red: r,
            green: g,
            blue: b
        )
    }
    
    struct brand {
        public static let primary = Color.init(red: 244/255, green: 101/255, blue: 52/255)
        public static let primaryLight = Color.init(red: 255/255, green: 237/255, blue: 236/255)
        public static let secondary = Color.init(red: 60/255, green:61/255, blue: 83/255)
        public static let thirdly = Color.init(red: 82/255, green:165/255, blue: 255/255)
        public static let accent =  Color.init(red: 190/255, green:25/255, blue: 25/255)
        public static let bg =  app.blue
    }
    struct kids {
        public static let primary = Color.init(red: 255/255, green: 96/255, blue: 42/255)
        public static let primaryExtra = Color.init(red: 241/255, green: 177/255, blue: 134/255)
        public static let primaryLight = Color.init(red: 219/255, green: 144/255, blue: 82/255)
        //public static let secondary = Color.init(red: 60/255, green:61/255, blue: 83/255)
        //public static let thirdly = Color.init(red: 82/255, green:165/255, blue: 255/255)
        
        public static let bg =  app.ivory
        
    
    }
    struct app {
        public static let black =  Color.black
        public static let blackExtra =  Color.init(red: 20/255, green: 20/255, blue: 20/255)
        public static let blackDeep =  Color.init(red: 65/255, green: 65/255, blue: 65/255)
        public static let blackLight =  Color.init(red: 83/255, green: 83/255, blue: 83/255)
       
        public static let grey = Color.init(red: 136/255, green: 136/255, blue: 136/255)
        public static let greyExtra = Color.init(red: 153/255, green: 153/255, blue: 153/255)
        public static let greyDeep = Color.init(red: 170/255, green: 170/255, blue: 170/255)
        public static let greyLight = Color.init(red: 212/255, green: 212/255, blue: 212/255)
        public static let greyLightExtra = Color.init(red: 204/255, green: 204/255, blue: 204/255)
        
        public static let white =  Color.white
        public static let whiteDeep = Color.init(red: 245/255, green: 245/255, blue: 245/255)
        
        public static let blueLight = Color.init(red: 29/255, green: 21/255, blue: 80/255)
        public static let blueLightExtra = Color.init(red: 49/255, green: 39/255, blue: 117/255)
        public static let blue = Color.init(red: 17/255, green: 3/255, blue: 58/255)
        public static let blueExtra = Color.init(red: 0/255, green: 78/255, blue: 162/255)
        public static let blueDeep = Color.init(red: 11/255, green: 1/255, blue: 39/255)
        
        public static let brownLight = Color.init(red: 137/255, green: 95/255, blue: 55/255)
        public static let brown = Color.init(red: 102/255, green: 63/255, blue: 44/255)
        public static let brownDeep = Color.init(red: 80/255, green: 48/255, blue: 37/255)
        
        public static let ivory = Color.init(red: 255/255, green: 236/255, blue: 206/255)
        public static let ivoryLight = Color.init(red: 250/255, green: 239/255, blue: 216/255)
        
        
    }
    
    struct transparent {
        public static let clear = Color.black.opacity(0.0)
        public static let clearUi = Color.black.opacity(0.0001)
        public static let black70 = Color.black.opacity(0.7)
        public static let black50 = Color.black.opacity(0.5)
        public static let black45 = Color.black.opacity(0.45)
        public static let black15 = Color.black.opacity(0.15)
        
        public static let white70 = Color.white.opacity(0.7)
        public static let white50 = Color.white.opacity(0.5)
        public static let white45 = Color.white.opacity(0.45)
        public static let white20 = Color.white.opacity(0.20) 
        public static let white15 = Color.white.opacity(0.15)
    }
}


