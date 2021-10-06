//
//  PlayBlockClip.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/09/20.
//

import Foundation
import SwiftUI
import Combine

extension PlayBlock{
    func reload(){
        self.delayUpdateCancel()
        self.datas = []
        self.appearList = []
        self.infinityScrollModel.reload()
        self.focusIndex = -1
        self.load()
    }
    
    func load(){
        if  !self.infinityScrollModel.isLoadable { return }
        withAnimation{ self.isError = false }
        self.infinityScrollModel.onLoad()
        if !self.isClip {
            self.loadPreview()
        } else {
            self.loadClip()
        }
    }
    
    func loadPreview(){
        self.viewModel.request = .init(
            id: self.tag,
            type: .getGridPreview(
                self.viewModel.menuId,
                self.infinityScrollModel.page + 1)
        )
    }
    func loadClip(){
        if self.isInitSortAble {
            if let datas = self.setupSortAble(clip:self.viewModel.data) {
                setDatas(datas:datas)
                return
            }
            self.isInitSortAble = false
        }
       
        if let api = self.viewModel.data?.getRequestApi(
            apiId:self.tag,
            pairing:self.pairing.status,
            kid: self.pairing.kid,
            sortType: self.sortType,
            isOption: false)
        {
            guard let blockData = self.viewModel.data else { return }
            if blockData.dataType != .grid {
                self.isPaging = false
                withAnimation{ self.isSortAble = true }
                self.viewModel.request = api
                return
            }
        }

        self.isPaging = true
        withAnimation{ self.isSortAble = true }
        self.viewModel.request = .init(
            id: self.tag,
            type: .getGridEvent(
                self.viewModel.menuId,
                self.sortType,
                self.infinityScrollModel.page + 1)
        )
    }
    
    func onError(){
        withAnimation{ self.isError = true }
    }
    
    func loaded(_ res:ApiResultResponds){
        if !self.isClip {
            self.loadedPreview(res)
            return
        }
        if self.isPaging {
            loadedGrid(res)
        }else{
            loadedBlock(res)
        }
       
    }
    
    private func loadedPreview(_ res:ApiResultResponds){
        guard let data = res.data as? GridPreview else { return }
        setDatas(datas: data.contents)
    }
    
    private func loadedGrid(_ res:ApiResultResponds){
        guard let data = res.data as? GridEvent else { return }
        if self.infinityScrollModel.page == 0 {
            self.totalCount = data.total_content_count ?? 0
        }
        setDatas(datas: data.contents)
    }
    
    private func loadedBlock(_ res:ApiResultResponds) {
        guard let data = self.viewModel.data else { return self.onError() }
       
        switch data.dataType {
        case .cwGrid:
            guard let resData = res.data as? CWGrid else {return}
            guard let grid = resData.grid else { return self.onError() }
            var allDatas:[ContentItem] = []
            grid.forEach{ g in
                if let blocks = g.block {
                    allDatas.append(contentsOf: blocks)
                }
            }
            self.totalCount = allDatas.count
            setDatas(datas: allDatas)
        
        case .grid:
            guard let resData = res.data as? GridEvent else { return self.onError() }
            guard let blocks = resData.contents else { return self.onError() }
            self.totalCount = blocks.count
            setDatas(datas: blocks)
        default: self.onError()
        }
    }
    
    private func setDatas(datas:[PreviewContentsItem]?) {
        guard let datas = datas else {
            if self.datas.isEmpty { self.onError() }
            return
        }
        if !datas.isEmpty {
            let start = self.datas.count
            let end = start + datas.count
            let loadedDatas:[PlayData] = zip(start...end, datas).map { idx, d in
                return PlayData().setData(data: d, idx: idx)
            }
            self.datas.append(contentsOf: loadedDatas)
            if self.pairing.status == .pairing {
                self.viewModel.request = .init(
                    id: self.tag,
                    type: .getNotificationVod(
                        loadedDatas.filter{$0.srisId != nil}.map{$0.srisId!},
                        loadedDatas.filter{$0.epsdId != nil}.map{$0.epsdId!},
                        .movie,
                        returnDatas: loadedDatas
                        ),
                    isOptional:true
                )
            }
            self.maxCount = self.datas.count
            self.setupInitFocus()
            self.delayUpdate()
        }
        self.infinityScrollModel.onComplete(itemCount: datas.count)
    }
    
    private func setDatas(datas:[ContentItem]?) {
        guard let datas = datas else {
            if self.datas.isEmpty { self.onError() }
            return
        }
        if !datas.isEmpty {
            let start = self.datas.count
            let end = start + datas.count
            let loadedDatas:[PlayData] = zip(start...end, datas).map { idx, d in
                return PlayData().setData(data: d, idx: idx)
            }
            self.datas.append(contentsOf: loadedDatas)
            self.maxCount = self.datas.count
            self.setupInitFocus()
            self.delayUpdate()
        }
        self.infinityScrollModel.onComplete(itemCount: datas.count)
    }
    
    private func setDatas(datas:[VideoData]?) {
        guard let datas = datas else {
            if self.datas.isEmpty { self.onError() }
            return
        }
        if !datas.isEmpty {
            let start = self.datas.count
            let end = start + datas.count
            let loadedDatas:[PlayData] = zip(start...end, datas).map { idx, d in
                return PlayData().setData(data: d, idx: idx)
            }
            self.datas.append(contentsOf: loadedDatas)
            self.maxCount = self.datas.count
            self.setupInitFocus()
            self.delayUpdate()
        }
        self.infinityScrollModel.onComplete(itemCount: datas.count)
    }
    
    private func setupInitFocus(){
        if let initIdx = self.viewModel.initFocus{
            self.initFocus = initIdx
            self.viewModel.resetInitFocus()
            
        }else if let initID = self.viewModel.initFocusID {
            if let find = self.datas.firstIndex(where: { $0.epsdId == initID }) {
                self.initFocus = find
            }
            self.viewModel.resetInitFocus()
        }
    }
    
    private func setupSortAble(clip:BlockData?) -> [VideoData]?{
        guard let data = clip else {return nil}
        guard let datas = data.allVideos else {return nil}
        if datas.isEmpty {return nil}
        switch self.sortType {
        default :
            self.totalCount = datas.count 
            self.isSortAble = false
            self.isPaging = false
            return datas
        }
    }
    
    func sortAction(_ sort:EuxpNetwork.SortType) {
        self.sortType = sort
        self.reload()
    }
    
    struct ClipHeader:PageComponent {
        var totalCount:Int
        var isSortAble:Bool
        var marginTop : CGFloat
        let action: (_ type:EuxpNetwork.SortType) -> Void
        var body :some View {
            SortTab(
                count:self.totalCount,
                isSortAble: self.isSortAble,
                sortOption: [.popularity, .latest, .title],
                action:self.action
            )
            .padding(.horizontal, Dimen.margin.thin)
        }
    }

}
