//
//  strings.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

extension String {
    private static let isPad =  AppUtil.isPad()
    func loaalized() -> String {
        return NSLocalizedString(self, comment: "")
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
        
        
        public static let subtitleKor = "sortSubtitleKor".loaalized()
        public static let dubbingKor = "sortDubbingKor".loaalized()
        
        public static let etc = "sortEtc".loaalized()
        public static let none = "sortNone".loaalized()
        public static let count = "sortCount".loaalized()
        public static let latest = "sortLatest".loaalized()
        public static let countKids = "sortCountKids".loaalized()
        public static let latestKids = "sortLatestKids".loaalized()
        public static let popularity = "sortPopularity".loaalized()
        public static let title = "sortTitle".loaalized()
        public static let price = "sortPrice".loaalized()
        
        public static let english = "sortEnglish".loaalized()
        public static let englishTab = "sortEnglishTab".loaalized()
        public static let infantDevelopment = "sortInfantDevelopment".loaalized()
        public static let creativeObservation = "sortCreativeObservation".loaalized()

        public static let fairytale = "sortFairytale".loaalized()
        public static let creativity = "sortCreativity".loaalized()
        public static let elementarySchool = "sortElementarySchool".loaalized()
    }
    

    struct player {
        public static let moveSec = "playerMoveSec".loaalized()
        public static let preplay = "playerPreplay".loaalized()
        public static let preplaying = "playerPreplaying".loaalized()
        public static let continueView = "playerContinueView".loaalized()
        public static let preview = "playerPreview".loaalized()
        public static let cookie = "playerCookie".loaalized()
        public static let fullVod = "playerFullVod".loaalized()
        public static let next = "playerNext".loaalized()
        public static let nextClip = "playerNextClip".loaalized()
        public static let nextSeason = "playerNextSeason".loaalized()
        public static let directPlay = "playerDirectPlay".loaalized()
        public static let season = "playerSeason".loaalized()
        public static let continuePlay = "playerContinuePlay".loaalized()
        public static let adTitle = "playerAdTitle".loaalized()
        public static let adMore = "playerAdMore".loaalized()
        public static let adCancel = "playerAdCancel".loaalized()
        public static let replay = "playerReplay".loaalized()
        public static let disable =  "playerDisable".loaalized()
        public static let recordDisable =  "playerRecordDisable".loaalized()
        public static let recordDisableText =  "playerRecordDisableText".loaalized()
    }
    
    struct remote {
        public static let playEmpty = "remotePlayEmpty".loaalized()
        public static let playError = "remotePlayError".loaalized()
        public static let playNoInfo = "remotePlayNoInfo".loaalized()
        public static let inputChannel = "remoteInputChannel".loaalized()
        public static let inputText = "remoteInputText".loaalized()
        public static let inputChannelHolder = "remoteInputChannelHolder".loaalized()
        public static let inputTextHolder = "remoteInputTextHolder".loaalized()
        
        public static let networkDisconnect = "remoteNetworkDisconnect".loaalized()
        public static let networkUnstable = "remoteNetworkUnstable".loaalized()
        
        public static let inputSearch = "remoteInputSearch".loaalized()
        public static let inputSearchHolder = "remoteInputSearchHolder".loaalized()
        public static let inputSearchTip = "remoteInputSearchTip".loaalized()
        
        public static let titleMusicBroadcast = "remoteTitleMusicBroadcast".loaalized()
        public static let titleMirroring = "remoteTitleMirroring".loaalized()
        public static let searchLock = "remoteSearchLock".loaalized()
        public static let setupMirroring = "remoteSetupMirroring".loaalized()
        public static let closeMirroring = "remoteCloseMirroring".loaalized()
        public static let searchMirroring = "remoteSearchMirroring".loaalized()
        public static let errorMirroringWifi = "remoteErrorMirroringWifi".loaalized()
        public static let errorMirroringWifiText = "remoteErrorMirroringWifiText".loaalized()
        public static let errorMirroring = "remoteErrorMirroring".loaalized()
        public static let errorMirroringText = "remoteErrorMirroringText".loaalized()
        public static let errorMirroringTextSub = "remoteErrorMirroringTextSub".loaalized()
    }
    
    struct monthly {
        public static let title = "monthlyTitle".loaalized()
        public static let more = "monthlyMore".loaalized()
        public static let textRecommand = "monthlyTextRecommand".loaalized()
        public static let textEnjoy = "monthlyTextEnjoy".loaalized()
        public static let textEnjoyPeriod = "monthlyTextEnjoyPeriod".loaalized()
        public static let textKidsLeading = "monthlyTextKidsLeading".loaalized()
        public static let textKidsTrailing = "monthlyTextKidsTrailing".loaalized()
        
        public static let textRecommandOmnipack = "monthlyTextRecommandOmnipack".loaalized()
        public static let textEnjoyOmnipack = "monthlyTextEnjoyOmnipack".loaalized()

        public static let textFirstFreeStrong = "monthlyTextFirstFreeStrong".loaalized()
        public static let textFirstFreeTrailing = "monthlyTextFirstFreeTrailing".loaalized()
        
        public static let oceanPurchaseLeading = "monthlyOceanPurchaseLeading".loaalized()
        public static let oceanPurchaseTrailing = "monthlyOceanPurchaseTrailing".loaalized()
        public static let oceanAuthLeading = "monthlyOceanAuthLeading".loaalized()
        public static let oceanAuth = "monthlyOceanAuth".loaalized()
        public static let oceanPeriodAuth = "monthlyOceanPeriodAuth".loaalized()
        
        public static let oceanFirstFreeLeading = "monthlyOceanFirstFreeLeading".loaalized()
        public static let oceanFirstFreeTrailing = "monthlyOceanFirstFreeTrailing".loaalized()
        
        public static let dDay = "monthlyDDay".loaalized()
        public static let expiry = "monthlyExpiry".loaalized()
        public static let kids = "monthlyKids".loaalized() 
    }
    struct quickMenu {
        public static let menu1 = "quickMenu1".loaalized()
        public static let menu2 = "quickMenu2".loaalized()
        public static let menu3 = "quickMenu3".loaalized()
        public static let menu4 = "quickMenu4".loaalized()
        public static let menu5 = "quickMenu5".loaalized()
    }
    
    struct footer {
        public static let title1 = "footerTitle1".loaalized()
        public static let text1 = "footerText1".loaalized()
        public static let title2 = "footerTitle2".loaalized()
        public static let text2 = "footerText2".loaalized()
        public static let title3 = "footerTitle3".loaalized()
        public static let text3 = "footerText3".loaalized()
        public static let title4 = "footerTitle4".loaalized()
        public static let text4 = "footerText4".loaalized()
        public static let title5 = "footerTitle5".loaalized()
        public static let text5 = "footerText6".loaalized()
        public static let title6 = "footerTitle6".loaalized()
        public static let text6 = "footerText6".loaalized()
        public static let title7 = "footerTitle7".loaalized()
        public static let text7 = "footerText7".loaalized()
        public static let title8 = "footerTitle8".loaalized()
        public static let text8 = "footerText8".loaalized()
       
        public static let button = "footerButton".loaalized()
    }
    
    struct voice {
        public static let searchTitle = "voiceSearchTitle".loaalized()
        public static let searchText = "voiceSearchText".loaalized()
        public static let searchTextKids = "voiceSearchTextKids".loaalized()
        public static let searchingTextKids = "voiceSearchingKids".loaalized()
    }

    struct share {
        public static let eventTitle = "shareEventTitle".loaalized()
        public static let inviteMsg =  "shareInviteMsg".loaalized()
        public static let synopsis = "shareSynopsis".loaalized()
        public static let complete = "shareComplete".loaalized()
        public static let fail = "shareFail".loaalized()
        public static let shareFamilyInvite = "shareFamilyInvite".loaalized()
        public static let shareFamilyInviteComplete = "shareFamilyInviteComplete".loaalized()
        public static let shareFamilyInviteFail = "shareFamilyInviteFail".loaalized()
        
        public static let synopsisRecommand = "shareSynopsisRecommand".loaalized()
        public static let synopsisRecommandBenefitText1 = "shareSynopsisRecommandBenefitText1".loaalized()
        public static let synopsisRecommandBenefitText2 = "shareSynopsisRecommandBenefitText2".loaalized()
        public static let synopsisRecommandBenefitText3 = "shareSynopsisRecommandBenefitText3" .loaalized()

        public static let synopsisRecommandBenefitFriend = "shareSynopsisRecommandBenefitFriend".loaalized()
        public static let synopsisRecommandBenefitMe = "shareSynopsisRecommandBenefitMe".loaalized()
        public static let synopsisRecommandVodLeading = "shareSynopsisRecommandVodLeading".loaalized()
        public static let synopsisRecommandPurchaseLeading = "shareSynopsisRecommandPurchaseLeading".loaalized()
        public static let synopsisRecommandVodTrailing = "shareSynopsisRecommandVodTrailing".loaalized()
        public static let synopsisRecommandPurchaseTrailing = "shareSynopsisRecommandPurchaseTrailing".loaalized()
        public static let synopsisRecommandVodTip = "shareSynopsisRecommandVodTip".loaalized()
        public static let synopsisRecommandPurchaseTip = "shareSynopsisRecommandPurchaseTip".loaalized()
        public static let synopsisRecommandTip = "shareSynopsisRecommandTip".loaalized()
        public static let synopsisRecommandButton = "shareSynopsisRecommandButton".loaalized()
        
        public static let synopsisRecommandReceiveTitleLeading = "shareSynopsisRecommandReceiveTitleLeading".loaalized()
        public static let synopsisRecommandReceiveTitleTrailing = "shareSynopsisRecommandReceiveTitleTrailing".loaalized()
        public static let synopsisRecommandReceiveText = "shareSynopsisRecommandReceiveText".loaalized()
        public static let synopsisRecommandReceiveTip = "shareSynopsisRecommandReceiveTip".loaalized()
        public static let synopsisRecommandReceiveButton = "shareSynopsisRecommandReceiveButton".loaalized()
        public static let synopsisRecommandReceiveNeedPairing = "shareSynopsisRecommandReceiveNeedPairing".loaalized()
        public static let synopsisRecommandReceiveCompleted = "shareSynopsisRecommandReceiveCompleted".loaalized()
        public static let synopsisRecommandReceiveCompletedTip = "shareSynopsisRecommandReceiveCompletedTip".loaalized()
        
        public static let synopsisRecommandReceiveError = "shareSynopsisRecommandReceiveError".loaalized()
        public static let synopsisRecommandReceiveErrorExpired = "shareSynopsisRecommandReceiveErrorExpired".loaalized()
        public static let synopsisRecommandReceiveErrorExpiredTip = "shareSynopsisRecommandReceiveErrorExpiredTip".loaalized()
        public static let synopsisRecommandReceiveErrorEqualSTB = "shareSynopsisRecommandReceiveErrorEqualSTB".loaalized()
        public static let synopsisRecommandReceiveErrorHasCoupon = "shareSynopsisRecommandReceiveErrorHasCoupon".loaalized()
        public static let synopsisRecommandReceiveErrorHasCouponTip = "shareSynopsisRecommandReceiveErrorHasCouponTip".loaalized()
        public static let synopsisRecommandReceiveErrorPurchased = "shareSynopsisRecommandReceiveErrorPurchased".loaalized()
        public static let synopsisRecommandReceiveErrorPurchasedTip = "shareSynopsisRecommandReceiveErrorPurchasedTip".loaalized()
        public static let synopsisRecommandReceiveErrorFail = "shareSynopsisRecommandReceiveErrorFail".loaalized()
    }
    
    struct pairingHitch {
  
        public static let auto =  "pairingHitchAuto".loaalized()
        public static let autoSelect =  "pairingHitchAutoSelect".loaalized()
        public static let select =  "pairingHitchSelect".loaalized()
        public static let selectAppleTip = "pairingHitchSelectAppleTip".loaalized()
        public static let fullTop = "pairingHitchFullTop".loaalized()
        public static let fullLeading =  "pairingHitchFullLeading".loaalized()
        public static let fullCenter =  "pairingHitchFullCenter".loaalized()
        public static let fullTrailing =  "pairingHitchFullTrailing".loaalized()
        public static let full =  "pairingHitchFull".loaalized()

        public static let userAgreement1 =  isPad
            ? "pairingHitchUserAgreement1Tablet".loaalized()
            : "pairingHitchUserAgreement1".loaalized()
        public static let userAgreement2 =  isPad
            ? "pairingHitchUserAgreement2Tablet".loaalized()
            : "pairingHitchUserAgreement2".loaalized()
        public static let userAgreement3 =  isPad
            ? "pairingHitchUserAgreement3Tablet".loaalized()
            : "pairingHitchUserAgreement3".loaalized()
        
        public static let stbName = "pairingHitchStbName".loaalized()
        
       
        public static let typeLeading = "pairingHitchTypeLeading".loaalized()
        public static let typeLeading2 = "pairingHitchTypeLeading2".loaalized()
        public static let wifi = "pairingHitchWifi".loaalized()
        public static let btv = "pairingHitchBtv".loaalized()
        public static let user = "pairingHitchUser".loaalized()
    }
    
    struct vs {
        public static let account = "vsAccount".loaalized()
        public static let accountExpirationDate = "vsAccountExpirationDate".loaalized()
        public static let accountAutoPairing = "vsAccountAutoPairing".loaalized()
        public static let accountUnPairing = "vsAccountUnPairing".loaalized()
        public static let accountAutoPairingError = "vsAccountAutoPairingError".loaalized()
        public static let accountAutoPairingFail = "vsAccountAutoPairingFail".loaalized()
        public static let accountSynchronizationDenied = "vsAccountSynchronizationDenied".loaalized()
        public static let accountSynchronizationFail = "vsAccountSynchronizationFail".loaalized()
        public static let accountSynchronizationFailDifferentStb = "vsAccountSynchronizationFailDifferentStb".loaalized()
        public static let accountSynchronizationFailExistPairing = "vsAccountSynchronizationFailExistPairing".loaalized()
        public static let accounttUnpairing = "vsAccountUnpairing".loaalized()
        public static let accountAutoPairingConfirm = "vsAccountAutoPairingConfirm".loaalized()
        public static let accountForbiddenUnpairing = "vsAccountForbiddenUnpairing".loaalized()
        public static let accountProviderPairing = "vsAccountProviderPairing".loaalized()
        public static let accountProviderPairingTip = "vsAccountProviderPairingTip".loaalized()
        public static let accountProviderPairingInfo = "vsAccountProviderPairingInfo".loaalized()
        public static let pairingMaintain = "vsPairingMaintain".loaalized()
        public static let pairingDisconnect = "vsPairingDisconnect".loaalized()
        public static let pairingRequestTvProvider = "vsPairingRequestTvProvider".loaalized()
        public static let accountTip = "vsAccountTip".loaalized()
        public static let accountTipError = "vsAccountTipError".loaalized()
        public static let accountTipRetry = "vsAccountTipRetry".loaalized()
        public static let accountTipDenied = "vsAccountTipDenied".loaalized()
    }
    
    struct oksusu {
        public static let setup = "myOksusuSetup".loaalized()
        public static let setupCertification = "myOksusuSetupCertification".loaalized()
        public static let setupCertificationSub = "myOksusuSetupCertificationSub".loaalized()
        public static let certification = "myOksusuCertification".loaalized()
        public static let setupAlreadyUsed = "myOksusuSetupAlreadyUsed".loaalized()
        public static let setupAlreadyUsedSub = "myOksusuSetupAlreadyUsedSub".loaalized()
        public static let setupCompleted = "myOksusuSetupCompleted".loaalized()
        public static let setupDiable = "myOksusuSetupDiable".loaalized()
        public static let setupDiableText = "myOksusuSetupDiableText".loaalized()
        public static let setupDiableSub = "myOksusuSetupDiableSub".loaalized()
        public static let setupDiableTip = "myOksusuSetupDiableTip".loaalized()
        public static let disconnect = "myOksusuDisconnect".loaalized()
        public static let disconnectText = "myOksusuDisconnectText".loaalized()
        public static let disconnectButPurchase = "myOksusuDisconnectButPurchase".loaalized()
        public static let disconnectAnotherUser = "myOksusuDisconnectAnotherUser".loaalized()
        public static let disconnectCompleted = "myOksusuDisconnectCompleted".loaalized()
        public static let connect = "myOksusuConnect".loaalized()
        public static let connectText = "myOksusuConnectText".loaalized()
        public static let connectSub = "myOksusuConnectSub".loaalized()
        public static let connectUser = "myOksusuConnectUser".loaalized()
        public static let connectIdNum = "myOksusuConnectIdNum".loaalized()
        public static let connectJoinDate = "myOksusuConnectJoinDate".loaalized()
        public static let connectJoinTid = "myOksusuConnectJoinTid".loaalized()
        public static let connectJoinFb = "myOksusuConnectJoinFb".loaalized()
        public static let setupPurchaseDiable = "myOksusuSetupPurchaseDiable".loaalized()
        public static let setupPurchaseDeleteDiable = "myOksusuSetupPurchaseDeleteDiable".loaalized()
        public static let setupPurchaseCompleted = "myOksusuSetupPurchaseCompleted".loaalized()
        public static let setupButtonConnect = "myOksusuSetupButtonConnect".loaalized()
        public static let setupButtonDisConnect = "myOksusuSetupButtonDisConnect".loaalized()
    }
}
