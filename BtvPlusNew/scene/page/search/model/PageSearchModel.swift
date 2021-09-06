//
//  PageSearchModel.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/20.
//

import Foundation
class PageSearchModel :ObservableObject, PageProtocol {
    
    @Published private(set) var searchDatas:[SearchData] = []
   
    private var keywordCoreData:KeywordCoreData = KeywordCoreData()
    private var localKeywords:[String] = []
    private var popularityKeywords:[String] = []
    private var popularityDatas:[PosterData] = []
    
    func onAppear() {
        DispatchQueue.global(qos: .background).async(){
            let localDatas = self.keywordCoreData.getAllKeywords()
            DispatchQueue.main.async {
                self.localKeywords.append(contentsOf: localDatas)
                self.updateSearchKeyword()
            }
        }
    }
    
    func addSearchKeyword (keyword:String){
        let find = self.localKeywords.firstIndex(of: keyword)
        
        if let findIdx = find {
            let removeKeyword = self.localKeywords.remove(at: findIdx)
            self.keywordCoreData.removeKeyword(removeKeyword)
            
        }
        self.localKeywords.append(keyword)
        if self.localKeywords.count > 9 {
            self.removeSearchKeyword(keyword: self.localKeywords.first!)
            //DispatchQueue.main.asyncAfter(deadline: .now()+0.1){
                self.updateSearchKeyword()
                //DispatchQueue.global(qos: .background).async(){
                    self.keywordCoreData.addKeyword(keyword)
                //}
            //}
        }
        else {
            self.updateSearchKeyword()
            //DispatchQueue.global(qos: .background).async(){
                self.keywordCoreData.addKeyword(keyword)
            //}
        }
        DispatchQueue.global(qos: .background).async(){
            self.keywordCoreData.saveContext()
        }
    }
    func removeSearchKeyword (keyword:String){
        guard let find = self.localKeywords.firstIndex(where: {$0 == keyword}) else {
            return
        }
        self.localKeywords.remove(at: find)
        self.updateSearchKeyword()
        //DispatchQueue.global(qos: .background).async(){
            self.keywordCoreData.removeKeyword(keyword)
        //}
    }
    func removeAllSearchKeyword (){
        let removeKeywords = self.localKeywords
        //DispatchQueue.global(qos: .background).async(){
            removeKeywords.forEach{
                self.keywordCoreData.removeKeyword($0)
            }
        //}
        
        self.localKeywords.removeAll()
        self.updateSearchKeyword()
        DispatchQueue.global(qos: .background).async(){
            self.keywordCoreData.saveContext()
        }
       
    }
    
    func updatePopularityKeywords (_ data:SearchKeyword? = nil){
        guard let result = data?.data else {return}
        if result.result != ApiCode.success {return}
        guard let datas = result.results_keyword else {return}
        self.popularityKeywords = datas.filter{$0.keyword != nil}.map{$0.keyword!}
        self.updateSearchKeyword()
    }
    func updateCompleteKeywords (_ data:CompleteKeyword? = nil){
        guard let result = data?.data else {return}
        guard let datas = result.results else {return}
        let filterDatas = datas.filter{$0.title != nil}.map{SearchData().setData(keyword: $0.title!)}
        if filterDatas.isEmpty {
            self.updateSearchKeyword()
        } else {
            self.searchDatas = filterDatas
        }
    }
    
    func updateSearchKeyword (_ keywords:[String]? = nil){
        if let keywords = keywords, !keywords.isEmpty {
            self.searchDatas = keywords.map{ keyword in
                SearchData().setData(
                    keyword: keyword)
            }
        } else {
            var datas = self.getLatestData()
            datas.append(contentsOf:  self.getPopularityData())
            datas.first?.isSectionChange = false
            self.searchDatas = datas
        }
    }
    
    func updatePopularityVod (_ data:SearchPopularityVod? = nil){
        guard let result = data?.data else {return}
        guard let datas = result.results_vod else {return}
        self.popularityDatas = datas.map{PosterData().setData(data: $0, searchType: .vod)}
    }
    
    func updateSearchCategory (_ data:SearchCategory? = nil, keyword:String? = nil) ->[BlockData]{
        guard let result = data?.data else {return []}
        var isEmpty = true
        var blocks:[BlockData] = []
        if let datas = result.results_vod {
            isEmpty = false
            blocks.append(self.getResultsVod(datas: datas, keyword: keyword))
        } else {
            blocks.append(self.getResultsVod(datas: [], keyword: keyword))
        }
        if let datas = result.results_vod_tseq {
            isEmpty = false
            blocks.append(self.getResultsSris(datas: datas, keyword: keyword))
        } else {
            blocks.append(self.getResultsSris(datas: [], keyword: keyword))
        }
        if let datas = result.results_clip {
            isEmpty = false
            blocks.append(self.getResultsClip(datas: datas, keyword: keyword))
        } else {
            blocks.append(self.getResultsClip(datas: [], keyword: keyword))
        }
        
        if let datas = result.results_corner {
            isEmpty = false
            blocks.append(self.getResultsCorner(datas: datas, keyword: keyword))
        } else {
            blocks.append(self.getResultsCorner(datas:[], keyword: keyword))
        }
        
        if let datas = result.results_tv {
            isEmpty = false
            blocks.append(self.getResultsTv(datas: datas, keyword: keyword))
        } else {
            blocks.append(self.getResultsTv(datas: [], keyword: keyword))
        }
        
        if let datas = result.results_people {
            isEmpty = false
            blocks.append(self.getResultsPeople(datas: datas, keyword: keyword))
        } else {
            blocks.append(self.getResultsPeople(datas: [], keyword: keyword))
        }
        if isEmpty {return []}
        return blocks
    }
    
    private func getResultsVod(datas:[CategoryVodItem],keyword:String? = nil) -> BlockData{
        var actionData = MenuNaviActionBodyItem(search_keyword:keyword)
        actionData.menu_name = String.app.vod + datas.count.description
        let allPosters:[PosterData] = datas.map{
            PosterData().setData(data: $0, searchType:.vod).setNaviLog(action: actionData)
        }
        let block = BlockData()
            .setData(title: String.app.vod, datas: allPosters, searchType:.vod, keyword: keyword)
            .setNaviLog(pageCloseActionLog: actionData)
       return block
    }
    private func getResultsSris(datas:[CategorySrisItem],keyword:String? = nil) -> BlockData{
        var actionData = MenuNaviActionBodyItem(search_keyword:keyword)
        actionData.menu_name = String.app.vod + datas.count.description
        actionData.category = "회차"
        let allPosters:[VideoData] = datas.map{
            VideoData().setData(data: $0, searchType:.vodSeq).setNaviLog(action: actionData)
        }
        let block = BlockData()
            .setData(title: String.app.sris, datas: allPosters, searchType:.vodSeq, keyword: keyword)
            .setNaviLog(pageCloseActionLog: actionData)
       return block
    }
    private func getResultsClip(datas:[CategoryClipItem],keyword:String? = nil) -> BlockData{
        var actionData = MenuNaviActionBodyItem(search_keyword:keyword)
        actionData.menu_name = String.app.clip + datas.count.description
        actionData.category = "클립"
        let allPosters:[VideoData] = datas.map{
            VideoData(usePrice:false).setData(data: $0, searchType:.clip).setNaviLog(action: actionData)
        }
        let block = BlockData()
            .setData(title: String.app.clip, datas: allPosters, searchType:.clip, keyword: keyword)
            .setNaviLog(pageCloseActionLog: actionData)
       return block
    }
    private func getResultsCorner(datas:[CategoryCornerItem],keyword:String? = nil) -> BlockData{
        var actionData = MenuNaviActionBodyItem(search_keyword:keyword)
        actionData.config = "코너"
        actionData.menu_name = String.app.corner + datas.count.description
        let allPosters:[VideoData] = datas.map{
            VideoData().setData(data: $0, searchType:.demand).setNaviLog(action: actionData)
        }
        let block = BlockData()
            .setData(title: String.app.corner, datas: allPosters, searchType:.demand, keyword: keyword)
            .setNaviLog(pageCloseActionLog: actionData)
       return block
    }
    
    private func getResultsPeople(datas:[CategoryPeopleItem],keyword:String? = nil) -> BlockData{
        var actionData = MenuNaviActionBodyItem(search_keyword:keyword)
        actionData.menu_name = String.app.people + datas.count.description
        let allPosters:[PosterData] = datas.map{ PosterData().setData(data: $0, searchType:.none).setNaviLog(action: actionData)}
        let block = BlockData()
            .setData(title: String.app.people, datas: allPosters, searchType:.none, keyword: keyword)
            .setNaviLog(pageCloseActionLog: actionData)
       return block
    }
    
    private func getResultsTv(datas:[CategoryTvItem],keyword:String? = nil) -> BlockData{
        var actionData = MenuNaviActionBodyItem(search_keyword:keyword)
        actionData.menu_name = String.app.liveTv + datas.count.description
        let allTvs:[TvData] = datas.map{ TvData().setData(data: $0, searchType: .live).setNaviLog(action: actionData)}
        let block = BlockData()
            .setData(title: String.app.liveTv, datas: allTvs, searchType:.live, keyword: keyword)
            .setNaviLog(pageCloseActionLog: actionData)
       return block
    }
    
    
    private func getLatestData() -> [SearchData] {
        if self.localKeywords.isEmpty {
            return []
        }
        var datas:[SearchData] = [
            SearchData().setData(
                keyword: String.pageText.searchLatest, isDeleteAble: true, isSection: true)
        ]
        datas.append(contentsOf: self.localKeywords.reversed().map{ keyword in
            SearchData().setData(
                keyword: keyword, isDeleteAble: true, isSection: false)
        })
        return datas
    }
    
    private func getPopularityData() -> [SearchData] {
        var datas:[SearchData] = [
            SearchData().setData(
                keyword: String.pageText.searchPopularity, isDeleteAble: false, isSection: true)
        ]
        datas.append(contentsOf: self.popularityKeywords.map{ keyword in
            SearchData().setData(
                keyword: keyword, isDeleteAble: false, isSection: false)
        })
        return datas
    }
    
    func getPosterSets(screenSize:CGFloat, datas:[PosterData]? = nil) -> [PosterDataSet] {
        let posters = datas ?? self.popularityDatas
        let count:Int = Int(floor(screenSize / ListItem.poster.type01.width))
        var rows:[PosterDataSet] = []
        var cells:[PosterData] = []
        var total = 0
        posters.forEach{ d in
            if cells.count < count {
                cells.append(d)
            }else{
                rows.append(
                    PosterDataSet( count: count, datas: cells, isFull: true, index:total)
                )
                total += 1
                cells = [d]
            }
        }
        if !cells.isEmpty {
            rows.append(
                PosterDataSet( count: count, datas: cells,isFull: cells.count == count, index: total)
            )
        }
        return rows
    }
    
}
