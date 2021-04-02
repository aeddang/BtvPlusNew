//
//  strings.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

extension String {
    func loaalized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    struct app {
        public static let appName = "appName".loaalized()
        public static let corfirm = "corfirm".loaalized()
        public static let close = "close".loaalized()
        public static let cancel = "cancel".loaalized()
        public static let retry = "retry".loaalized()
        
        public static let nickName = "nickName".loaalized()
        public static let nickNameHolder = "nickNameHolder".loaalized()
        public static let nickNameValidation = "nickNameValidation".loaalized()
        public static let nickNameInvalidation = "nickNameInvalidation".loaalized()
        public static let birth = "birth".loaalized()
        public static let gender = "gender".loaalized()
        public static let mail = "mail".loaalized()
        public static let femail = "femail".loaalized()
        
        public static let min = "min".loaalized()
        public static let hour = "hour".loaalized()
        public static let day = "day".loaalized()
        public static let week = "week".loaalized()
        public static let month = "month".loaalized()
        public static let year = "year".loaalized()
        public static let cash = "cash".loaalized()
        public static let total = "total".loaalized()
        public static let certificationNumber = "certificationNumber".loaalized()
        public static let certificationNumberHolder = "certificationNumberHolder".loaalized()
        public static let macAdress = "macAdress".loaalized()
        
        public static let rent = "rent".loaalized()
        public static let owner = "owner".loaalized()
        public static let defaultStb = "defaultStb".loaalized()
        public static let another = "another".loaalized()
        public static let count = "count".loaalized()
        public static let broCount = "broCount".loaalized()
        public static let sesonCount = "sesonCount".loaalized()
        public static let ageCount = "ageCount".loaalized()
        public static let award = "award".loaalized()
        
        public static let ppmUpdate = "ppmUpdate".loaalized()
        public static let open = "open".loaalized()
        
        public static let mic = "mic".loaalized()
        public static let location = "location".loaalized()
        public static let select = "select".loaalized()
        public static let todayUnvisible = "todayUnvisible".loaalized()
        public static let watch = "watch".loaalized()
        public static let watchAble = "watchAble".loaalized()
        public static let cast = "cast".loaalized()
        
        public static let free = "free".loaalized()
        public static let vod = "vod".loaalized()
        public static let sris = "sris".loaalized()
        public static let corner = "corner".loaalized()
        public static let people = "people".loaalized()
        public static let ticket = "ticket".loaalized()
        public static let coupon = "coupon".loaalized()
        public static let bpoint = "bpoint".loaalized()
        public static let bcash = "bcash".loaalized()
        public static let lockAdult = "lockAdult".loaalized()
    }
    
    struct week {
        static func getDayString(day:Int) -> String{
            switch day {
            case 2 : return "mon".loaalized()
            case 3 : return "tue".loaalized()
            case 4 : return "wed".loaalized()
            case 5 : return "thu".loaalized()
            case 6 : return "fri".loaalized()
            case 7 : return "sat".loaalized()
            case 1 : return "sun".loaalized()
            default : return ""
            }
        }
    }
    
    
    struct sort {
        public static let langTitle = "sortLangTitle".loaalized()
        public static let dubbing = "sortDubbing".loaalized()
        public static let subtitle = "sortSubtitle".loaalized()
        public static let ensubtitle = "sortEnsubtitle".loaalized()
        public static let endubbing = "sortEndubbing".loaalized()
        public static let cndubbing = "sortCndubbing".loaalized()
        public static let folansubtitle = "sortFolansubtitle".loaalized()
        public static let etc = "sortEtc".loaalized()
        public static let none = "sortNone".loaalized()
        public static let count = "sortCount".loaalized()
        public static let latest = "sortLatest".loaalized()
        public static let popularity = "sortPopularity".loaalized()
        public static let title = "sortTitle".loaalized()
        public static let price = "sortPrice".loaalized()
    }
    
    
    struct alert {
        public static var apns = "alertApns".loaalized()
        public static var api = "alertApi".loaalized()
        public static var apiErrorServer = "alertApiErrorServer".loaalized()
        public static var apiErrorClient = "alertApiErrorClient".loaalized()
        public static var networkError = "alertNetworkError".loaalized()
        public static var dataError = "alertDataError".loaalized()
        public static var connect = "alertConnect".loaalized()
        public static var connectWifi = "alertConnectWifi".loaalized()
        public static var connectWifiSub = "alertConnectWifiSub".loaalized()
    
        public static var needConnect = "alertNeedConnect".loaalized()
        public static var needConnectForView = "alertNeedConnectForView".loaalized()
        public static var needConnectStatus = "alertNeedConnectStatus".loaalized()
        public static var connectNotFound = "alertConnectNotFound".loaalized()
        public static var connectNotFoundSub = "alertConnectNotFoundSub".loaalized()
     
        
        public static var location = "alertLocation".loaalized()
        public static var locationSub = "alertLocationSub".loaalized()
        public static var locationBtn = "alertLocationBtn".loaalized()
        
        public static var findDevice = "alertFindDevice".loaalized()
        public static var findDeviceSub = "alertFindDeviceSub".loaalized()
        
        public static var limitedDevice = "alertLimitedDevice".loaalized()
        public static var limitedDeviceSub = "alertLimitedDeviceSub".loaalized()
        public static var limitedDeviceTip = "alertLimitedDeviceTip".loaalized()
        public static var limitedDeviceReference = "alertLimitedDeviceReference".loaalized()
        
        public static var authcodeInvalid = "alertAuthcodeInvalid".loaalized()
        public static var authcodeWrong = "alertAuthcodeWrong".loaalized()
        public static var authcodeTimeout = "alertAuthcodeTimeout".loaalized()
        public static var limitedConnect = "alertLimitedConnect".loaalized()
        public static var stbConnectFail = "alertStbConnectFail".loaalized()
        
        public static var pairingError = "alertPairingError".loaalized()
        public static var pairingCompleted = "alertPairingCompleted".loaalized()
        public static var pairingRecovery = "alertPairingRecovery".loaalized()
        public static var pairingDisconnected = "alertPairingDisconnected".loaalized()
        public static var serviceUnavailable = "alertServiceUnavailable".loaalized()
        public static var serviceUnavailableText = "alertServiceUnavailableText".loaalized()
        public static var serviceUnavailableText1 = "alertServiceUnavailableText1".loaalized()
        public static var serviceUnavailableText2 = "alertServiceUnavailableText2".loaalized()
        public static var identifySuccess = "alertIdentifySuccess".loaalized()
        public static var identifyFail = "alertIdentifyFail".loaalized()
        public static var identifySuccessAdult = "alertIdentifySuccessAdult".loaalized()
        public static var identifyFailAdult = "alertIdentifyFailAdult".loaalized()
        public static var identifySuccessMe = "alertIdentifySuccessMe".loaalized()
        public static var identifyFailMe = "alertIdentifyFailMe".loaalized()
        public static var like = "alertLike".loaalized()
        
        public static var bc = "alertBC".loaalized()
        public static var bcText = "alertBCtext".loaalized()
        public static var bs = "alertBS".loaalized()
        public static var bsText = "alertBStext".loaalized()
        
        public static var purchase = "alertPurchase".loaalized()
        public static var purchaseContinue = "alertPurchaseContinue".loaalized()
        
        public static var dataAlramOn = "alertDataAlramOn".loaalized()
        public static var dataAlramOff = "alertDataAlramOff".loaalized()
        public static var autoRemoconOn = "alertAutoRemoconOn".loaalized()
        public static var autoRemoconOff = "alertAutoRemoconOff".loaalized()
        public static var remoconVibrationOn = "alertRemoconVibrationOn".loaalized()
        public static var remoconVibrationOff = "alertRemoconVibrationOff".loaalized()
        public static var autoPlayOn = "alertAutoPlayOn".loaalized()
        public static var autoPlayOff = "alertAutoPlayOff".loaalized()
        public static var nextPlayOn = "alertNextPlayOn".loaalized()
        public static var nextPlayOff = "alertNextPlayOff".loaalized()
        
        public static var updateAlram = "alertUpdateAlram".loaalized()
        public static var updateAlramSetup = "alertUpdateAlramSetup".loaalized()
        public static var updateAlramRecommand = "alertUpdateAlramRecommand".loaalized()
        public static var updateRegistAlram = "alertUpdateRegistAlram".loaalized()
        public static var updateUnregistAlram = "alertUpdateUnregistAlram".loaalized()
        public static var dragdown = "alertDragdown".loaalized()
        public static var deleteWatch = "alertDeleteWatch".loaalized()
        public static var needMicPermission = "alertNeedMicPermission".loaalized()
        
        public static var adultCertification = "alertAdultCertification".loaalized()
        public static var adultCertificationFail = "alertAdultCertificationFail".loaalized()
        public static var adultCertificationNotAllowed = "alertAdultCertificationNotAllowed".loaalized()
        public static var needAdultCertification = "alertNeedAdultCertification".loaalized()
        
        public static var watchLv = "alertWatchLv".loaalized()
        public static var watchLvCompleted = "alertWatchLvCompleted".loaalized()
        public static var watchLvInput = "alertWatchLvInput".loaalized()
        public static var watchLvInfo = "alertWatchLvInfo".loaalized()
        public static var watchLvInfoError = "alertWatchLvError".loaalized()
        public static var watchLvCompletedInfo = "alertWatchLvCompletedInfo".loaalized()
    }
    
    struct button {
        public static var next = "btnNext".loaalized()
        public static var complete = "btnComplete".loaalized()
        public static var share = "btnShare".loaalized()
        public static var more = "btnMore".loaalized()
        public static var all = "btnAll".loaalized()
        public static var detail = "btnDetail".loaalized()
        public static var delete = "btnDelete".loaalized()
        public static let view = "btnView".loaalized()
        public static let connect = "btnConnect".loaalized()
        public static let disConnect = "btnDisConnect".loaalized()
        public static let heart = "btnHeart".loaalized()
        public static let like = "btnLike".loaalized()
        public static let likeOn = "btnLikeOn".loaalized()
        public static let likeOff = "btnLikeOff".loaalized()
        public static let watchBtv = "btnWatchBtv".loaalized()
        public static let connectBtv = "btnConnectBtv".loaalized()
        public static let alarm = "btnAlarm".loaalized()
        public static let notice = "btnNotice".loaalized()
        public static let purchas = "btnPurchas".loaalized()
        public static let purchasAnother = "btnPurchasAnother".loaalized()
        
        public static let ratioOrigin = "btnRatioOrigin".loaalized()
        public static let ratioFill = "btnRatioFill".loaalized()
        public static let ratioFit = "btnRatioFit".loaalized()
        
        public static let screenLock = "btnScreenLock".loaalized()
        public static let screenRatio = "btnScreenRatio".loaalized()
        public static let guide = "btnGuide".loaalized()
        public static let recieveAlram = "btnRecieveAlram".loaalized()
        public static let broadband = "btnBroadband".loaalized()
        
        public static let skip = "btnSkip".loaalized()
        public static let appInit = "btnAppInit".loaalized()
        public static let home = "btnHome".loaalized()
        public static let deleteAll = "btnDeleteAll".loaalized()
        public static let certification = "btnCertification".loaalized()
        public static let adultCertification = "btnAdultCertification".loaalized()
        
    }
    struct player {
        public static let moveSec = "playerMoveSec".loaalized()
        public static let preplay = "playerPreplay".loaalized()
        public static let preplaying = "playerPreplaying".loaalized()
        public static let continueView = "playerContinueView".loaalized()
        public static let preview = "playerPreview".loaalized()
        public static let cookie = "playerCookie".loaalized()
        public static let next = "playerNext".loaalized()
        public static let directPlay = "playerDirectPlay".loaalized()
        public static let season = "playerSeason".loaalized()
        public static let continuePlay = "playerContinuePlay".loaalized()
        public static let adTitlec = "playerAdTitle".loaalized()
        public static let adMore = "playerAdMore".loaalized()
        public static let adCancel = "playerAdCancel".loaalized()
    }
    
    struct monthly {
        public static let title = "monthlyTitle".loaalized()
        public static let more = "monthlyMore".loaalized()
        public static let textRecommand = "monthlyTextRecommand".loaalized()
        public static let textEnjoy = "monthlyTextEnjoy".loaalized()
    }
    
    struct footer {
        public static let text = "footerText".loaalized()
        public static let button = "footerButton".loaalized()
    }
    
    struct voice {
        public static let searchTitle = "voiceSearchTitle".loaalized()
        public static let searchText = "voiceSearchText".loaalized()
    }

  
    struct pageTitle {
        public static let connectBtv = "titleConnectBtv".loaalized()
        public static let connectWifi = "titleConnectWifi".loaalized()
        public static let connectCertificationBtv = "titleConnectCertificationBtv".loaalized()
        public static let connectCertificationUser = "titleConnectCertificationUser".loaalized()
        public static let my = "titleMy".loaalized()
        public static let pairingManagement =  "titlePairingManagement".loaalized()
        public static let myPurchase =  "titleMyPurchase".loaalized()
        public static let setup = "titleSetup".loaalized()
        public static let purchase = "titlePurchase".loaalized()
        public static let certificationUser = "titleCertificationUser".loaalized()
        public static let privacy = "titlePrivacy".loaalized()
        public static let serviceTerms = "titleServiceTerms".loaalized()
        public static let schedule = "titleSchedule".loaalized()
        public static let modifyProfile = "titleModifyProfile".loaalized()
        public static let watched = "titleWatched".loaalized()
        
    }
    
    struct pageText {
        public static let pairingText1 = "pairingText1".loaalized()
        public static let pairingText2_1 = "pairingText2_1".loaalized()
        public static let pairingText2_2 = "pairingText2_2".loaalized()
        public static let pairingText2_3 = "pairingText2_3".loaalized()
        public static let pairingText2_4 = "pairingText2_4".loaalized()
        public static let pairingTitle1 = "pairingTitle1".loaalized()
        public static let pairingTitle2 = "pairingTitle2".loaalized()
        public static let pairingBtnGuide = "pairingBtnGuide".loaalized()
        public static let pairingBtnWifi = "pairingBtnWifi".loaalized()
        public static let pairingBtnWifiSub = "pairingBtnWifiSub".loaalized()
        public static let pairingBtnBtvCertification = "pairingBtnBtvCertification".loaalized()
        public static let pairingBtnBtvCertificationSub = "pairingBtnBtvCertificationSub".loaalized()
        public static let pairingBtnUserCertification = "pairingBtnUserCertification".loaalized()
        public static let pairingBtnUserCertificationSub = "pairingBtnUserCertificationSub".loaalized()
        
        public static let pairingSetupUserText1 = "pairingSetupUserText1".loaalized()
        public static let pairingSetupUserText2 = "pairingSetupUserText2".loaalized()
        public static let pairingSetupCharacterSelect = "pairingSetupCharacterSelect".loaalized()
        public static let pairingSetupUserAgreementAll = "pairingSetupUserAgreementAll".loaalized()
        public static let pairingSetupUserAgreement1 = "pairingSetupUserAgreement1".loaalized()
        public static let pairingSetupUserAgreement2 = "pairingSetupUserAgreement2".loaalized()
        public static let pairingSetupUserAgreement3 = "pairingSetupUserAgreement3".loaalized()
        
        public static let pairingDeviceText1 = "pairingDeviceText1".loaalized()
        public static let pairingDeviceText2 = "pairingDeviceText2".loaalized()
        public static let pairingDeviceText3 = "pairingDeviceText3".loaalized()
        public static let pairingDeviceText4 = "pairingDeviceText4".loaalized()
        
        public static let pairingBtvText1 = "pairingBtvText1".loaalized()
        public static let pairingBtvText2 = "pairingBtvText2".loaalized()
        public static let pairingBtvText3 = "pairingBtvText3".loaalized()
        public static let pairingBtvText4 = "pairingBtvText4".loaalized()
        public static let pairingBtvText5 = "pairingBtvText5".loaalized()
        
      
        
        public static let setupApp = "setupApp".loaalized()
        public static let setupAppDataAlram = "setupAppDataAlram".loaalized()
        public static let setupAppDataAlramText = "setupAppDataAlramText".loaalized()
        public static let setupAppAutoRemocon = "setupAppAutoRemocon".loaalized()
        public static let setupAppAutoRemoconText = "setupAppAutoRemoconText".loaalized()
        public static let setupAppRemoconVibration = "setupAppRemoconVibration".loaalized()
        public static let setupAppRemoconVibrationText = "setupAppRemoconVibrationText".loaalized()

        public static let setupPlay = "setupPlay".loaalized()
        public static let setupPlayAuto = "setupPlayAuto".loaalized()
        public static let setupPlayAutoText = "setupPlayAutoText".loaalized()
        public static let setupPlayNext = "setupPlayNext".loaalized()
        public static let setupPlayNextText = "setupPlayNextText".loaalized()

        public static let setupAlram = "setupAlram".loaalized()
        public static let setupAlramMarketing = "setupAlramMarketing".loaalized()
        public static let setupAlramMarketingText = "setupAlramMarketingText".loaalized()
        public static let setupAlramMarketingTip1 = "setupAlramMarketingTip1".loaalized()
        public static let setupAlramMarketingTip2 = "setupAlramMarketingTip2".loaalized()
        public static let setupAlramMarketingTip3 = "setupAlramMarketingTip3".loaalized()
        public static let setupAlramMarketingTip4 = "setupAlramMarketingTip4".loaalized()
        public static let setupAlramMarketingTip5 = "setupAlramMarketingTip5".loaalized()

        public static let setupCertification = "setupCertification".loaalized()
        public static let setupCertificationPurchase = "setupCertificationPurchase".loaalized()
        public static let setupCertificationPurchaseText = "setupCertificationPurchaseText".loaalized()
        public static let setupCertificationAge = "setupCertificationAge".loaalized()
        public static let setupCertificationAgeText = "setupCertificationAgeText".loaalized()

        public static let setupChildren = "setupChildren".loaalized()
        public static let setupChildrenHabit = "setupChildrenHabit".loaalized()
        public static let setupChildrenHabitText = "setupChildrenHabitText".loaalized()

        public static let setupHappySenior = "setupHappySenior".loaalized()
        public static let setupHappySeniorPicture = "setupHappySeniorPicture".loaalized()
        public static let setupHappySeniorPictureText = "setupHappySeniorPictureText".loaalized()

        public static let setupGuideNVersion = "setupGuideNVersion".loaalized()
        public static let setupGuide = "setupGuide".loaalized()
        public static let setupVersionLatest = "setupVersionLatest".loaalized()
        public static let setupOpensource = "setupOpensource".loaalized()
        
        public static let myText1 = "myText1".loaalized()
        public static let myText2 = "myText2".loaalized()
        public static let myPairing =  "myPairing".loaalized()
        
        public static let myPairingInfo = "myPairingInfo".loaalized()
        public static let myConnectedBtv = "myConnectedBtv".loaalized()
        public static let myPairingDate = "myPairingDate".loaalized()
        public static let myEditNick = "myEditNick".loaalized()
        public static let myinviteFammly = "myinviteFammly".loaalized()
        public static let myinviteFammlyText1 = "myinviteFammlyText1".loaalized()
        public static let myinviteFammlyText2 = "myinviteFammlyText2".loaalized()
        
        public static let myWatchedInfo = "myWatchedInfo".loaalized()
        public static let myWatchedEmpty = "myWatchedEmpty".loaalized()
        public static let myCollectedEmpty = "myCollectedEmpty".loaalized()
        public static let myBookMarkedEmpty =  "myBookMarkedEmpty".loaalized()
        
        public static let synopsisOnlyBtvFree = "synopsisOnlyBtvFree".loaalized()
        public static let synopsisOnlyBtv = "synopsisOnlyBtv".loaalized()
        public static let synopsisWatchOnlyBtv = "synopsisWatchOnlyBtv".loaalized()
        public static let synopsisOnlyPurchasBtv = "synopsisOnlyPurchasBtv".loaalized()
        public static let synopsisTerminationBtv = "synopsisTerminationBtv".loaalized()
        public static let synopsisFreeWatch = "synopsisFreeWatch".loaalized()
        public static let synopsisFreeWatchBtv = "synopsisFreeWatchBtv".loaalized()
        public static let synopsisFreeWatchMonthly = "synopsisFreeWatchMonthly".loaalized()
        public static let synopsisWatchRent = "synopsisWatchRent".loaalized()
        public static let synopsisWatchPeriod = "synopsisWatchPeriod".loaalized()
        public static let synopsisWatchPossn = "synopsisWatchPossn".loaalized()
        public static let synopsisSummry = "synopsisSummry".loaalized()
        public static let synopsisSiris = "synopsisSiris".loaalized()
        public static let synopsisSirisView = "synopsisSirisView".loaalized()
        public static let synopsisDDay = "synopsisDDay".loaalized()
        public static let synopsisRelationVod = "synopsisRelationVod".loaalized()
        public static let synopsisNoRelationVod = "synopsisNoRelationVod".loaalized()
        public static let synopsisPackageContent = "synopsisPackageContent".loaalized()
        
        public static let authTitle = "authTitle".loaalized()
        public static let authText = "authText".loaalized()
        public static let authTextMic = "authTextMic".loaalized()
        public static let authTextLocation = "authTextLocation".loaalized()
        
        public static let searchLatest = "searchLatest".loaalized()
        public static let searchPopularity = "searchPopularity".loaalized()
        public static let searchResult = "searchResult".loaalized()
        public static let searchEmpty = "searchEmpty".loaalized()
        public static let searchEmptyGuide = "searchEmptyGuide".loaalized()
        public static let searchEmptyTitle = "searchEmptyTitle".loaalized()
        
        public static let modifyProfileText1 = "modifyProfileText1".loaalized()
        public static let modifyProfileText2 = "modifyProfileText2".loaalized()
        public static let modifyProfileText3 = "modifyProfileText3".loaalized()
        
        public static let adultCertificationText1 = "adultCertificationText1".loaalized()
        public static let adultCertificationText2 = "adultCertificationText2".loaalized()
        public static let adultCertificationText3 = "adultCertificationText3".loaalized()
    }
    
}
