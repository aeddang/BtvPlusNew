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
        public static let moreSmall = "icArrowRightWhite"
        public static let close = "icTopClose"
        public static let setting = "icTopSetting"
       
        public static let alertSmall = "icAlertS"
        public static let pairingWifi = "icPairing03"
        public static let pairingBtv = "icPairing02"
        public static let pairingUser = "icPairing01"
        
        public static let watchBTv = "icSynopTvNor"
        public static let likeOff = "icSynopRatingDownFoc"
        public static let likeOn = "icSynopRatingFoc"
        public static let like = "icSynopRatingNor"
        
        public static let goodOn = "icPopupGoodFoc"
        public static let goodOff = "icPopupGoodNor"
        public static let badOn = "icPopupBadFoc"
        public static let badOff = "icPopupBadNor"
        
        
        public static let heartOn = "icSynopStarFoc"
        public static let heartOff = "icSynopStarNor"
        public static let ageAll = "icSynopAgeAll"
        public static let age19 = "icSynopAge19"
        public static let age15 = "icSynopAge15"
        public static let age12 = "icSynopAge12"
        public static let age7 = "icSynopAge7"
        public static let trophy = "icSynopTrophy"
        public static let ratingPrimary = "icSynopRatingS"
        
        public static let watcha = "icSynopWatcha"
        public static let share = "icSynopShareNor"
        public static let tip = "icSynopTip"
        
        public static let alarm = "icMyAlarm"
        public static let notice = "icMyNotice"
        public static let profileEdit = "icMyProfileEdit"
        public static let alert = "icChannelAlert"
        
        public static let thumbPlay = "icThumPlay"
        
    }
    
    
    struct player {
        public static let more = "icPlayerHalfMore"
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
        public static let noImgActor =  "imgSynopNoimageActor"
        public static let noImgVoice =  "imgSynopNoimageVoice"
        public static let noImgWriter =  "imgSynopNoimageWriter"
        public static let noImgDirector =  "imgSynopNoimageDirector"
    }
    
    struct source {
        public static let pairingTutorial = "pairingTutorialS"
        public static let myConnectIos = "imgMyConnectIos"
    }
    
    
}
