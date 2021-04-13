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
    struct brand {
        public static let logoLauncher =  "icLauncherSIos"
        public static let logoSplash =  "imgSplashLogo"
        public static let logoWhite =  "icHalfLogoBtv"
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
        public static let down = "icArrowDownG"
        
        public static let directLeft = "icArrowIcPopupArrowLeftG"
        public static let directRight = "icArrowIcPopupArrowRightG"
        
        public static let back = "icTopBack"
        public static let more = "icArrowRight"
        public static let moreSmall = "icArrowRightWhite"
        public static let close = "icTopClose"
        public static let setting = "icTopSetting"
        
        public static let sortList =  "icSynopSorting"
        public static let dropDown =  "icSynopDropdownArrow"
       
        public static let alertSmall = "icAlertS"
        public static let pairingWifi = "icPairing03"
        public static let pairingBtv = "icPairing02"
        public static let pairingUser = "icPairing01"
        
        public static let watchBTv = "icSynopTvNor"
        public static let likeOff = "icSynopRatingDownFoc"
        public static let likeOn = "icSynopRatingFoc"
        public static let like = "icSynopRatingNor"
        public static let likeThin = "icReleaseRatingNor"
        
        public static let goodOn = "icPopupGoodFoc"
        public static let goodOff = "icPopupGoodNor"
        public static let badOn = "icPopupBadFoc"
        public static let badOff = "icPopupBadNor"
        
        
        public static let heartOn = "icSynopStarFoc"
        public static let heartOff = "icSynopStarNor"
        public static let heartSmallOn = "icMyStarFoc"
        public static let heartSmallOff = "icChannelNorStar"
        
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
        public static let lockAlert = "icLockAlert"
        public static let profileEdit = "icMyProfileEdit"
        public static let alert = "icChannelAlert"
        public static let info = "icSynopInfo"
        public static let thumbPlay = "icThumPlay"
        public static let play = "icPlayerPlayS"
        
        public static let cateEvent = "icCategoryBtnEvent"
        public static let cateTip = "icCategoryBtnTip"
        
        public static let alarmOn = "icSynopAlarmFoc"
        public static let alarmOff = "icSynopAlarmNor"
        public static let dragDown = "icDragDown"
        
        public static let mic = "icPopupMic"
        public static let searchMic = "icMicS"
        public static let micError = "icMicError"
        public static let location = "icPopupLocation"
        public static let searchDelete = "icSearchDelete"
        
        public static let itemRock = "ic19Lock"
        public static let itemAge19 = "tagPoster19"
        public static let itemDiscount = "tagPosterDiscount"
        public static let itemEven = "tagPosterEvent"
        public static let itemRangking = "tagPosterRangking"
        public static let onAir = "tagSynopOnair"
        public static let onAirOff = "tagSynopOffair"
        public static let btvlite = "tagMyBtvlite"
        public static let imminent = "tagMyEndSoon"
        public static let expiration = "tagMyEnd"
        public static let used = "tagMyUsed"
        
        public static let add = "icMyAddCouponPoint"
        public static let delete = "icMyDelete"
        public static let edit = "icMyEdit"
        
        public static let ticketMonthly = "tagMySubscribe"
        public static let ticketPeriod = "tagMySubscribe02"
        public static let represent = "tagMyRepresent"
        
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
        public static let tooltip = "icSynopTooltip"
        
        public static let bgGradientBottom = "bgGradientBottom"
        public static let bgGradientTop = "bgGradientTop"
        public static let bgCoupon = "imgMyListCoupon01"
    }
    
    struct image {
        public static let noImgActor =  "imgSynopNoimageActor"
        public static let noImgVoice =  "imgSynopNoimageVoice"
        public static let noImgWriter =  "imgSynopNoimageWriter"
        public static let noImgDirector =  "imgSynopNoimageDirector"
        public static let cardMembership = "imgMyCardMembership"
        public static let cardOkcashbag = "imgMyCardOkcashbag"
        public static let cardTvpoint = "imgMyCardTvpoint"
    }
    
    struct source {
        public static let pairingTutorial = "pairingTutorialS"
        public static let myConnectIos = "imgMyConnectIos"
        public static let bannerTopPairing = "imgBannerTopPairing"
        public static let intro01 = "imgIosIntro01"
        public static let intro02 = "imgIosIntro02"
        public static let intro03 = "imgIosIntro03"
        public static let empty = "imgMyEmpty01"
        public static let myEmpty = "imgMyEmpty01"
        public static let deviceEmpty = "imgPairingNostbB"
    }
    
    struct age {
        static func getIcon(age:String?) -> String {
            switch age {
            case "7": return Asset.icon.age7
            case "12": return Asset.icon.age12
            case "15": return Asset.icon.age15
            case "19": return Asset.icon.age19
            default: return Asset.icon.ageAll
            }
        }
        static func getListIcon(age:String?) -> String?{
            switch age {
            case "19": return Asset.icon.itemAge19
            default: return nil
            }
        }
    }
    
    struct ani {
        public static let mic:[String] = (1...27).map{ "imgSearchMic" + $0.description.toFixLength(2) }
        public static let record:[String] = (1...10).map{ "icRecoqIng" + $0.description.toFixLength(2) }
    }
    
    
}
