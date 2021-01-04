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
    }
    
    struct alert {
        public static var apns = "apns".loaalized()
        public static var api = "api".loaalized()
        public static var apiErrorServer = "apiErrorServer".loaalized()
        public static var apiErrorClient = "apiErrorClient".loaalized()
        public static var connectError = "connectError".loaalized()
    }
    
    struct button {
        public static var next = "next".loaalized()
        public static var complete = "complete".loaalized()
        public static var share = "share".loaalized()
        public static var more = "more".loaalized()
        public static var delete = "delete".loaalized()
        public static let view = "view".loaalized()
        public static let connect = "connect".loaalized()
    }
    
    struct pageTitle {
        public static let connectBtv = "connectBtv".loaalized()
        public static let connectWifi = "connectWifi".loaalized()
        public static let connectCertificationBtv = "connectCertificationBtv".loaalized()
        public static let connectCertificationUser = "connectCertificationUser".loaalized()
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
        
        public static let pairingBtvText1 = "pairingBtvText1".loaalized()
        public static let pairingBtvText2 = "pairingBtvText2".loaalized()
        public static let pairingBtvText3 = "pairingBtvText3".loaalized()
        public static let pairingBtvText4 = "pairingBtvText4".loaalized()
        public static let pairingBtvText5 = "pairingBtvText5".loaalized()
    }
    
}
