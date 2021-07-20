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
    
    func updateSearchCategory (_ data:SearchCategory? = nil) ->[BlockData]{
        guard let result = data?.data else {return []}
        var blocks:[BlockData] = []
        
        if let datas = result.results_vod {
            let allPosters:[PosterData] = datas.map{ PosterData(pageType: .kids).setData(data: $0)}
            let block = BlockData(pageType: .kids).setData(title: String.app.vod, datas: allPosters)
            blocks.append(block)
        }
        if let datas = result.results_vod_tseq {
            let allPosters:[VideoData] = datas.map{ VideoData(pageType: .kids).setData(data: $0)}
            let block = BlockData(pageType: .kids).setData(title: String.app.sris, datas: allPosters)
            blocks.append(block)
        }
        if let datas = result.results_corner {
            let allPosters:[VideoData] = datas.map{ VideoData(pageType: .kids).setData(data: $0)}
            let block = BlockData(pageType: .kids).setData(title: String.app.corner, datas: allPosters)
            blocks.append(block)
        }
        if let datas = result.results_people {
            let allPosters:[PosterData] = datas.map{ PosterData(pageType: .kids).setData(data: $0)}
            let block = BlockData(pageType: .kids).setData(title: String.app.people, datas: allPosters)
            blocks.append(block)
        }
        return blocks
    }
}
