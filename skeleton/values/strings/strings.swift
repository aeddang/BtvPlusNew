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
    
    struct remote {
        public static let playEmpty = "remotePlayEmpty".loaalized()
        public static let playError = "remotePlayError".loaalized()
        public static let playNoInfo = "remotePlayNoInfo".loaalized()
        public static let inputChannel = "remoteInputChannel".loaalized()
        public static let inputText = "remoteInputText".loaalized()
        public static let inputChannelHolder = "remoteInputChannelHolder".loaalized()
        public static let inputTextHolder = "remoteInputTextHolder".loaalized()
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
        public static let oceanPhaseLeading = "monthlyOceanPhaseLeading".loaalized()
        public static let oceanPhaseTrailing = "monthlyOceanPhaseTrailing".loaalized()
        public static let oceanAuth = "monthlyOceanAuth".loaalized()
        public static let oceanPeriodAuth = "monthlyOceanPeriodAuth".loaalized()
    }
    
    struct footer {
        public static let text = "footerText".loaalized()
        public static let text1 = "footerText1".loaalized() // for pad
        public static let text2 = "footerText2".loaalized() // for pad
        public static let button = "footerButton".loaalized()
    }
    
    struct voice {
        public static let searchTitle = "voiceSearchTitle".loaalized()
        public static let searchText = "voiceSearchText".loaalized()
    }

    struct share {
        public static let inviteMsg =  "shareInviteMsg".loaalized()
        public static let synopsis = "shareSynopsis".loaalized()
        public static let complete = "shareComplete".loaalized()
        public static let fail = "shareFail".loaalized()
    }
  
    
}