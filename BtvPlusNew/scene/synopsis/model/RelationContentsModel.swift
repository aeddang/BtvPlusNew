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
    var nameKids: String {
        switch self {
        case .count: return String.sort.countKids
        case .latest: return String.sort.latestKids
        }
    }
    
}


class RelationContentsModel:ObservableObject {
    private(set) var isReady = false
    private(set) var serisTitle:String? = nil
    private(set) var relationTabs:[String] = []
    
    private(set) var seasons:[SeasonData] = []
    private(set) var seris:[SerisData] = []
    private(set) var playList:[PlayerListData] = []
    private(set) var serisSortType:SerisSortType? = nil
    private(set) var apiSortType:SerisSortType? = nil
    private(set) var relationContents:[[PosterData]] = []
    private(set) var synopsisRelationData:SynopsisRelationData? = nil
    private(set) var pageType:PageType = .btv
    private(set) var serisTip:String? = nil
    private(set) var unavailableSeris:Bool = false
    
    @Published var selectedEpsdId:String? = nil
    
    var currentSeasonIdx:Int = -1
    
    func reset(synopsisType:MetvNetwork.SynopsisType?, pageType:PageType = .btv){
        if synopsisType != .title {
            self.relationContents = []
            self.relationTabs = []
            self.seris = []
            self.serisTitle = nil
            self.isReady = false
        }
        self.unavailableSeris = false
        self.pageType = pageType
    }
    
    func setData(synopsis:SynopsisModel) {
        self.unavailableSeris = false
        self.isReady = true
        self.serisTitle = synopsis.srisTitle
        if let list = synopsis.seriesInfoList {
            let filterList = synopsis.isTrstrs && !synopsis.isPurchasedPPM ? list.filter{ $0.sale_prc_vat != 0 } : list
            self.seris = zip(filterList, 0...filterList.count).map{data, idx in
                SerisData(pageType: self.pageType).setData(data: data, title: self.serisTitle, idx: idx)}
            self.playList = zip(filterList, 0...filterList.count).map{ data, idx in
                PlayerListData().setData(data: data, title: self.serisTitle, idx: idx)}
            self.apiSortType = synopsis.isSrisCompleted ? .count : .latest
            if list.count != filterList.count {
                self.serisTip = String.pageText.synopsisUnavailableSeriesMessage
            }
            if !self.seris.isEmpty && self.seris.first(where: {$0.epsdId == synopsis.epsdId}) == nil {
                self.unavailableSeris = true
            }
        }
        
        if let list = synopsis.siries {
            self.seasons = list.map{
                let data = SynopsisData(
                    srisId: $0.sris_id,
                    searchType: EuxpNetwork.SearchType.sris.rawValue,
                    epsdId: $0.epsd_id, epsdRsluId: nil, prdPrcId: nil, kidZone: nil,
                    synopType: .season
                )
                
                return SeasonData(title: $0.sson_choic_nm, srisId:$0.sris_id, synopsisData: data)
            }
            self.currentSeasonIdx = self.seasons.firstIndex(where:{ $0.srisId == synopsis.srisId }) ?? -1
        }
        if synopsis.isQuiz && self.pageType == .kids{
            let idx = self.seris.count
            self.seris.append( SerisData(pageType: self.pageType).setQuiz(synopsis: synopsis, idx: idx))
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
            $0.block!.map{ PosterData(pageType: self.pageType).setData(data: $0) }
        }
        self.createTab(tabs: tabs)
    }
    
    func getAvailableSeris()-> SerisData? {
        if self.seris.isEmpty {return nil}
        return self.apiSortType == .latest ? self.seris.last :  self.seris.first
    }
    
    func getCurrentSerisSortType()-> SerisSortType{
        return self.serisSortType ?? self.apiSortType ?? .latest
    }
    
    func getSerisDatas(sort:SerisSortType? = nil) -> [SerisData] {
        if sort != nil {
            self.serisSortType = sort
        }
        let sort = sort ?? self.getCurrentSerisSortType()
        
        if self.seris.isEmpty { return self.seris }
        return self.seris.sorted(by: {
            switch sort {
            case .count : return $0.brcastTseqNm < $1.brcastTseqNm
            case .latest : return $0.brcastTseqNm > $1.brcastTseqNm
            }
        })
    }
    
    func getRelationContentSets(idx:Int, row:Int = 3 ) -> [PosterDataSet] {
        if self.relationContents.count <= idx { return [] }
        let datas = self.relationContents[idx]
        let count = row
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
        if  !self.seris.isEmpty {
            self.relationTabs.append(String.pageText.synopsisSiris)
            if self.pageType == .kids {return}
        }
        if let tabs = tabs {self.relationTabs.append(contentsOf: tabs)}
    }
    
}
