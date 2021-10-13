//
//  PlayerData.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation


enum SynopsisPlayType:Equatable {
    case unknown, preview(Int, Bool? = nil) , preplay(Bool? = nil),
         clip(Bool? = nil , SynopsisData? = nil), 
         vod(Double = 0, Bool? = nil), vodNext(Double = 0, Bool? = nil, isNextAuto:Bool = true), vodChange(Double = 0, Bool? = nil)
    
    var name: String? {
        switch self {
        case .preview: return String.player.preview
        case .preplay: return String.player.preplaying
        default: return nil
        }
    }
    var logCategory: String {
        switch self {
        case .preview: return "trailer"
        case .preplay: return "3minute"
        default: return "common"
        }
    }
    
    var logSynopCategory: String {
        switch self {
        case .preview: return "미리보기"
        case .preplay: return "미리보기"
        default: return "시청하기"
        }
    }
    
    var logConfig: String {
        switch self {
        case .preview: return "trailer"
        case .preplay: return "3m_preview"
        default: return "watching"
        }
    }
    
    
    public static func == (l:SynopsisPlayType, r:SynopsisPlayType)-> Bool {
        switch (l, r) {
        case ( .preview, .preview):return true
        case ( .preplay, .preplay):return true
        case ( .clip, .clip):return true
        case ( .vod, .vod):return true
        case ( .vodNext, .vodNext):return true
        case ( .vodChange, .vodChange):return true
        default: return false
        }
    }
}

class SynopsisPlayerData {
    private(set) var type:SynopsisPlayType = .unknown
    private(set) var previews:[PreviewItem]? = nil
    private(set) var hasNext:Bool = false
    private(set) var isClip:Bool = false
    private(set) var nextEpisode:PlayerListData? = nil
    private(set) var nextSeason:SeasonData? = nil
    private(set) var openingTime:Double? = nil
    private(set) var endingTime:Double? = nil
    func setData(type:SynopsisPlayType, synopsis:SynopsisModel, relationContentsModel:RelationContentsModel? = nil,
                 isPairing:Bool? = nil) -> SynopsisPlayerData {
        
        self.type = type
        switch type {
        case .preview:
            self.previews = isPairing == true ? synopsis.previews : []
        case .preplay:break
        case .vod, .vodChange, .vodNext:
            
            if let list = synopsis.rsluInfoList {
                if !list.isEmpty {
                    let rslu = list.first
                    self.openingTime = rslu?.openg_tmtag_tmsc?.number
                    self.endingTime = rslu?.endg_tmtag_tmsc?.number 
                }
            }
            guard let relationContentsModel = relationContentsModel else {return self}
            if let find = relationContentsModel.playList.first(where: {$0.epsdId == synopsis.epsdId}) {
                if find.index < (relationContentsModel.playList.count-1) {
                    self.nextEpisode = relationContentsModel.playList[find.index+1]
                    self.hasNext = true
                    return self
                }
            }
            let sortedSeason =  relationContentsModel.seasons.sorted(by: {$0.sortSeq < $1.sortSeq})
            let seasonCount = sortedSeason.count
            
            if let find = zip(0...seasonCount, relationContentsModel.seasons)
                .first(where: { idx, season in season.srisId == synopsis.srisId}) {
                if find.0 < seasonCount-1 {
                    self.nextSeason = sortedSeason[find.0+1]
                    self.hasNext = true
                }
            }
        default:break
        }
        return self
    }
    
    func setData(type:SynopsisPlayType,datas:[PlayerListData], epsdId:String ) -> SynopsisPlayerData {
        self.type = type
        self.isClip = true
        if let find = datas.first(where: {$0.epsdId == epsdId}) {
            if find.index < (datas.count-1) {
                self.nextEpisode = datas[find.index+1]
                self.hasNext = true
                return self
            }
        }
        return self
    }
    
    var previewCount:String {
        get{
            switch type {
            case .preview(let count, _ ):
                let num = self.previews?.count ?? 0
                if num > 1 {
                    return count.description + "/" + num.description
                }else{
                    return ""
                }
            default: return ""
            }
        }
    }
    
    var nextString:String? {
        get{
            if self.isClip {
                return String.player.nextClip
            }else if self.nextEpisode != nil {
                return String.player.next
            }else if let _ = self.nextSeason {
                return String.player.nextSeason
            }
            return nil
        }
    }
}
