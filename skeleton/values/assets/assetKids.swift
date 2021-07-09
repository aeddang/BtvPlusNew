//
//  asset.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/15.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
struct AssetKids {}
extension AssetKids {
    public static let noImg16_9 = "zemkidsMThumnailDefault"
    public static let noImg9_16 = "zemkidsMPosterDefault2"
}
extension AssetKids{
    private static let isPad =  AppUtil.isPad()
    struct brand {
       
    }
    
    struct gnbTop {
        public static let monthly = "zemkidsMGnbTopNorMonthly"
        public static let exit = "zemkidsMGnbTopNorOut"
        public static let search = "zemkidsMGnbTopNorSearch"
        public static let addProfile = "zemkidsMGnbNorSetprofile"
        
        public static let homeOff = "zemkidsMGnbNorHome"
        public static let homeOn = "zemkidsMGnbSelHome"
        public static let bgOn = "zemkidsMGnbSelBg"
    }
    
   
    
    struct icon {
        public static let delete = "zemkidsMPopupInputDelNor"
        public static let back = "zemkidsMBackBtn"
        public static let close = "zemkidsMQuizBtnClose"
        public static let backTop = "zemkidsMTopBackBtn"
        public static let setting = "zemkidsMTopSetBtn"
        public static let more = "zemkidsMBtnMore"
        public static let heartOff = "zemkidsMBtnSynopsisFavoriteOff"
        public static let heartOn = "zemkidsMBtnSynopsisFavoriteOn"
        public static let info = "zemkidsMBtnSynopsisTololtipInfoNor"
        public static let warn = "zemkidsMIcSysnopsisWarn"
        public static let tip = "zemkidsMIcSysnopsisTip"
        public static let watchBTv = "zemkidsMBtnSynopsisBtvNor"
        public static let playInfo = "zemkidsMBtnSynopsisInfoNor"
        public static let share = "zemkidsMBtnSynopsisShareNor"
        public static let sort = "zemkidsMDropdownBriDownNor"
        public static let thumbPlay = "zemkidsMIcPlay"
        
        public static let editProfileOff = "zemkidsMBtnEditNor"
        public static let editProfileOn = "zemkidsMBtnEditSel"
        
        public static let crownOff = "zemkidsMFlagTypicalNor"
        public static let crownOn = "zemkidsMFlagTypicalSel"
        
        public static let addReport = "zemkidsMBtnKidsprofilePlusNor"
        public static let addProfile = "zemkidsMIcKidsprofilePlusNor"
        public static let profileDelete = "zemkidsMBtnProfileDeleteNor"
        
        public static let trophy = "zemkidsMImgReportLevelS"
        public static let medal = "zemkidsMIcBtnRecommend"
        
        
    }
    
    
    struct player {
        public static let back = "zemkidsMBackBtnW"
        public static let close = "zemkidsMPlayerBtnCloseHarf"
        public static let more = "zemkidsMPlayerBtnOptionHarf"
        public static let lock = "zemkidsMPlayerBtnLock1Harf"
        public static let lockOn = "zemkidsMPlayerBtnLock2Harf"
        public static let lockText = "zemkidsMLockBubbleHalf"
        public static let resume = "zemkidsMPlayerPlayBtnHarf"
        public static let pause = "zemkidsMPlayerPauseBtnHarf"
        public static let replay = "zemkidsMPlayerBtnRepeat1Harf"
        
        public static let fullScreen = "zemkidsMPlayerBtnChangeHarf"
        public static let fullScreenOff = "zemkidsMPlayerBtnChange"
        public static let volumeOn = "zemkidsMPlayerBtnSound1Harf"
        public static let volumeOff = "zemkidsMPlayerBtnSound2Harf"
        public static let seekForward = "zemkidsMPlayerIc10SRightHalf"
        public static let seekBackward = "zemkidsMPlayerIc10SLeftHalf"
       
        public static let noImg = "zemkidsMPlayerDefaultImgHarf"
        public static let listBg = "zemkidsMPlayerThumbnailFrameNor"
        public static let listBgOn = "zemkidsMPlayerThumbnailFrameSel"
       
      
    }
    
    struct exam {
        public static let answerBg = isPad ? "zemkidsTIAnswerBg" : "zemkidsMAnswerBg"
        public static let listenBg = isPad ? "zemkidsTIAnswerListenBg" : "zemkidsMAnswerListenBg"
        
        public static let sound = "zemkidsMTestBtnSound"
        public static let check = "zemkidsTIIcCheck"
        
        public static let answer =  isPad
            ? [ "zemkidsTIBtnAnswer1", "zemkidsTIBtnAnswer2", "zemkidsTIBtnAnswer3" ]
            : [ "zemkidsMBtnAnswer1", "zemkidsMBtnAnswer2", "zemkidsMBtnAnswer3" ]
      
        public static let answerRight = isPad ? "zemkidsTIBtnAnswerRight" : "zemkidsMBtnAnswerRight"
        public static let answerWrong = isPad ? "zemkidsTIBtnAnswerWrong" : "zemkidsMBtnAnswerWrong"
        
        public static let next = "zemkidsMLevelTestBtnR"
        public static let prev = "zemkidsMLevelTestBtnL"
        public static let exit = "zemkidsMLevelTestBtnROut"
        
        public static let timerNext = [
            "zemkidsMLevelTestBtnNext3", "zemkidsMLevelTestBtnNext2", "zemkidsMLevelTestBtnNext1"
        ]
        
        public static let timerExit = [
            "zemkidsMLevelTestBtnROut3", "zemkidsMLevelTestBtnROut2", "zemkidsMLevelTestBtnROut1"
        ]
         
        public static let timerResult = [
            "zemkidsMLevelTestBtnRResults3", "zemkidsMLevelTestBtnRResults2", "zemkidsMLevelTestBtnRResults1"
        ]
       
        public static let graphic1 = "zemkidsMBgLevelTestGraphic01"
        public static let graphic2 = "zemkidsMBgLevelTestGraphic02"
        
        public static let completeBg1 = "zemkidsMTestEnd1Eng"
        public static let completeBg2 = "zemkidsMTestEnd2Kidsdev"
        public static let completeBg3 = "zemkidsMTestEnd3Creative"
        public static let completeBg4 = "zemkidsMTestEnd4Quiz"
        
        public static let startBg1 = "zemkidsMTestStart1Eng"
        public static let startBg2 = "zemkidsMTestStart2Kidsdev"
        public static let startBg3 = "zemkidsMTestStart3Creative"
        public static let startBg4 = "zemkidsMTestStart4Quiz"
    }
    
    
    struct shape {
        public static let radioBtnOn = "zemkidsMRadioButtonPre"
        public static let radioBtnOff = "zemkidsMRadioButtonNor"
        public static let checkBoxOn = "zemkidsMProfileImgSel"
        public static let checkBoxOn2 = "zemkidsMPopupCheckSel"
        public static let checkBoxOff = "zemkidsMProfileImgNor"
        
        public static let checkOption = "zemkidsMToggleOptionIcSel"
        
        public static let profileBgOff = "zemkidsMMyProfileCardNor"
        public static let profileBgOn = "zemkidsMMyProfileCardSel"
        public static let profileBg = isPad ? "zemkidsTIMyProfileCard" : "zemkidsMMyProfileCard"
        
        public static let tooltip = isPad ? "zemkidsTTooltipBubble29" : "zemkidsMTooltipBubble29"
        public static let spinner = "icSpinner"
        
        public static let graphAverage = "zemkidsMImgGraphBallonGreen"
        public static let graphThumbBg = "zemkidsMImgGraphMeRed"
        
        public static let graphGuideNum = "zemkidsMImgGraphRecomNum"
        public static let graphGuideTime = "zemkidsMImgGraphRecomTime"
        
        public static let cardFolder = "zemkidsMMyCardFolder1"
        public static let cardFolderWide = "zemkidsMMyCardFolder2"
        
        
    }
    
    struct image {
        public static let noProfile = "zemkidsMImgKidsprofileDefault"
        public static let emptyRelationVod = "zemkidsMImgSynopsisNocontents"
        public static let synopsisBg = isPad ? "zemkidsTIBgSynopsisEnter" : "zemkidsMBgSynopsisEnter"
        public static let homeBg = "zemkidsMBgKidsHome01"
        public static let myBg = "zemkidsTIBgKidsMy01"
        public static let profileBg = "zemkidsMMyProfileBg"
        public static let reportImg = "zemkidsMMyReportImg"
        public static let needPairing = "imgZemkidsTIImgMySharing"
       
        public static let englishReport = "zemkidsTIImgNotEnglish"
        public static let infantDevelopmentReport = "zemkidsTIImgReportNotBook"
        public static let creativeObservationReport = "zemkidsTIImgReportNotCreativity"
        
        public static let resultEnglish = "zemkidsMEngTestResult"
        public static let resultDiagnostic = "zemkidsMCreateTestResult"
        
        public static let resultReading1 = "zemkidsMImgReportSports"
        public static let resultReading2 = "zemkidsMImgReportCardLanguage"
        public static let resultReading3 = "zemkidsMImgReportCardCognitive"
        public static let resultReading4 = "zemkidsMImgReportCardSociety"
        public static let resultReading5 = "zemkidsMImgReportLife"
        
        public static let testEnglish1 = "zemkidsMEngTestImg1"
        public static let testEnglish2 = "zemkidsMEngTestImg2"
        public static let testEnglish3 = "zemkidsMEngTestImg3"
        
    }
    
    struct ani {
        public static let splash:[String] = (0...47).map{ "zemkidsMSplash" + $0.description.toFixLength(2) }
        public static let loading:[String] = (0...59).map{ "zemkidsMLoading" + $0.description.toFixLength(2) }
        
        public static let testStart:[String] = (1...30).map{ "zemkidsTITestStart0" + $0.description.toFixLength(2) }
        public static let testEnd:[String] = (1...31).map{ "zemkidsTITestEnd0" + $0.description.toFixLength(2) }
        public static let answer:[String] = (1...61).map{ "zemkidsTITestGood0" + $0.description.toFixLength(2) }
        public static let answerWrong:[String] = (1...60).map{ "zemkidsTITestBad0" + $0.description.toFixLength(2) }
    }
    
    struct age {
        static func getIcon(age:String?) -> String {
            switch age {
            case "7": return "zemkidsMFlagKidsAgeAll"
            case "12": return "zemkidsMFlagKidsAge12"
            default: return "zemkidsMFlagKidsAgeAll"
            }
        }
    }
    
    static let characterList = [
        "zemkidsTIImgKidsprofileBoy01",
        "zemkidsTIImgKidsprofileBoy02",
        "zemkidsTIImgKidsprofileBoy03",
        "zemkidsTIImgKidsprofileGirl01",
        "zemkidsTIImgKidsprofileGirl02",
        "zemkidsTIImgKidsprofileGirl03",
    ]
    
    static let characterGnbList = [
        "zemkidsMImgGnbKidsprofileBoy01",
        "zemkidsMImgGnbKidsprofileBoy02",
        "zemkidsMImgGnbKidsprofileBoy03",
        "zemkidsMImgGnbKidsprofileGirl01",
        "zemkidsMImgGnbKidsprofileGirl02",
        "zemkidsMImgGnbKidsprofileGirl03",
    ]
    
}
