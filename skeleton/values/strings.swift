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
        public static let year = "year".loaalized()
        public static let min = "min".loaalized()
        
        public static let certificationNumber = "certificationNumber".loaalized()
        public static let certificationNumberHolder = "certificationNumberHolder".loaalized()
        public static let macAdress = "macAdress".loaalized()
        
        public static let rent = "rent".loaalized()
        public static let owner = "owner".loaalized()
        public static let defaultStb = "defaultStb".loaalized()
        public static let another = "another".loaalized()
        public static let count = "count".loaalized()
        public static let award = "award".loaalized()
    }
    
    struct alert {
        public static var apns = "alertApns".loaalized()
        public static var api = "alertApi".loaalized()
        public static var apiErrorServer = "alertApiErrorServer".loaalized()
        public static var apiErrorClient = "alertApiErrorClient".loaalized()

        public static var connect = "alertConnect".loaalized()
        public static var connectWifi = "alertConnectWifi".loaalized()
        public static var connectWifiSub = "alertConnectWifiSub".loaalized()
    
        public static var needConnect = "alertNeedConnect".loaalized()
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
        public static var like = "alertLike ".loaalized()
        
    }
    
    struct button {
        public static var next = "btnNext".loaalized()
        public static var complete = "btnComplete".loaalized()
        public static var share = "btnShare".loaalized()
        public static var more = "btnMore".loaalized()
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
    }
    
    struct pageTitle {
        public static let connectBtv = "titleConnectBtv".loaalized()
        public static let connectWifi = "titleConnectWifi".loaalized()
        public static let connectCertificationBtv = "titleConnectCertificationBtv".loaalized()
        public static let connectCertificationUser = "titleConnectCertificationUser".loaalized()
        public static let my = "titleMy".loaalized()
        public static let pairingManagement =  "titlePairingManagement".loaalized()
        public static let myPurchase =  "titleMyPurchase".loaalized()
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
        
    }
    
}
