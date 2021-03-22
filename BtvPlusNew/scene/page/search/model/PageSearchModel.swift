//
//  PageSearchModel.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/20.
//

import Foundation



class PageSearchModel :ObservableObject, PageProtocol {
    
    @Published private(set) var searchDatas:[SearchData] = []
    
    private var apiCoreDataManager:ApiCoreDataManager? = nil
    private var localKeywords:[String] = []
    private var popularityKeywords:[String] = []
    private var popularityDatas:[PosterData] = []
    
    func onAppear(apiCoreDataManager:ApiCoreDataManager) {
        self.apiCoreDataManager = apiCoreDataManager
        DispatchQueue.global().async(){
            let localDatas = apiCoreDataManager.getAllKeywords()
            DispatchQueue.main.async {
                self.localKeywords.append(contentsOf: localDatas)
                self.updateSearchKeyword()
            }
        }
    }
    
    func addSearchKeyword (keyword:String){
        let find = self.localKeywords.first(where: {$0 == keyword})
        if find == nil {
            self.localKeywords.append(keyword)
            DispatchQueue.global().async(){
                self.apiCoreDataManager?.addKeyword(keyword)
            }
        }
    }
    func removeSearchKeyword (keyword:String){
        guard let find = self.localKeywords.firstIndex(where: {$0 == keyword}) else {
            return
        }
        self.localKeywords.remove(at: find)
        self.updateSearchKeyword()
        DispatchQueue.global().async(){
            self.apiCoreDataManager?.removeKeyword(keyword)
        }
    }
    func removeAllSearchKeyword (){
        self.localKeywords.removeAll()
        self.updateSearchKeyword()
        DispatchQueue.global().async(){
            self.localKeywords.forEach{
                self.apiCoreDataManager?.removeKeyword($0)
            }
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
        self.searchDatas = datas.filter{$0.title != nil}.map{SearchData().setData(keyword: $0.title!)}
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
            self.searchDatas = datas
        }
    }
    
    func updatePopularityVod (_ data:SearchPopularityVod? = nil){
        guard let result = data?.data else {return}
        guard let datas = result.results_vod else {return}
        self.popularityDatas = datas.map{PosterData().setData(data: $0)}
    }
    
    func updateSearchCategory (_ data:SearchCategory? = nil){
        guard let result = data?.data else {return}
        guard let datas = result.results_vod else {return}
        
    }
    
    
    
    
    private func getLatestData() -> [SearchData] {
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
