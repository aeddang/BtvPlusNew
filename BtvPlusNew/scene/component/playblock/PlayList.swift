//
//  VideoList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import Combine
import struct Kingfisher.KFImage
class PlayData:InfinityData,ObservableObject{
    private(set) var image: String? = nil
    private(set) var title: String? = nil
    
    private(set) var watchLv:Int = 0
    private(set) var isAdult:Bool = false
    
    private(set) var openDate: String? = nil
    private(set) var date: String? = nil
    private(set) var srisId: String? = nil
    private(set) var epsdId: String? = nil
    private(set) var prdId: String? = nil
    private(set) var prdTypeCd: String? = nil
    fileprivate(set) var epsdRsluId: String? = nil
    private(set) var summary: String? = nil
    var isLike:LikeStatus? = nil
    var isAlram:Bool = false
    private(set) var isPlayAble:Bool = false
    private(set) var restrictAgeIcon:String? = nil
    private(set) var provider: String? = nil
    private(set) var ppmIcon: String? = nil
    private(set) var notificationData: NotificationData? = nil
    private(set) var notiType: String? = nil
    private(set) var isCompleted:Bool = false
    
    private(set) var isClip:Bool = false
    private(set) var subTitle: String? = nil
    private(set) var count: String? = nil
    private(set) var synopsisType:SynopsisType = .title
    private(set) var synopsisData:SynopsisData? = nil
    fileprivate(set) var synopsisModel:SynopsisModel? = nil
    fileprivate(set) var playListData:PlayListData? = nil
    fileprivate(set) var episodeViewerData:EpisodeViewerData? = nil
    fileprivate(set) var isAutoPlay:Bool = false
    
    fileprivate(set) var playRespond:ApiResultResponds? = nil
    fileprivate(set) var playData:Play? = nil
    var playTime:Double = 0
    @Published private(set) var isUpdated: Bool = false
        {didSet{ if isUpdated { isUpdated = false} }}
    
    func completed(){
        self.isCompleted = true
        self.playTime = 0
    }
    func reset(){
        self.playTime = 0
        self.isCompleted = false
    }
    
    func setData(data:PreviewContentsItem,idx:Int = -1) -> PlayData {
        title = data.title
        srisId = data.sris_id
        summary = data.epsd_snss_cts
        epsdId = data.epsd_id
        epsdRsluId = data.epsd_rslu_id
        prdId = data.prd_id
        prdTypeCd = data.prd_typ_cd
        watchLv = data.wat_lvl_cd?.toInt() ?? 0
        isAdult = data.adlt_lvl_cd?.toBool() ?? false
        if isAdult { watchLv = Setup.WatchLv.lv4.rawValue }
        restrictAgeIcon = Asset.age.getListIcon(age: data.wat_lvl_cd) 
        if let poster = data.poster_filename_h {
            image = ImagePath.thumbImagePath(filePath: poster, size: ListItem.play.size)
        }
        if data.ppm_grid_icon_img_path?.isEmpty == false, let icon = data.ppm_grid_icon_img_path {
            self.ppmIcon = ImagePath.thumbImagePath(filePath: icon,
                                               size:CGSize(width: 0, height: Dimen.icon.light),
                                               convType: .alpha)
       
        }
        index = idx
        let ppm: Bool = ("30" == data.prd_typ_cd || "34" == data.prd_typ_cd )
        if let release = data.release_dt?.subString(start: 0, len: 8) {
            if let date = release.toDate(dateFormat: "yyyyMMdd") {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "M" + String.app.month + "d" + String.app.day
                //OR dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"
                let currentDateString: String = dateFormatter.string(from: date)
                let weekday = date.getWeekday()
                self.openDate = currentDateString
                self.date = currentDateString
                    + " " + String.week.getDayString(day: weekday)
                    + " " + ( ppm ? String.app.ppmUpdate : String.app.open)
            }
        }
        isPlayAble = self.epsdRsluId != nil && self.epsdRsluId != ""
        
        if ("30" == data.prd_typ_cd || "34" == data.prd_typ_cd) && 0 < (data.prd_id?.count ?? 0) {
            notiType = NfNetwork.NotiType.product.rawValue
        } else if "02" == data.synon_typ_cd {
            notiType = NfNetwork.NotiType.season.rawValue
        } else {
            notiType = NfNetwork.NotiType.movie.rawValue
        }
        self.notificationData = NotificationData(
            srisId: self.srisId,
            epsdId: self.epsdId,
            type: self.notiType,
            epsdRsluId: self.epsdRsluId,
            prdId:data.prd_id,
            contentsNm: self.title)
        
        return self
    }
    
    func setData(data:ContentItem, idx:Int = -1) -> PlayData {
        isClip = true
        count = data.brcast_tseq_nm
    
        title = data.title
        subTitle = data.title
        image = ImagePath.thumbImagePath(filePath: data.poster_filename_h, size: ListItem.video.size, isAdult: self.isAdult)
        watchLv = data.wat_lvl_cd?.toInt() ?? 0
        isAdult = EuxpNetwork.adultCodes.contains(data.adlt_lvl_cd)
        index = idx
        epsdId = data.epsd_id
        //epsdRsluId = data.epsd_rslu_id
        srisId = data.sris_id
        synopsisType = SynopsisType(value: data.synon_typ_cd)
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.prd,
            epsdId: data.epsd_id, epsdRsluId: "", prdPrcId: data.prd_prc_id,
            kidZone:data.kids_yn, synopType: synopsisType)
        return self
    }
    
    func setData(data:VideoData, idx:Int = -1) -> PlayData {
        isClip = true
        count = data.count
        title = data.title
        subTitle = data.title
        index = idx
        epsdId = data.epsdId
        watchLv = data.watchLv
        image = data.image
        synopsisType =  data.synopsisType
        synopsisData = data.synopsisData
        return self
    }
    
    @discardableResult
    func setData(data:NotificationVodItem?) -> PlayData {
        if let noti = data {
            self.isAlram = true
            self.notiType = noti.noti_type
        } else{
            self.isAlram = false
        }
        if let nm = data?.contents_nm {
            self.notificationData?.contentsNm = nm
        }
        self.isUpdated = true
        return self
    }
    
    var fullTitle:String {
        get{
            guard let title = self.title else {return ""}
            if let count = self.count {
                if count.isEmpty {return title}
                return count + String.app.broCount + " " + title
            } else {
                return title
            }
        }
    }
   
    
}
/*
struct PlayList: PageComponent{
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[PlayData]
    var useTracking:Bool = false
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .vertical,
            marginVertical: 0,
            marginHorizontal: Dimen.margin.thin,
            spacing: SystemEnvironment.isTablet ? Dimen.margin.thin :  Dimen.margin.medium,
            isRecycle: true,
            useTracking: self.useTracking
        ){
            ForEach(self.datas) { data in
                PlayItem(
                    pageObservable: PageObservable(),
                    playerModel : BtvPlayerModel(),
                    data: data)
            }
        }
        
    }//body
}*/

extension PlayItem{
    static let listSize: CGSize = CGSize(width: 520, height: 292)
    static let bottomSize: CGFloat = SystemEnvironment.isTablet ? 199 : 146
    static let bottomSizeClip: CGFloat = SystemEnvironment.isTablet ? 140 : 102
    static func getListRange(width:CGFloat, sceneOrientation :SceneOrientation, isClip:Bool)->CGFloat{
        if SystemEnvironment.isTablet && sceneOrientation == .landscape {
            return listSize.height
        }
        return (width * 9 / 16) + (isClip ? self.bottomSizeClip : self.bottomSize)
    }
}


struct PlayItem: PageView {
    
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var setup:Setup
    @ObservedObject var pageObservable:PageObservable
    @ObservedObject var playerModel: BtvPlayerModel
    @ObservedObject var viewModel:PlayBlockModel
   
    var data:PlayData
    var range:CGFloat = 0
    var onPlay:(PlayData)->Void
    @State var isSelected:Bool = false
    @State var isForcePlay:Bool = false
    @State var isPlay:Bool = false
    @State var sceneOrientation: SceneOrientation = .portrait
    
    
    var body: some View {
        ZStack{
            if self.sceneOrientation == .landscape {
                HStack(alignment: .center, spacing:0){
                    PlayItemScreen(
                        pageObservable: self.pageObservable,
                        playerModel : self.playerModel,
                        data: self.data,
                        isSelected : self.isSelected,
                        isPlay : self.isPlay,
                        isLoading: self.isLoading,
                        action:{
                            //self.isForcePlay = true
                            self.onPlay(self.data)
                        })
                    .frame(width: Self.listSize.width, height: Self.listSize.height)
                    .clipped()
                    VStack(alignment: .leading, spacing:0){
                        if !self.data.isClip , let title = self.data.title {
                            Text(title)
                                .modifier(BoldTextStyle(
                                        size: Font.size.large,
                                        color: Color.app.white)
                                )
                                .lineLimit(1)
                        }
                        PlayItemInfo(data: self.data)
                        if !self.data.isClip {
                            HStack(spacing:SystemEnvironment.isTablet ? Dimen.margin.tiny : Dimen.margin.thin){
                                PlayItemFunction(
                                    viewModel: self.viewModel,
                                    data: self.data,
                                    isInit: self.isInit,
                                    isLike: self.$isLike,
                                    isAlram: self.$isAlram)
                            }
                            .padding(.top, Dimen.margin.light)
                        }
                    }
                    .padding(.all, Dimen.margin.thin)
                    .modifier(MatchParent())
                }
            } else {
                
                VStack(alignment: .leading, spacing:0){
                    PlayItemScreen(
                        pageObservable: self.pageObservable,
                        playerModel : self.playerModel,
                        data: self.data,
                        isSelected : self.isSelected,
                        isPlay : self.isPlay,
                        isLoading: self.isLoading,
                        action:{
                            //self.isForcePlay = true
                            self.onPlay(self.data)
                        })
                    .modifier(
                        Ratio16_9(
                            width: self.sceneObserver.screenSize.width,
                            horizontalEdges: Dimen.margin.thin
                        )
                    )
                    .clipped()
                    HStack(alignment: .top, spacing:0){
                        Spacer().modifier(MatchVertical(width: 0))
                        VStack(alignment: .leading, spacing:0){
                            if !self.data.isClip {
                                HStack(spacing:SystemEnvironment.isTablet ? Dimen.margin.tiny : Dimen.margin.thin){
                                    if let title = self.data.title {
                                        VStack(alignment: .leading, spacing:0){
                                            Text(title)
                                                .modifier(BoldTextStyle(
                                                        size: Font.size.large,
                                                        color: Color.app.white)
                                                )
                                                .lineLimit(1)
                                            
                                            Spacer().modifier(MatchHorizontal(height: 0))
                                        }
                                        .modifier(MatchHorizontal(height: Font.size.large))
                                    } else{
                                        Spacer().modifier(MatchHorizontal(height: 0))
                                    }
                                    PlayItemFunction(
                                        viewModel: self.viewModel,
                                        data: self.data,
                                        isInit: self.isInit,
                                        isLike: self.$isLike,
                                        isAlram: self.$isAlram)
                                }
                            }
                            PlayItemInfo(data: self.data)
                        }
                    }
                    .padding(.top, (SystemEnvironment.isTablet || self.data.isClip) ? 0 : Dimen.margin.lightExtra)
                    .padding(.all, (SystemEnvironment.isTablet || self.data.isClip) ? Dimen.margin.thin : 0)
                    .frame(height:self.data.isClip ? Self.bottomSizeClip : Self.bottomSize)
                }
            }
        }
        .background((SystemEnvironment.isTablet || self.data.isClip) ? Color.app.blueLight : Color.transparent.clear)
        .opacity(self.isSelected ? 1.0 : 0.5)
        
        .onReceive(self.viewModel.$currentPlayData){ selectData in
            guard let selectData = selectData else {
                self.isSelected = false
                return
            }
            let isSelect = selectData == self.data
            if self.isSelected == isSelect { return }
            withAnimation{
                self.isSelected = isSelect
            }
            let isAuto = !data.isCompleted && isSelect
            if isAuto {
                if self.isForcePlay {
                    self.isPlay = true
                    self.isForcePlay = false
                } else {
                    self.isPlay = self.setup.autoPlay
                }
                PageLog.d("currentPlayData autoLoad " + self.isPlay.description, tag: self.tag)
                PageLog.d("currentPlayData autoLoad " + (selectData.title ?? ""), tag: self.tag)
                self.autoLoad()
            } else {
                PageLog.d("currentPlayData cancelAutoLoad " + (selectData.title ?? ""), tag: self.tag)
                self.playerModel.event = .pause()
                self.isPlay = false
                self.isLoading = false
                self.cancelAutoLoad()
            }
        }
        .onReceive(self.viewModel.$isPlayStatusUpdate){ update in
            if self.isSelected && update {
                self.isPlay = true
                self.load()
            }
        }
        .onReceive(self.playerModel.$error){err in
            if !self.isSelected {return}
            switch err {
            case .illegalState :
                break
            default :
                PageLog.d("error " + (self.data.title ?? ""), tag: self.tag)
                self.data.playRespond = nil
                self.data.playData = nil
                break
            }
        }
        .onReceive(self.playerModel.$event){evt in
            if !self.isSelected {return}
            guard let evt = evt else {return}
            switch evt {
            case .recovery(let isUser) :
                if isUser {
                    self.isPlay = true
                    self.load()
                }
            default : break
            }
        }
        
        .onReceive(self.playerModel.$streamStatus){stat in
            if !self.isSelected {return}
            switch stat {
            case .playing :
                self.isPlay = true
                withAnimation{ self.isLoading = false }
            case .stop :
                self.isPlay = false
            default : break
            }
        }
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            if !self.isSelected {return}
            if !res.id.hasPrefix( data.id) { return }
            self.loaded(res: res)
        }
        .onReceive(self.dataProvider.$error){ err in
            guard let err = err else { return }
            if !self.isSelected {return}
            if !err.id.hasPrefix(data.id) { return }
        }
        .onReceive(self.data.$isUpdated){ updated in
            if updated {
                self.isAlram = self.data.isAlram
            }
        }
        .onReceive(self.sceneObserver.$isUpdated){ _ in
            self.sceneOrientation = self.sceneObserver.sceneOrientation
        }
        .onAppear{
            self.sceneOrientation = self.sceneObserver.sceneOrientation
            self.isLike = self.data.isLike
            self.isAlram = self.data.isAlram
            self.isInit = true
        }
        .onDisappear{
            self.isInit = false
            self.cancelAutoLoad()
        }
    }
    @State var isLoading:Bool = false
    @State var isInit:Bool = false
    @State var isLike:LikeStatus? = nil
    @State var isAlram:Bool? = nil
    

    private func load(){
        if !self.isSelected { return }
        withAnimation{ self.isLoading = true }
        if self.data.isClip {
            self.loadClip()
        } else {
            self.loadPreview()
        }
    }
    private func loaded(res:ApiResultResponds){
        if self.data.isClip {
            self.setupClip(res: res)
        } else {
            self.setupPreview(res: res)
        }
    }
    
    
    private func loadPreview(){
        guard let epsdRsluId = data.epsdRsluId else { return }
        //self.playerModel.currentIdx = self.data.index
        //self.playerModel.currentEpsdRsluId = self.data.epsdRsluId
        if let res = self.data.playRespond {
            setupPreview(res:res)
        } else {
            if pairing.status == .pairing {
                dataProvider.requestData(q: .init(id:data.id, type: .getPreview(epsdRsluId, self.pairing.hostDevice)))
            }
            else {
                dataProvider.requestData(q: .init(id:data.id, type: .getPreplay(epsdRsluId, false)))
            }
        }
        
        
    }
    
    
    private func setupPreview(res:ApiResultResponds){
        guard let epsdRsluId = data.epsdRsluId else {
            PageLog.d("error epsdRsluId", tag: self.tag)
            self.isPlay = false
            return
        }
        guard let data = res.data as? Preview else {
            PageLog.d("error Preview", tag: self.tag)
            self.isPlay = false
            return
        }
        if data.result != ApiCode.success {
            PageLog.d("fail PreviewInfo", tag: self.tag)
            self.isPlay = false
            return
        }
        guard let dataInfo = data.CTS_INFO else {
            PageLog.d("error PreviewInfo", tag: self.tag)
            self.isPlay = false
            return
        }
        
        let watchLv = self.data.watchLv
        if watchLv >= 19 {
            if self.pairing.status != .pairing {
                self.isPlay = false
            }
            if !SystemEnvironment.isAdultAuth {
                self.isPlay = false
            }
        }
        if !SystemEnvironment.isAdultAuth ||
            ( !SystemEnvironment.isWatchAuth && SystemEnvironment.watchLv != 0 )
        {
            if SystemEnvironment.watchLv != 0 && SystemEnvironment.watchLv <= watchLv {
                self.isPlay = false
            }
        }
        
        self.data.isAutoPlay = self.isPlay
        self.viewModel.naviLogPlayData = self.data
        self.data.playRespond = res
        PageLog.d("load Preview", tag: self.tag)
        if !self.isPlay {
            withAnimation{ self.isLoading = false }
        }
        
        DispatchQueue.main.async {
            self.playerModel.setData(data: dataInfo,
                                     type: .preview(epsdRsluId, isList:true),
                                     autoPlay: self.isPlay,
                                     continuousTime: self.data.playTime)
        }
        
    }
    
    
    private func loadClip(){
        guard let synop = data.synopsisData else {
            self.isPlay = false
            return
        }
        if data.synopsisModel == nil {
            dataProvider.requestData(q: .init(id:data.id, type: .getSynopsis(synop)))
        } else {
            loadClipPlay()
        }
    }
    
    private func loadClipPlay(){
        guard let epsdRsluId = data.epsdRsluId else {
            self.isPlay = false
            return
        }
        if let data = self.data.playData {
            setupPlay(data)
        } else {
            dataProvider.requestData(q: .init(id:data.id, type: .getPlay(epsdRsluId)))
        }
       
    }
    
    private func setupClip(res:ApiResultResponds){
        switch res.type {
        case .getSynopsis:
            guard let data = res.data as? Synopsis else { return }
            self.setupSynopsis(data)
            loadClipPlay()
        case .getPlay:
            guard let data = res.data as? Play else { return }
            self.setupPlay(data)
        default: break
        }
    }
    
    private func setupSynopsis (_ data:Synopsis) {
        let model = SynopsisModel(type: .seasonFirst).setData(data: data)
        self.data.synopsisModel = model
        self.data.epsdRsluId = model.epsdRsluId
        if let content = data.contents {
            self.data.episodeViewerData = EpisodeViewerData().setData(data: content )
        }
    }
    
    private func setupPlay (_ data:Play){
        if data.result != ApiCode.success {
            PageLog.d("fail Play", tag: self.tag)
            self.isPlay = false
            return
        }
        guard let dataInfo = data.CTS_INFO else {
            PageLog.d("error PlayInfo", tag: self.tag)
            self.isPlay = false
            return
        }
        if let synopsis = self.data.synopsisModel {
            guard let epsdId = synopsis.epsdId else {
                PageLog.d("error epsdId", tag: self.tag)
                self.isPlay = false
                return
            }
            guard let epsdRsluId = synopsis.epsdRsluId else {
                PageLog.d("error epsdRsluId", tag: self.tag)
                self.isPlay = false
                return
            }
            var synopsisPlayType:SynopsisPlayType = .unknown
            if synopsis.originEpsdId?.isEmpty == false, let fullVod = synopsis.originEpsdId {
                synopsisPlayType = .clip(nil, SynopsisData(
                    srisId: self.data.synopsisData?.srisId,
                    searchType: .prd,
                    epsdId: fullVod,
                    synopType: self.data.synopsisData?.synopType ?? .none
                ))
            } else {
                synopsisPlayType = .clip()
            }
           
            var playerData:SynopsisPlayerData? = nil
            self.data.playData = data
            if let infoList = synopsis.seriesInfoList {
                let playList = zip(infoList, 0...infoList.count).map{ data, idx in
                    PlayerListData().setData(data: data, isClip: true, idx: idx)}
                
                let playListData = PlayListData(
                    listTitle: String.pageText.synopsisClipView,
                    datas: playList)
                self.data.playListData = playListData
                playerData = SynopsisPlayerData()
                    .setData(type: synopsisPlayType , datas: playListData.datas, epsdId:epsdId)
            }
            
            if self.pairing.status != .pairing && self.data.isClip {
                self.isPlay = false
            }
            let watchLv = self.data.watchLv
            if watchLv >= 19 {
                if self.pairing.status != .pairing {
                    self.isPlay = false
                }
                if !SystemEnvironment.isAdultAuth {
                    self.isPlay = false
                }
            }
            if !SystemEnvironment.isAdultAuth ||
                ( !SystemEnvironment.isWatchAuth && SystemEnvironment.watchLv != 0 )
            {
                if SystemEnvironment.watchLv != 0 && SystemEnvironment.watchLv <= watchLv {
                    self.isPlay = false
                }
            }
            self.data.isAutoPlay = self.isPlay
            self.viewModel.naviLogPlayData = self.data
            if !self.isPlay {
                withAnimation{ self.isLoading = false }
            }
            
            DispatchQueue.main.async {
                self.playerModel
                    .setData(synopsisPlayData: playerData)
                    .setData(data: dataInfo,
                             type: .vod(epsdRsluId,self.data.episodeViewerData?.episodeSubTitle),
                             autoPlay: self.isPlay,
                             continuousTime: self.data.playTime)
            }
        } else {
            PageLog.d("error synopsisModel", tag: self.tag)
            self.isPlay = false
        }
        
    }
    
    
    
    @State private var autoPlayer:AnyCancellable?
    private func autoLoad(){
        
        self.autoPlayer?.cancel()
        self.autoPlayer = Timer.publish(
            every: 0.5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.cancelAutoLoad()
                self.load()
            }
    }
    private func cancelAutoLoad(){
        self.autoPlayer?.cancel()
        self.autoPlayer = nil
    }
}






