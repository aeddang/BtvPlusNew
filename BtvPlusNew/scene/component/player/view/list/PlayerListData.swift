//
//  VideoPlayerData.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/24.
//

import Foundation
class PlayerListData:InfinityData{
    private(set) var image: String? = nil
    private(set) var title: String? = nil
    private(set) var subTitle: String? = nil
    private(set) var count: String = ""
    
    private(set) var synopsisType:SynopsisType = .title
    private(set) var synopsisData:SynopsisData? = nil
    private(set) var epsdId:String? = nil
    private(set) var srisId:String? = nil
    
    func setData(data:SeriesInfoItem, title:String? = nil, isClip:Bool = false, idx:Int = -1) -> PlayerListData {
        if  isClip {
            self.title = data.sub_title
        } else {
            self.title = data.sub_title ?? data.brcast_exps_dy
        }
        if let count = data.brcast_tseq_nm {
            self.count = count + String.app.broCount
        }
        image = ImagePath.thumbImagePath(filePath: data.poster_filename_h, size: ListItemKids.video.size)
        index = idx
        epsdId = data.epsd_id
        self.contentID = epsdId ?? ""
        return self
    }
}
