//
//  PageSearchModel.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/20.
//

import Foundation
class PageKidsSearchModel :ObservableObject, PageProtocol {
    
    @Published private(set) var searchDatas:[SearchData] = []
    
    func updateCompleteKeywords (_ data:CompleteKeyword? = nil, searchKeyword:String? = nil){
        guard let result = data?.data else {return}
        guard let datas = result.results else {return}
        if let search = searchKeyword {
            self.searchDatas = datas.filter{$0.title != nil}.map{SearchData().setData(keyword: $0.title!, search: search)}
        } else {
            self.searchDatas = datas.filter{$0.title != nil}.map{SearchData().setData(keyword: $0.title!)}
        }
    }
    
    func updateSearchKeyword (_ keywords:[String]? = nil){
        if let keywords = keywords, !keywords.isEmpty {
            self.searchDatas = keywords.map{ keyword in
                SearchData().setData(
                    keyword: keyword)
            }
        } else {
            self.searchDatas = []
        }
    }
    
    func updateSearchCategory (_ data:SearchCategory? = nil, keyword:String? = nil) ->[BlockData]{
        guard let result = data?.data else {return []}
        var blocks:[BlockData] = []
        var isEmpty = true
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
        if isEmpty {return []}
        return blocks
    }
    
    private func getResultsVod(datas:[CategoryVodItem],keyword:String? = nil) -> BlockData{
        var actionData = MenuNaviActionBodyItem(search_keyword:keyword)
        actionData.menu_name = String.app.vod + datas.count.description
        let allPosters:[PosterData] = datas.map{
            PosterData(pageType: .kids).setData(data: $0, searchType:.vod).setNaviLog(action: actionData)
        }
        let block = BlockData(pageType: .kids)
            .setData(title: String.app.vod, datas: allPosters, searchType:.vod, keyword: keyword)
            .setNaviLog(pageCloseActionLog: actionData)
       return block
    }
    private func getResultsSris(datas:[CategorySrisItem],keyword:String? = nil) -> BlockData{
        var actionData = MenuNaviActionBodyItem(search_keyword:keyword)
        actionData.menu_name = String.app.vod + datas.count.description
        actionData.category = "회차"
        let allPosters:[VideoData] = datas.map{
            VideoData(pageType: .kids).setData(data: $0, searchType:.vodSeq).setNaviLog(action: actionData)
        }
        let block = BlockData(pageType: .kids)
            .setData(title: String.app.sris, datas: allPosters, searchType:.vodSeq, keyword: keyword)
            .setNaviLog(pageCloseActionLog: actionData)
       return block
    }
}
