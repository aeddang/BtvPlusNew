//
//  asset.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/15.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
struct Asset {}
extension Asset {
    public static let noImg16_9 = "imgDefaultPosterThum"
    public static let noImg4_3 = "imgDefaultMonthlyCardB"
    public static let noImg1_1 = "img07CardDefault"
    public static let noImgCircle1_1 = "img05CardDefault"
    
    public static let noImg9_16 = "imgDefaultPosterSmall"
    public static let noImg3_4 = "imgDefaultPosterSmall02"

    public static let noImgBanner = "img09CardBannerDefault"
    public static let test = "test"
}
extension Asset{
    
    struct bland {
        public static let logoLauncher =  "icLauncherSIos"
        public static let logoSplash =  "imgSplashLogo"
    }
    
    struct gnbTop {
        public static let my =  "icTopMyBasic"
        public static let remote =  "icTopRemote"
        public static let schedule =  "icTopSchedule"
        public static let search =  "icTopSearch"
        public static let zemkids =  "icTopZemkids"
    }
    
    struct gnbBottom {
        public static let categoryOn =  "icGnbFocCategory"
        public static let freeOn =  "icGnbFocFree"
        public static let homeOn =  "icGnbFocHome"
        public static let paymentOn =  "icGnbFocPayment"
        public static let oceanOn =  "icGnbFocOcean"
        
        public static let categoryOff =  "icGnbNorCategory"
        public static let freeOff =  "icGnbNorFree"
        public static let homeOff =  "icGnbNorHome"
        public static let paymentOff =  "icGnbNorPayment"
        public static let oceanOff =  "icGnbNorOcean"
    }
    
    struct icon {
        public static let new =  "tagMyNewS"
        public static let sort = "icArrowDownG"
        public static let back = "icTopBack"
        public static let more = "icArrowRight"
        public static let close = "icTopClose"
        
    }
    
    struct shape {
        public static let radioBtnOn = "icRadioSOff"
        public static let radioBtnOff = "icRadioSOn"
        public static let checkBoxOn = "icCheckboxOn"
        public static let checkBoxOff = "icCheckboxOff"
        
        
    }
}
