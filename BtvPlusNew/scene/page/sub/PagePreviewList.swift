//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine


struct PagePreviewList: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var naviLogManager:NaviLogManager
    @EnvironmentObject var setup:Setup
    @ObservedObject var pageObservable:PageObservable = PageObservable()
   
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var viewModel:PlayBlockModel = PlayBlockModel()
    @ObservedObject var playerModel: BtvPlayerModel = BtvPlayerModel(useFullScreenAction:false, useRecovery: false)
    
    @State var title:String? = nil
    @State var playerTitle:String? = nil
    @State var menuId:String? = nil
    @State var block:BlockData? = nil
    @State var safeAreaTop:CGFloat = 0
    @State var marginBottom:CGFloat = 0
    @State var isInit:Bool = false
    @State var isFullScreen:Bool = false
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
               
                VStack(spacing:0){
                    PageTab(
                        title: self.title,
                        isBack : true,
                        style: .dark
                    )
                    .padding(.top, self.safeAreaTop)
                    PlayBlock(
                        pageObservable:self.pageObservable,
                        viewModel:self.viewModel,
                        infinityScrollModel:self.infinityScrollModel,
                        playerModel: self.playerModel,
                        marginTop: Dimen.margin.thin,
                        marginBottom: self.marginBottom,
                        spacing: self.isClip
                        ? SystemEnvironment.isTablet ? Dimen.margin.thin : Dimen.margin.mediumExtra
                        : SystemEnvironment.isTablet ? Dimen.margin.thin : Dimen.margin.medium
                    )
                    
                }
                .modifier(PageFull(style:.dark))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                if isFullScreen {
                    if self.block != nil {
                        BtvPlayer(
                            pageObservable:self.pageObservable,
                            viewModel:self.playerModel,
                            title: self.playerTitle,
                            contentID : self.epsdId,
                            listData: self.playListData,
                            playerType: .normal
                        )
                       
                    } else {
                        SimplePlayer(
                            pageObservable: self.pageObservable,
                            viewModel : self.playerModel)
                            .modifier(MatchParent())
                            .background(Color.app.black)
                    }
                }
            }
            
            .onReceive(self.sceneObserver.$isUpdated){ update in
                if update {
                    self.safeAreaTop = self.sceneObserver.safeAreaTop
                }
            }
            .onReceive(self.infinityScrollModel.$scrollPosition){ pos in
                self.pageDragingModel.uiEvent = .dragCancel
                
            }
            .onReceive(self.appSceneObserver.$safeBottomLayerHeight){ bottom in
                withAnimation{ self.marginBottom = bottom }
            }
            .onReceive(self.viewModel.$fullPlayData){ data in
                guard let data = data else {
                    if !self.isFullScreen {return}
                    self.isFullScreen = false
                    self.appSceneObserver.useBottomImmediately  = true
                    return
                }
                if self.isFullScreen {return}
                let type = self.viewModel.btvPlayType
                let time = self.viewModel.continuousTime
               
                self.appSceneObserver.useBottomImmediately  = false
                self.pagePresenter.orientationLock(lockOrientation: .landscape)
                var changeType:BtvPlayType? = nil
                switch type {
                case .preview(let value,_):
                    self.isFullScreen = true
                    changeType = .preview(value,isList:false)
                    self.playListData = PlayListData()
                case .vod(let value, let title):
                    
                    self.isFullScreen = true
                    changeType = .vod(value,title)
                    self.playerTitle = title
                    self.epsdId = self.viewModel.finalPlayData?.epsdId
                    self.synopsisData = self.viewModel.finalPlayData?.synopsisData
                    self.playListData = self.viewModel.finalPlayData?.playListData ?? PlayListData()
                    
                default: break
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    
                    self.playerModel
                        .setData(
                            data: data,
                            type: changeType ?? .preview("", isList: false),
                            autoPlay: true,
                            continuousTime: time)
                    self.playerModel.btvUiEvent = .syncListScroll
                    
                }
            }
            .onReceive(self.viewModel.$naviLogPlayData){ playData in
                guard let playData = playData else {return}
                self.sendLogPlayData(playData)
                
            }
            .onReceive(self.playerModel.$event){ evt in
                guard let evt = evt else {return}
                self.sendLogPlay(evt:evt)
            }
            .onReceive(self.playerModel.$streamEvent){ evt in
                guard let evt = evt else {return}
                self.onEventLog(streamEvent: evt)
            }
            .onReceive(self.viewModel.$logEvent){ evt in
                guard let evt = evt else {return}
                self.sendLogEvent(evt: evt)
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    if self.isInit {return}
                    var initFocus:Int?  = nil
                    var initFocusId:String?  = nil
                    if  let obj = self.pageObject  {
                        if let index = obj.getParamValue(key: .index) as? Int {
                            initFocus = index
                        }
                        if let id = obj.getParamValue(key: .id) as? String {
                            initFocusId = id
                        }
                    }
                    DispatchQueue.main.async {
                        self.isInit = true
                        if let block = self.block {
                            self.viewModel.update(
                                data: block, initFocus:initFocus, initFocusID:initFocusId, key: nil)
                        } else {
                            self.viewModel.update(
                                menuId:self.menuId, initFocus:initFocus, initFocusID:initFocusId, key:nil)
                        }
                    }
                }
            }
            .onAppear{
                self.safeAreaTop = self.sceneObserver.safeAreaTop
                guard let obj = self.pageObject  else { return }
                
                if let data = obj.getParamValue(key: .data) as? CateData {
                    self.logPageId = .scheduled
                    self.title = data.title
                    self.isClip = false
                    if let cateData = data.blocks?.filter({ $0.menu_id != nil }).first {
                        self.menuId = cateData.menu_id
                        return
                    }
                    return
                }
                
                self.isClip = true
                self.logPageId = .clipViewAll
                if let data = obj.getParamValue(key: .data) as? BlockData {
                    self.title = data.name
                    self.block = data
                    self.menuId = data.menuId
                } else {
                    self.menuId = obj.getParamValue(key: .id) as? String
                    
                }
                self.title = obj.getParamValue(key: .title) as? String ?? self.title
                
            }
            .onDisappear{
               
            }
        }//geo
    }//body
    
    @State var synopsisData:SynopsisData? = nil
    @State var playListData:PlayListData = PlayListData()
    @State var epsdId:String? = nil
    @State var isClip:Bool = false
    @State var isInitLog:Bool = true
    @State var logPageId:NaviLog.PageId = .empty
    @State var lastShow:String? = nil
    
    
    func onEventLog(streamEvent:PlayerStreamEvent){
        switch streamEvent {
        case .resumed:
            self.naviLogManager.contentsWatch(isPlay: true)
        case .stoped, .paused:
            self.naviLogManager.contentsWatch(isPlay: false)
        default: break
        }
    }
    
    private func sendLogPlayData(_ playData:PlayData){
        if self.viewModel.currentPlayData != playData {return}
        if self.lastShow == playData.epsdId {return}
        self.lastShow = playData.epsdId
        if playData.isClip {
            let content = MenuNaviContentsBodyItem(
                type: "clip",
                title: playData.fullTitle,
                episode_id: playData.epsdId,
                episode_resolution_id: playData.epsdRsluId)
            let action = MenuNaviActionBodyItem(
                menu_id: self.menuId,
                menu_name: self.title,
                category: playData.isAutoPlay == false ? "자동재생불가" : "자동재생",
                target: playData.subTitle)
            
            self.naviLogManager.actionLog(.pageShow, pageId: self.logPageId, actionBody: action, contentBody: content)
        }else {
            
            let content = MenuNaviContentsBodyItem(
                type: "vod",
                title: playData.title,
                genre_text:"",
                genre_code:"",
                episode_id: playData.epsdId,
                episode_resolution_id: playData.epsdRsluId,
                product_id: playData.prdId,
                purchase_type: playData.prdTypeCd
            )
            let action = MenuNaviActionBodyItem(
                result: playData.isAutoPlay == false ? "자동재생불가" : "자동재생")
            
            self.naviLogManager.actionLog(.pageShow, pageId: self.logPageId, actionBody: action, contentBody: content)
            
        }
    }
    
    private func sendLogPlay(evt:PlayerUIEvent, playData:PlayData? = nil){
        guard let playData = playData ?? self.viewModel.naviLogPlayData  else {return}
        if !playData.isClip {return} // 클립만
        if self.viewModel.currentPlayData != playData {return}
        var actionType:NaviLog.Action = .none
        switch evt {
        case .pause(let isUser) :
            if !isUser {return}
            actionType = .clickContentsPause
        case .resume(let isUser) :
            if !isUser {return}
            actionType = .clickContentsPlay
        case .togglePlay(let isUser) :
            if !isUser {return}
            actionType =  self.playerModel.playerStatus == .resume ? .clickContentsPause : .clickContentsPlay
        default: return
        }
        
        let content = MenuNaviContentsBodyItem(
            type: "clip",
            title: playData.fullTitle,
            episode_id: playData.epsdId,
            episode_resolution_id: playData.epsdRsluId
        )
        let action = MenuNaviActionBodyItem(
            menu_id: self.menuId,
            menu_name: self.title,
            target: playData.subTitle ?? "")
        
        self.naviLogManager.actionLog(actionType, pageId: self.logPageId, actionBody: action, contentBody: content)
    }
    
    private func sendLogEvent(evt:PlayBlockModel.LogEvent){
       
        switch evt {
        case .select(let playData) : self.sendLogEventSelect (playData:playData)
        case .play(let playData) :
            if playData.isClip { sendLogPlay(evt: .resume(isUser: true)) }
            else { sendLogEventPlay(playData:playData)}
        case .like : self.sendLogEventOption(evt:evt)
        case .alram : self.sendLogEventOption(evt:evt)
        }
    
    }
    
    private func sendLogEventSelect (playData:PlayData? = nil){
        guard let playData = playData ?? self.viewModel.naviLogPlayData  else {return}
        if playData.isClip {
            let content = MenuNaviContentsBodyItem(
                type: "clip",
                title: playData.fullTitle,
                episode_id: playData.epsdId,
                episode_resolution_id: playData.epsdRsluId)
            let action = MenuNaviActionBodyItem(
                menu_id: self.menuId,
                menu_name: self.title,
                position: (playData.index+1).description + "@" + self.infinityScrollModel.total.description,
                target: playData.subTitle
            )
            
            self.naviLogManager.actionLog(.clickClipStoryButton, pageId: self.logPageId, actionBody: action, contentBody: content)
        } else {
            
            let content = getPreviewLogContent (playData:playData)
            self.naviLogManager.actionLog(.clickClipStoryButton, pageId: self.logPageId, contentBody: content)
        }
    }
    
    
    // 공개예정 전용
    private func sendLogEventOption (evt:PlayBlockModel.LogEvent){
        var category:String? = nil
        var actionType:NaviLog.Action = .none
        var sendPlayData:PlayData? = nil
        switch evt {
        case .like(let playData, let isLike) :
            sendPlayData = playData
            if let like = isLike {
                category = like ? "like" : "dislike"
                actionType = .clickLikeSelection
            } else {
                actionType = .clickLikeSelectionCancel
            }
            
        case .alram(let playData, let isAlram) :
            sendPlayData = playData
            category = isAlram ? "alram" : "un-alarm"
            actionType = .clickMovieOption
        default : break
        }
        
        let content = getPreviewLogContent (playData:sendPlayData)
        let action = category != nil
            ? MenuNaviActionBodyItem(category : category)
            : nil
        self.naviLogManager.actionLog(actionType , pageId: self.logPageId, actionBody: action, contentBody: content)
    }
    
    
    
    private func sendLogEventPlay (playData:PlayData? = nil){
        let content = getPreviewLogContent (playData:playData)
        self.naviLogManager.actionLog(.clickScheduledMoviePlay, pageId: self.logPageId, contentBody: content)
    }
    
    private func getPreviewLogContent (playData:PlayData? = nil) -> MenuNaviContentsBodyItem? {
        guard let playData = playData ?? self.viewModel.naviLogPlayData  else {return nil}
        let content = MenuNaviContentsBodyItem(
            type: "vod",
            title: playData.title,
            genre_text: nil,
            genre_code: nil,
            paid: nil,
            purchase: nil,
            episode_id: playData.epsdId,
            episode_resolution_id: playData.epsdRsluId,
            cid: nil,
            product_id: playData.prdId,
            purchase_type: playData.prdTypeCd,
            monthly_pay: nil,
            list_price: nil,
            payment_price: nil)
        return content
    }
}


#if DEBUG
struct PagePreviewList_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePreviewList().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(AppSceneObserver())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

