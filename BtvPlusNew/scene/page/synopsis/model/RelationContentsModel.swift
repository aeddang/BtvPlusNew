//
//  RelationContentsModel.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/15.
//

import Foundation

struct SeasonData {
    var title:String? = nil
    var srisId:String? = nil
    var synopsisData:SynopsisData? = nil
}

struct SynopsisRelationData {
    var menuId:String? = nil
    var cwCallId:String? = nil
    var epsdId:String? = nil
    var epsdRsluId:String? = nil
}

enum SerisSortType {
    case count, latest
    
    var name: String {
        switch self {
        case .count: return String.sort.count
        case .latest: return String.sort.latest
        }
    }
    
}


class RelationContentsModel {
    private(set) var isReady = false
    private(set) var serisTitle:String? = nil
    private(set) var relationTabs:[String] = []
    
    private(set) var seasons:[SeasonData] = []
    private(set) var seris:[SerisData] = []
    private(set) var playList:[VideoData] = []
    private(set) var serisSortType:SerisSortType = .latest
    private(set) var relationContents:[[PosterData]] = []
    private(set) var synopsisRelationData:SynopsisRelationData? = nil
    
    var currentSeasonIdx:Int = -1
    
    func reset(synopsisType:MetvNetwork.SynopsisType?){
        if synopsisType != .title {
            self.relationContents = []
            self.relationTabs = []
            self.seris = []
            self.serisTitle = nil
            self.isReady = false
        }
    }
    
    func setData(synopsis:SynopsisModel) {
        self.isReady = true
        self.serisTitle = synopsis.srisTitle
        if let list = synopsis.seriesInfoList {
            self.seris = list.map{SerisData().setData(data: $0, title: self.serisTitle)}
            self.playList = zip(list, 0...list.count).map{ data, idx in
                VideoData().setData(data: data, title: self.serisTitle, idx: idx)}
        }
        if let list = synopsis.siries {
            self.seasons = list.map{
                let data = SynopsisData(
                    srisId: $0.sris_id,
                    searchType: EuxpNetwork.SearchType.sris.rawValue,
                    epsdId: $0.epsd_id, epsdRsluId: nil, prdPrcId: nil, kidZone: nil)
                return SeasonData(title: $0.sson_choic_nm, srisId:$0.sris_id, synopsisData: data)
            }
            self.currentSeasonIdx = self.seasons.firstIndex(where:{ $0.srisId == synopsis.srisId }) ?? -1
        }
        
        
        
        if let temp = synopsis.cwCallId {
            var cwCallIdVal:String? = nil
            switch synopsis.srisTypCd {
            case .title:
                cwCallIdVal = "RELATED.MOVIE.PAGE".caseInsensitiveCompare(temp) == .orderedSame
                    ? "MB4.RELATED.MOVIE.PAGE"
                    : temp
            case .season:
                cwCallIdVal = "RELATED.TVPROGRAM.PAGE".caseInsensitiveCompare(temp) == .orderedSame
                    ? "RELATED.TVPROGRAM_RM.PAGE"
                    : temp
            default: return
            }
            if let cw = cwCallIdVal {
                self.synopsisRelationData = SynopsisRelationData(
                    menuId: synopsis.srisId ?? "",
                    cwCallId: cw,
                    epsdId: synopsis.epsdId ?? "",
                    epsdRsluId: synopsis.epsdRsluId ?? "")
            }
        }
       
    }
    
    func setData(data:RelationContents?) {
        guard let data = data else {
            createTab()
            return
        }
        guard let infos = data.related_info else {
            createTab()
            return
        }
        let tabs:[String] = infos.filter{ $0.sub_title != nil }.map{ $0.sub_title!}
        self.relationContents = infos.filter{ $0.block != nil }.map{
            $0.block!.map{ PosterData().setData(data: $0) }
        }
        self.createTab(tabs: tabs)
    }
    
    func getSerisDatas(sort:SerisSortType? = nil) -> [SerisData] {
        let sort = sort ?? self.serisSortType
        self.serisSortType = sort
        if self.seris.isEmpty { return self.seris }
        return self.seris.sorted(by: {
            switch sort {
            case .count : return $0.brcastTseqNm < $1.brcastTseqNm
            case .latest : return $0.brcastTseqNm > $1.brcastTseqNm
            }
        })
    }
    
    func getRelationContentSets(idx:Int) -> [PosterDataSet] {
        if self.relationContents.count <= idx { return [] }
        let datas = self.relationContents[idx]
        let count = 3
        var rows:[PosterDataSet] = []
        var cells:[PosterData] = []
        datas.forEach{ d in
            if cells.count < count {
                cells.append(d)
            }else{
                rows.append(
                    PosterDataSet(
                        count: count,
                        datas: cells,
                        isFull: true)
                )
                cells = [d]
            }
        }
        if !cells.isEmpty {
            rows.append(
                PosterDataSet(
                    count: count,
                    datas: cells,
                    isFull: cells.count == count)
            )
        }
        return rows
        
    }
    

    private func createTab(tabs:[String]? = nil){
        self.relationTabs = []
        if  !self.seris.isEmpty { self.relationTabs.append(String.pageText.synopsisSiris) }
        if let tabs = tabs {self.relationTabs.append(contentsOf: tabs)}
    }
    
}
