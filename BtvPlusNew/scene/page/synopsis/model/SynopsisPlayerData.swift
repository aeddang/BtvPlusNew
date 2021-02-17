//
//  PlayerData.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation


enum SynopsisPlayType {
    case unknown, preview(Int, Bool? = nil) , preplay(Bool? = nil),
         vod(Double = 0, Bool? = nil), vodNext(Double = 0, Bool? = nil), vodChange(Double = 0, Bool? = nil)
    
    var name: String? {
        switch self {
        case .preview: return String.player.preview
        case .preplay: return String.player.preplay
        default: return nil
        }
    }
}

class SynopsisPlayerData {
    private(set) var type:SynopsisPlayType = .unknown
    private(set) var previews:[PreviewItem]? = nil
    private(set) var siries:[SeriesItem]? = nil
    
    private(set) var hasNext:Bool = false
    private(set) var nextSeason:String? = nil
    private(set) var nextEpisode:String? = nil
    private(set) var openingTime:Double? = nil
    func setData(type:SynopsisPlayType, synopsis:SynopsisModel) -> SynopsisPlayerData {
        self.type = type
        switch type {
        case .preview:
            self.previews = synopsis.previews
        case .preplay:do{}
        case .vod, .vodChange, .vodNext:
            if let srisId = synopsis.nextSrisId {
                if !srisId.isEmpty { self.nextSeason = srisId }
            }
            if let epsdId = synopsis.nextEpsdId {
                if !epsdId.isEmpty { self.nextEpisode = epsdId }
            }
            self.siries = synopsis.siries
            self.hasNext = self.nextEpisode != nil || self.nextSeason != nil
            if let list = synopsis.rsluInfoList {
                if !list.isEmpty {
                    let rslu = list.first
                    self.openingTime = rslu?.openg_tmtag_tmsc?.number
                }
            }
            
            
        default:do{}
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
    
    var nextString:String {
        get{
            if self.nextEpisode != nil {
                return String.player.next
            }else if self.nextSeason != nil {
                if self.siries != nil && self.siries?.isEmpty != true {
                    let siris = self.siries![0]
                    let leading = siris.sson_choic_nm ?? String.player.season
                    let tailing = siris.sort_seq?.description ?? ""
                    return leading + tailing + " 1" + String.app.sesonCount
                }else{
                    return String.player.season + " 1" + String.app.sesonCount
                }
            }
            return ""
        }
    }
    
}
