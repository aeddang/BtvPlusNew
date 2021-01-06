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
        
        public static let certificationNumber = "certificationNumber".loaalized()
        public static let certificationNumberHolder = "certificationNumberHolder".loaalized()
        public static let macAdress = "macAdress".loaalized()
    }
    
    struct alert {
        public static var apns = "alertApns".loaalized()
        public static var api = "alertApi".loaalized()
        public static var apiErrorServer = "alertApiErrorServer".loaalized()
        public static var apiErrorClient = "alertApiErrorClient".loaalized()
        
        
        public static var connect = "alertConnect".loaalized()
        public static var connectWifi = "alertConnectWifi".loaalized()
        public static var connectWifiSub = "alertConnectWifiSub".loaalized()
        public static var connectError = "alertConnectError".loaalized()
        public static var connectNotFound = "alertConnectNotFound".loaalized()
        public static var connectNotFoundSub = "alertConnectNotFoundSub".loaalized()
    }
    
    struct button {
        public static var next = "btnNext".loaalized()
        public static var complete = "btnComplete".loaalized()
        public static var share = "btnShare".loaalized()
        public static var more = "btnMore".loaalized()
        public static var delete = "btnDelete".loaalized()
        public static let view = "btnView".loaalized()
        public static let connect = "btnConnect".loaalized()
    }
    
    struct pageTitle {
        public static let connectBtv = "titleConnectBtv".loaalized()
        public static let connectWifi = "titleConnectWifi".loaalized()
        public static let connectCertificationBtv = "titleConnectCertificationBtv".loaalized()
        public static let connectCertificationUser = "titleConnectCertificationUser".loaalized()
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
        
        
    }
    
}
