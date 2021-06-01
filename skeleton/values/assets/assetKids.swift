//
//  asset.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/15.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
struct AssetKids {}
extension AssetKids {
    public static let noImg16_9 = "imgDefaultPosterThum"
    public static let noImg4_3 = "imgDefaultMonthlyCardB"
    public static let noImg1_1 = "img07CardDefault"
    public static let noImgCircle1_1 = "img05CardDefault"
    public static let noImg9_16 = "imgDefaultPosterSmall"
    public static let noImg3_4 = "imgDefaultPosterSmall02"
    public static let noImgBanner = "img09CardBannerDefault"
}
extension AssetKids{
    struct brand {
       
    }
    
    struct gnbTop {
        public static let monthly = "zemkidsMGnbTopNorMonthly"
        public static let exit = "zemkidsMGnbTopNorOut"
        public static let search = "zemkidsMGnbTopNorSearch"
    }
    
   
    
    struct icon {
        public static let new =  "tagMyNewS"
    }
    
    
    struct player {
        public static let more = "icPlayerFullMore"
        public static let lock = "icPlayerFullLock"
        public static let resume = "icPlayerPlay"
        public static let pause = "icPlayerPause"
        
        public static let fullScreen = "icPlayerHalfScalemax"
        public static let fullScreenOff = "icPlayerFullScalemin"
        public static let volumeOn = "icPlayerHalfVolume"
        public static let volumeOff = "icPlayerHalfVolumeMute"
        public static let seekForward = "icPlayerHalfTimeNext"
        public static let seekBackward = "icPlayerHalfTimePrevious"
        public static let volumeLv0 = "icPlayerHalfVolume0"
        public static let volumeLv1 = "icPlayerHalfVolume1"
        public static let volumeLv2 = "icPlayerHalfVolume6"
        public static let volumeLv3 = "icPlayerHalfVolume11"
        public static let brightnessLv0 = "icPlayerHalfBrightness0"
        public static let brightnessLv1 = "icPlayerHalfBrightness1"
        public static let brightnessLv2 = "icPlayerHalfBrightness4"
        public static let brightnessLv3 = "icPlayerHalfBrightness8"
        public static let brightnessLv4 = "icPlayerHalfBrightness12"
        public static let brightnessLv5 = "icPlayerHalfBrightness15"
        
        public static let guide = "playerCoachmarkFull"
        public static let popupBgFull = "icPlayerFullPopup"
        public static let popupBg = "icPlayerHalfPopup"
    }
    
    
    struct shape {
        public static let radioBtnOn = "icRadioSOn"
        public static let radioBtnOff = "icRadioSOff"
        public static let checkBoxOn = "icCheckboxOn"
        public static let checkBoxOn2 = "icCheckboxOn02"
        public static let checkBoxOff = "icCheckboxOff"
        public static let spinner = "icSpinner"
       
    }
    
    struct image {
        
    }
    
    struct source {
        
    }
    
    struct ani {
        public static let splash:[String] = (0...47).map{ "zemkidsMSplash" + $0.description.toFixLength(2) }
        public static let loading:[String] = (0...59).map{ "zemkidsMLoading" + $0.description.toFixLength(2) }
        
    }
    
    
}
