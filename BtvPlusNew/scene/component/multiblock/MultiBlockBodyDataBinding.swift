//
//  MultiBlockBodyDataBinding.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/09/05.
//

import Foundation

extension MultiBlockBody {
    
    func onDataBinding(res:ApiResultResponds?){
        guard let data = self.loadingBlocks.first(where: { $0.id == res?.id}) else {return}
        var leadingBanners:[BannerData]? = nil
        var total:Int? = nil
        let max = Self.maxCellCount
        let usePrice:Bool = !self.viewModel.isFree
        data.usePrice = usePrice
        switch data.dataType {
        case .cwGrid:
            guard let resData = res?.data as? CWGrid else {return data.setBlank()}
            guard let grid = resData.grid else {return data.setBlank()}
            if grid.isEmpty {return data.setBlank()}
            total = resData.total_count
            data.setData(grids: grid, usePrice: usePrice)
            
        case .cwGridKids:
            guard let resData = res?.data as? CWGridKids else {return data.setBlank()}
            data.errorMassage = resData.status_reason
            guard let grid = resData.grid else {return data.setBlank()}
            if grid.isEmpty {return data.setBlank()}
            total = resData.total_count
            if grid.count == 1 {
                grid.forEach{ g in
                    if let blocks = g.block {
                        switch data.uiType {
                        case .poster :
                            data.posters = blocks[0...min(max, blocks.count-1)].map{ d in
                                PosterData(pageType: self.pageType, usePrice:usePrice).setData(data: d, cardType: data.cardType)
                            }
                        case .video :
                            data.videos = blocks[0...min(max, blocks.count-1)].map{ d in
                                VideoData(pageType: self.pageType, usePrice:usePrice).setData(data: d, cardType: data.cardType)
                            }
                        default: break
                        }
                    }
                }
            } else {
                data.setData(grids: grid)
            }
            
        case .grid:
            guard let resData = res?.data as? GridEvent else {return data.setBlank()}
            guard let blocks = resData.contents else {return data.setBlank()}
            if blocks.isEmpty {return data.setBlank()}
            total = resData.total_content_count
            switch data.uiType {
            case .poster :
                data.posters = blocks[0...min(max, blocks.count-1)].map{ d in
                    PosterData(pageType: self.pageType, usePrice:usePrice).setData(data: d, cardType: data.cardType)
                }

            case .video :
                data.videos = blocks[0...min(max, blocks.count-1)].map{ d in
                    VideoData(pageType: self.pageType, usePrice:usePrice).setData(data: d, cardType: data.cardType)
                }
                
            case .theme :
                data.themas = blocks[0...min(max, blocks.count-1)].map{ d in
                    ThemaData(usePrice:usePrice).setData(data: d, cardType: data.cardType)
                }
            default: break
            }
            leadingBanners = resData.banners?.map{d in
                BannerData(pageType: self.pageType).setData(data: d, type: .list, cardType: .bigPoster)
            }
            
        case .bookMark:
            guard let resData = res?.data as? BookMark else {return data.setBlank()}
            guard let blocks = resData.bookmarkList else {return data.setBlank()}
            if blocks.isEmpty {return data.setBlank()}
            total = resData.bookmark_tot?.toInt()
            switch data.uiType {
            case .poster :
                data.posters = blocks[0...min(max, blocks.count-1)].map{ d in
                    PosterData(pageType: self.pageType, usePrice:usePrice).setData(data: d, cardType: data.cardType)
                }
            case .video :
                data.videos = blocks[0...min(max, blocks.count-1)].map{ d in
                    VideoData(pageType: self.pageType, usePrice:usePrice).setData(data: d, cardType: data.cardType)
                }
            default: break
            }
           
        case .watched:
            guard let resData = res?.data as? Watch else {return data.setBlank()}
            guard let originWatchBlocks = resData.watchList else {return data.setBlank()}
            var watchBlocks:[WatchItem] = originWatchBlocks
            if let ticketId = self.viewModel.selectedTicketId {
                watchBlocks = originWatchBlocks.filter{$0.prod_id == ticketId}
            }
            if watchBlocks.count < 1 {return data.setBlank()}
            total = resData.watch_tot?.toInt()
            switch data.uiType {
            case .poster :
                let posters = watchBlocks.map{ d in
                    PosterData(pageType: self.pageType, usePrice:usePrice).setData(data: d, cardType: data.cardType)
                }
                .filter{$0.isContinueWatch}.filter{$0.progress != 1}
                if  posters.isEmpty == true { return data.setBlank() }
                data.posters = posters
            case .video :
                let videos = watchBlocks.map{ d in
                    VideoData(pageType: self.pageType, usePrice:usePrice).setData(data: d, cardType: data.cardType)
                }
                .filter{$0.isContinueWatch}.filter{$0.progress != 1}
                if  videos.isEmpty == true { return data.setBlank() }
                data.videos = videos
            default: break
            }
        
        case .banner:
            guard let resData = res?.data as? EventBanner else {return data.setBlank()}
            guard let banners = resData.banners else {return data.setBlank()}
            if banners.isEmpty {return data.setBlank()}
                data.banners = banners.map{ d in
                    BannerData().setData(data: d, cardType:data.cardType)
            }
        default: break
        }
        
        var listHeight:CGFloat = 0
        var blockHeight:CGFloat = 0
        let tabHeight:CGFloat = self.viewModel.type == .btv ? Self.tabHeight : Self.tabHeightKids
        var padding = self.viewModel.type == .btv ? Dimen.margin.thin : DimenKids.margin.thin
        
        if let size = data.posters?.first?.type {
            listHeight = size.size.height
            blockHeight = listHeight + tabHeight
        }
        if let size = data.videos?.first{
            listHeight = size.type.size.height + size.bottomHeight
            blockHeight = listHeight + tabHeight
        }
        if let size = data.themas?.first?.type {
            listHeight = size.size.height
            blockHeight = listHeight + tabHeight
            padding = size.spacing
        }
        
        if let size = data.banners?.first?.type {
            let screenSize = self.sceneObserver.screenSize.width - (Dimen.margin.thin*2)
            listHeight = round(screenSize * size.size.height/size.size.width)
            blockHeight = listHeight
        }
        if blockHeight != 0 {
            if let banner = leadingBanners {
                let ratio = ListItem.banner.type03
                let w = round(listHeight * ratio.width/ratio.height)
                banner.forEach{ $0.setBannerSize(width: w , height: listHeight, padding: padding) }
                data.leadingBanners = banner
            }
            data.listHeight = blockHeight
        }
        data.setDatabindingCompleted(total: total, parentTitle: self.viewModel.title)

    }
    
    
}
