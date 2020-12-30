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
    public static let appName = "appName".loaalized()
    public static let corfirm = "corfirm".loaalized()
    public static let cancel = "cancel".loaalized()
    public static let retry = "retry".loaalized()
    
    struct alert {
        public static var apns = "apns".loaalized()
        public static var api = "api".loaalized()
        public static var apiErrorServer = "apiErrorServer".loaalized()
        public static var apiErrorClient = "apiErrorClient".loaalized()
    }
    
    struct button {
        public static var next = "next".loaalized()
        public static var complete = "complete".loaalized()
        public static var share = "share".loaalized()
        public static var more = "more".loaalized()
        public static var delete = "delete".loaalized()
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
    }
    
}
