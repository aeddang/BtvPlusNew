//
//  string.alert.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/01.
//

import Foundation

extension String {
    
    struct alert {
        public static var apns = "alertApns".loaalized()
        public static var apnsNotice = "alertApnsNotice".loaalized()
        public static var apnsEventWeb =  "alertApnsEventWeb".loaalized()
        public static var apnsVodDetail = "alertApnsVodDetail".loaalized()
        public static var apnsWebInApp = "alertApnsWebInApp".loaalized()
        public static var apnsBrowser = "alertApnsBrowser".loaalized()
        public static var apnsHome = "alertApnsHome".loaalized()
        public static var apnsTrailer = "alertApnsTrailer".loaalized()
        public static var apnsMenu = "alertApnsMenu".loaalized()
        public static var apnsSynop = "alertApnsSynop".loaalized()
        public static var apnsSeason = "alertApnsSeason".loaalized()
        public static var apnsMonthly = "alertApnsMonthly".loaalized()
        public static var apnsReserve = "alertApnsReserve".loaalized()
        
        
        public static var api = "alertApi".loaalized()
        public static var apiErrorServer = "alertApiErrorServer".loaalized()
        public static var apiErrorClient = "alertApiErrorClient".loaalized()
        public static var networkError = "alertNetworkError".loaalized()
        public static var dataError = "alertDataError".loaalized()
        public static var connect = "alertConnect".loaalized()
        public static var connectWifi = "alertConnectWifi".loaalized()
        public static var connectWifiSub = "alertConnectWifiSub".loaalized()
        
        
        public static var guide = "alertGuide".loaalized()
        public static var guideNotSupported = "alertGuideNotSupported".loaalized()
        public static var guideNotSupportedVibrate = "alertGuideNotSupportedVibrate".loaalized()
    
        public static var needConnect = "alertNeedConnect".loaalized()
        public static var needConnectForView = "alertNeedConnectForView".loaalized()
        public static var needConnectStatus = "alertNeedConnectStatus".loaalized()
        public static var checkConnectStatus = "alertCheckConnectStatus".loaalized()
        public static var connectNotFound = "alertConnectNotFound".loaalized()
        public static var connectNotFoundSub = "alertConnectNotFoundSub".loaalized()
     
        public static var pushOn =  "alertPushOn".loaalized()
        public static var pushOff =  "alertPushOff".loaalized()
        public static var pushError =  "alertPushError".loaalized()
        
        public static var location = "alertLocation".loaalized()
        public static var locationSub = "alertLocationSub".loaalized()
        public static var locationBtn = "alertLocationBtn".loaalized()
        
        public static var findDevice = "alertFindDevice".loaalized()
        public static var findDeviceSub = "alertFindDeviceSub".loaalized()
        
        public static var unpairing = "alertUnpairing".loaalized()
        public static var forceUnpairing = "alertForceUnpairing".loaalized()
        public static var forceUnpairingInfo = "alertForceUnpairingInfo".loaalized()

        public static var upgradePairing = "alertUpgradePairing".loaalized()
        public static var upgradePairingSub = "alertUpgradePairingSub".loaalized()
        
        public static var limitedDevice = "alertLimitedDevice".loaalized()
        public static var limitedDeviceSub = "alertLimitedDeviceSub".loaalized()
        public static var limitedDeviceTip = "alertLimitedDeviceTip".loaalized()
        public static var limitedDeviceReference = "alertLimitedDeviceReference".loaalized()
        
        public static var userCertification = "alertUserCertification".loaalized()
        public static var userCertificationPairing = "alertUserCertificationPairing".loaalized()
        public static var userCertificationNeedPairing = "alertUserCertificationNeedPairing".loaalized()
        public static var authcodeInvalid = "alertAuthcodeInvalid".loaalized()
        public static var authcodeWrong = "alertAuthcodeWrong".loaalized()
        public static var authcodeTimeout = "alertAuthcodeTimeout".loaalized()
        public static var limitedConnect = "alertLimitedConnect".loaalized()
        public static var stbConnectFail = "alertStbConnectFail".loaalized()
        
        public static var pairingError = "alertPairingError".loaalized()
        public static var pairingCompleted = "alertPairingCompleted".loaalized()
        public static var pairingRecovery = "alertPairingRecovery".loaalized()
        public static var pairingDisconnected = "alertPairingDisconnected".loaalized()
        public static var notPairing = "alertNotPairing".loaalized()
        public static var notPairingText = "alertNotPairingText".loaalized()
        
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
        public static var purchaseContinueBtv = "alertPurchaseContinueBtv".loaalized()
        
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
        
        
        
        public static var incorrectNumberOfCharacter = "alertIncorrectNumberOfCharacter".loaalized()
        public static var incorrecPassword = "alertIncorrecPassword".loaalized()
        public static var passwordInitateInfo = "alertPasswordInitateInfo".loaalized()
        
        public static var watchLv = "alertWatchLv".loaalized()
        public static var watchLvInput = "alertWatchLvInput".loaalized()
       
        public static var watchLvCompleted = "alertWatchLvCompleted".loaalized()
        public static var watchLvCompletedInfo = "alertWatchLvCompletedInfo".loaalized()
        
        public static var purchaseAuth = "alertPurchaseAuth".loaalized()
        public static var purchaseAuthInput = "alertPurchaseAuthInput".loaalized()
        public static var purchaseAuthInfo = "alertPurchaseAuthInfo".loaalized()
        
        public static var okCashDiscount = "alertOkCashDiscount".loaalized()
        public static var okCashDiscountInput =  "alertOkCashDiscountInput".loaalized()

        public static var purchaseAuthCompleted = "alertPurchaseAuthCompleted".loaalized()
        public static var purchaseAuthCompleteInfo = "alertPurchaseAuthCompleteInfo".loaalized()
        public static var purchaseHidden = "alertPurchaseHidden".loaalized()
        public static var purchaseHiddenText = "alertPurchaseHiddenText".loaalized()
        public static var purchaseHiddenInfo = "alertPurchaseHiddenInfo".loaalized()
        public static var purchaseHiddenLimit = "alertPurchaseHiddenLimit".loaalized()
        public static var purchaseHiddenLimitText = "alertPurchaseHiddenLimitText".loaalized()
        
        public static var newAlram = "alertNewAlram".loaalized()
        public static var newAlramAllRead = "alertNewAlramAllRead".loaalized()

        public static var possession = "alertPossession".loaalized()
        public static var possessionText = "alertPossessionText".loaalized()
        public static var possessionInfo = "alertPossessionInfo".loaalized()
        public static var possessionDelete = "alertPossessionDelete".loaalized()
        public static var possessionComplete = "alertPossessionComplete".loaalized()
        public static var possessionStbNone = "alertPossessionStbNone".loaalized()
        public static var possessionVodNone = "alertPossessionVodNone".loaalized()
        public static var possessionDiableAlready = "alertPossessionDiableAlready".loaalized()
        public static var possessionDiableAlreadyChange = "alertPossessionDiableAlreadyChange".loaalized()
        public static var possessionDeleteConfirm = "alertPossessionDeleteConfirm".loaalized()
        
    }
}