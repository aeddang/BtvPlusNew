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
    public static let appIcon = "AppIcon"
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
    private static let isPad =  AppUtil.isPad()
    struct brand {
        public static let logoLauncher =  "icLauncherSIos"
        public static let logoSplash =  "imgSplashLogo"
        public static let logoWhite =  "icHalfLogoBtv"
        public static let logo =  "imgSplashLogoBtv"
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
        public static let closeBlack = "icTopPopupCloseBT"
        public static let closeCircle = "icCategoryClose"
        public static let setting = "icTopSetting"
        
        public static let sortList =  "icSynopSorting"
        public static let dropDown =  "icSynopDropdownArrow"
        public static let alertInfo = "icMyAlert"
        public static let alertSmall = "icAlertS"
        public static let pairingWifi = "icPairing03"
        public static let pairingBtv = "icPairing02"
        public static let pairingUser = "icPairing01"
        public static let pairingWifi2 = "icPoupPairing01"
        public static let pairingBtv2 = "icPoupPairing02"
        public static let pairingUser2 = "icPoupPairing03"
        
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
        
        public static let agePlayerAll = "icPlayerGradeAll"
        public static let agePlayer19 = "icPlayerGrade18"
        public static let agePlayer15 = "icPlayerGrade15"
        public static let agePlayer12 = "icPlayerGrade12"
        
        public static let playerContentInfo1 = "icPlayerContentInfo01"
        public static let playerContentInfo2 = "icPlayerContentInfo02"
        public static let playerContentInfo3 = "icPlayerContentInfo03"
        public static let playerContentInfo4 = "icPlayerContentInfo04"
        public static let playerContentInfo5 = "icPlayerContentInfo05"
        public static let playerContentInfo6 = "icPlayerContentInfo06"
        public static let playerContentInfo7 = "icPlayerContentInfo07"
        
        public static let trophy = "icSynopTrophy"
        public static let ratingPrimary = "icSynopRatingS"
        
        public static let watcha = "icSynopWatcha"
        public static let share = "icSynopRecommendNor"
        public static let tip = "icSynopTip"
        
        public static let alarm = "icMyAlarm"
        public static let notice = "icMyNotice"
        public static let lockAlert = "icLockAlert"
        public static let profileEdit = "icMyProfileEdit"
        public static let alert = "icChannelAlert"
        public static let info = "icSynopInfo"
        public static let thumbPlay = "icThumPlay"
        public static let play = "icPlayerPlayS"
        public static let person = "ic-search-person-s"
        
        public static let cateEvent = "icCategoryBtnEvent"
        public static let cateTip = "icCategoryBtnTip"
        public static let cateBCash = "icCategoryBtnBcash"
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
        public static let btvliteFamily = "tagMyBtvliteFamily"
        public static let imminent = "tagMyEndSoon"
        public static let expiration = "tagMyEnd"
        public static let used = "tagMyUsed"
        
        public static let add = "icMyAddCouponPoint"
        public static let delete = "icMyDelete"
        public static let edit = "icMyEdit"
        
        public static let ticketMonthly = "tagMySubscribe"
        public static let ticketPeriod = "tagMySubscribe02"
        public static let represent = "tagMyRepresent"
        public static let logoOcean = "logoOcean"
        public static let logoZem = "icZem"
        public static let firstFree = "icFree"
        public static let oceanFree = "icOceanFree"
        public static let noticeAd = "icNoticeAdNor"
        public static let noticeCoupon = "icNoticeCouponNor"
        public static let noticePoint = "icNoticePointNor"
        public static let noticeRelease = "icNoticeReleaseNor"
        public static let noticeReserve = "icNoticeReserveNor"
        
        public static let readAllOff = "icMyReadDim"
        public static let readAll = "icMyReadNor"
        public static let recommend = "icMyRecommend"
        public static let btv = "icMyBtv"
        public static let purchase = "icMyPaidT"
        
        public static let stb = "icPopupPairingDefault"
        public static let recommendPoint = "icMyRecommendPoint"
        public static let addCard = "btnMyAddCard"
        public static let searchOnlyBtv = "icTagSearchOnlybtv"
        
        public static let onTop = "icBtnTop"
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
    
    struct remote {
        public static let close = "icRemoteClose"
        public static let center =  "icRemoteCenterNor"
        public static let centerUp =  "icRemoteCenter01Pre"
        public static let centerDown =  "icRemoteCenter02Pre"
        public static let centerLeft =  "icRemoteCenter03Pre"
        public static let centerRight =  "icRemoteCenter04Pre"
        public static let centerOk = "icRemoteCenterOk"
        public static let centerPlayStop = "icRemoteCenterPlayStop"
        public static let centerSkip = "icRemoteCenterSkipNor"
        public static let centerSkipPrev = "icRemoteCenterSkip01Pre"
        public static let centerSkipNext = "icRemoteCenterSkip02Pre"
        public static let channel = "icRemoteChannelNor"
        public static let channelUp = "icRemoteChannelUpPre"
        public static let channelDown = "icRemoteChannelDownPre"
        public static let chlist = "icRemoteChlistNor"
        public static let chlistOn = "icRemoteChlistPre"
        public static let chNumber = "icRemoteChNumberNor"
        public static let chNumberOn = "icRemoteChNumberPre"
        public static let earphone = "icRemoteEarphoneOff"
        public static let earphoneOn = "icRemoteEarphoneOn"
        public static let exit = "icRemoteExitNor"
        public static let exitOn = "icRemoteExitPre"
        public static let fastForward = "icRemoteFastForwardNor"
        public static let fastForwardOn = "icRemoteFastForwardPreT"
        public static let rewind = "icRemoteRewindNorT"
        public static let rewindOn = "icRemoteRewindPre"
        public static let refresh = "icRemoteRefresh"
        public static let home = "icRemoteHomeNor"
        public static let homeOn = "icRemoteHomePre"
        public static let text = "icRemoteTextNor"
        public static let textOn = "icRemoteTextPre"
        public static let multiview = "icRemoteMultiviewNor"
        public static let multiviewOn = "icRemoteMultiviewPre"
        public static let mute = "icRemoteMuteOff"
        public static let muteOn = "icRemoteMuteOn"
        public static let onair = "icRemoteOnair"
        public static let vod = "icRemoteVod"
        public static let on = "icRemoteOnNor"
        public static let onOn = "icRemoteOnPre"
        public static let previous = "icRemotePreviousNor"
        public static let previousOn = "icRemotePreviousPre"
        public static let vibrate = "icRemoteVibrateOff"
        public static let vibrateOn = "icRemoteVibrateOn"
        public static let volume = "icRemoteVolumeNor"
        public static let volumeUp = "icRemoteVolumePlusPre"
        public static let volumeDown = "icRemoteVolumeMinusPre"
        public static let bg = isPad ? "imgRemoteBg01" : "imgRemoteBg02"
    }
    
    struct shape {
        public static let radioBtnOn = "icRadioSOn"
        public static let radioBtnOff = "icRadioSOff"
        public static let checkBoxOn = "icCheckboxOn"
        public static let checkBoxDisable = "icCheckboxDisable"
        public static let checkBoxOn2 = "icCheckboxOn02"
        public static let checkBoxOff = "icCheckboxOff"
        public static let checkBoxOffWhite = "icCheckboxOffWhite"
        public static let spinner = "icSpinner"
        public static let tooltip = isPad ? "icSynopTooltipT" : "icSynopTooltip" 
        public static let topTooltip = "icTopTooltip"
        public static let bgGradientBottom = "bgGradientBottom"
        public static let bgGradientTop = "bgGradientTop"
        public static let bgCoupon = "imgMyListCoupon01"
        public static let recommandTip = "icSynopTooltipS"
        public static let recommandTipHorizontal = "icSynopTooltipST"
        public static let recommendPopupTicket = "icPopupTicket"
        public static let listGradient = "listGradient"
        public static let listGradientH = "listGradientH"
    }
    
    struct image {
        public static let noImgActor =  "imgSynopNoimageActor"
        public static let noImgVoice =  "imgSynopNoimageVoice"
        public static let noImgWriter =  "imgSynopNoimageWriter"
        public static let noImgDirector =  "imgSynopNoimageDirector"
        public static let cardMembership = "imgMyCardMembership"
        public static let cardOkcashbag = "imgMyCardOkcashbag"
        public static let cardTvpoint = "imgMyCardTvpoint"
        public static let pairingTutorial = "pairingTutorialS"
        public static let myConnectIos = "imgMyConnectIos"
        public static let bannerTopPairing = "imgBannerTopPairing"
        public static let intro01 = "imgIosIntro01"
        public static let intro02 = "imgIosIntro02"
        public static let intro03 = "imgIosIntro03"
        public static let intro04 = "imgIosIntro04"
        public static let introT01 = "imgIntroIos01T"
        public static let introT02 = "imgIntroIos02T"
        public static let introT03 = "imgIntroIos03T"
        public static let introT04 = "imgIntroIos04T"
        public static let pairingTutorial01 = "imgPairingTutorial01"
        public static let pairingTutorial02 = "imgPairingTutorial02"
        public static let pairingTutorial03 = "imgPairingTutorial03"
        public static let pairingTutorial04 = "imgPairingTutorial04"
        public static let empty = "imgMyEmpty01"
        public static let myEmpty = "imgMyEmpty01"
        public static let myEmpty2 = "imgMyEmpty02"
        public static let pairingCharacter = "imgPairingCharacter"
        public static let deviceEmpty = "imgPairingNostbB"
        
        
        public static let pairingHitchText01 = "imgPopupTitle01"
        public static let pairingHitchText02 = "imgPopupTitle02"
        public static let pairingHitch01 = "imgPopupCharecter01"
        public static let pairingHitch02 = "imgPopupCharecter02"
        
        public static let recommendDetail = "imgMyRecommendDetail"
        public static let recommendPopup = "imgSynopsisRecommendPopup"
        public static let pairindPopup = "imgPairingPopup01"
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
        
        static func getRemoteIcon(age:String?) -> String?{
            switch age {
            case "7": return Asset.icon.age7
            case "12": return Asset.icon.age12
            case "15": return Asset.icon.age15
            case "19": return Asset.icon.age19
            default: return nil
            }
        }
        
        static func getPlayerIcon(age:String?) -> String?{
            guard let age = age else{return nil}
            switch age {
            case "12": return Asset.icon.agePlayer12
            case "15": return Asset.icon.agePlayer15
            case "19": return Asset.icon.agePlayer19
            default: return Asset.icon.agePlayerAll
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
        static let brightnessList = [
            Asset.player.brightnessLv0,
            Asset.player.brightnessLv1,
            Asset.player.brightnessLv2,
            Asset.player.brightnessLv3,
            Asset.player.brightnessLv4,
            Asset.player.brightnessLv5
        ]
        
        static let volumeList = [
            Asset.player.volumeLv0,
            Asset.player.volumeLv1,
            Asset.player.volumeLv2,
            Asset.player.volumeLv3
        ]
        static let mic:[String] = (1...27).map{ "imgSearchMic" + $0.description.toFixLength(2) }
        static let record:[String] = (1...10).map{ "icRecoqIng" + $0.description.toFixLength(2) }
        static let alarm:[String] = (1...20).map{ "imgMyAlarm" + $0.description.toFixLength(2) }
        
        static let loading = "icPlayerLoadingSeq01"
    }
    
    static let characterList = [
        "imgProfile37",
        "imgProfile38",
        "imgProfile39",
        "imgProfile40",
        "imgProfile01",
        "imgProfile02",
        "imgProfile03",
        "imgProfile04",
        "imgProfile05",
        "imgProfile06",
        "imgProfile07",
        "imgProfile08",
        "imgProfile09",
        "imgProfile10",
        "imgProfile11",
        "imgProfile12",
        "imgProfile13",
        "imgProfile14",
        "imgProfile15",
        "imgProfile16",
        "imgProfile17",
        "imgProfile18",
        "imgProfile19",
        "imgProfile20",
        "imgProfile21",
        "imgProfile22",
        "imgProfile23",
        "imgProfile24",
        "imgProfile25",
        "imgProfile26",
        "imgProfile27",
        "imgProfile28",
        "imgProfile29",
        "imgProfile30",
        "imgProfile31",
        "imgProfile32",
        "imgProfile33",
        "imgProfile34",
        "imgProfile35",
        "imgProfile36"
    ]
    
    
}
