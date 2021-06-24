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
    public static let noImg16_9 = "imgDefaultPosterThum"
    public static let noImg4_3 = "imgDefaultMonthlyCardB"
    public static let noImg1_1 = "img07CardDefault"
    public static let noImgCircle1_1 = "img05CardDefault"
    public static let noImg9_16 = "imgDefaultPosterSmall"
    public static let noImg3_4 = "imgDefaultPosterSmall02"
    public static let noImgBanner = "img09CardBannerDefault"
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
        public static let heartOff = "zemkidsMBtnSynopsisFavoriteOff"
        public static let heartOn = "zemkidsMBtnSynopsisFavoriteOn"
        public static let info = "zemkidsMBtnSynopsisTololtipInfoNor"
        public static let warn = "zemkidsMIcSysnopsisWarn"
        public static let tip = "zemkidsMIcSysnopsisTip"
        public static let watchBTv = "zemkidsMBtnSynopsisBtvNor"
        public static let playInfo = "zemkidsMBtnSynopsisInfoNor"
        public static let share = "zemkidsMBtnSynopsisShareNor"
        public static let sort = "zemkidsMDropdownBriDownNor"
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
    
    
    struct shape {
        public static let radioBtnOn = "zemkidsMRadioButtonPre"
        public static let radioBtnOff = "zemkidsMRadioButtonNor"
        public static let checkBoxOn = "zemkidsMProfileImgSel"
        public static let checkBoxOn2 = "zemkidsMPopupCheckSel"
        public static let checkBoxOff = "zemkidsMProfileImgNor"
        
        public static let checkOption = "zemkidsMToggleOptionIcSel"
        
       
        public static let tooltip = isPad ? "zemkidsTTooltipBubble29" : "zemkidsMTooltipBubble29"
        public static let spinner = "icSpinner"
       
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
    struct image {
        public static let noProfile = "zemkidsMGnbNorProfileDefault"
        
      
    }
    
    struct source {
        public static let emptyRelationVod = "zemkidsMImgSynopsisNocontents"
        public static let synopsisBg = isPad ? "zemkidsTIBgSynopsisEnter" : "zemkidsMBgSynopsisEnter"
        
    }
    
    struct ani {
        public static let splash:[String] = (0...47).map{ "zemkidsMSplash" + $0.description.toFixLength(2) }
        public static let loading:[String] = (0...59).map{ "zemkidsMLoading" + $0.description.toFixLength(2) }
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
