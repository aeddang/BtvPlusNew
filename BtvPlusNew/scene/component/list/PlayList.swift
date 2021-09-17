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
    private(set) var epsdRsluId: String? = nil
    private(set) var summary: String? = nil
    fileprivate(set) var isLike:LikeStatus? = nil
    fileprivate(set) var isAlram:Bool = false
    private(set) var isPlayAble:Bool = false
    private(set) var restrictAgeIcon:String? = nil
    private(set) var provider: String? = nil
    private(set) var ppmIcon: String? = nil
    private(set) var notificationData: NotificationData? = nil
    private(set) var notiType: String? = nil
    private(set) var isCompleted:Bool = false
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
    static func getListRange(width:CGFloat, sceneOrientation :SceneOrientation)->CGFloat{
        if SystemEnvironment.isTablet && sceneOrientation == .landscape {
            return listSize.height
        }
        return (width * 9 / 16) + self.bottomSize
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
    @State var isPlay:Bool = false
    @State var isRecovery:Bool = false
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
                        isRecovery: self.isRecovery,
                        isPlay : self.isPlay,
                        isLoading: self.isLoading,
                        action:{
                            self.onPlay(self.data)
                        })
                    .frame(width: Self.listSize.width, height: Self.listSize.height)
                    .clipped()
                    VStack(alignment: .leading, spacing:0){
                        if let title = self.data.title {
                            Text(title)
                                .modifier(BoldTextStyle(
                                        size: Font.size.large,
                                        color: Color.app.white)
                                )
                                .lineLimit(1)
                        }
                        PlayItemInfo(data: self.data)
                        HStack(spacing:SystemEnvironment.isTablet ? Dimen.margin.tiny : Dimen.margin.thin){
                            PlayItemFunction(
                                data: self.data,
                                isInit: self.isInit,
                                isLike: self.$isLike,
                                isAlram: self.$isAlram)
                        }
                        .padding(.top, Dimen.margin.light)
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
                        isRecovery: self.isRecovery,
                        isPlay : self.isPlay,
                        isLoading: self.isLoading,
                        action:{
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
                                    data: self.data,
                                    isInit: self.isInit,
                                    isLike: self.$isLike,
                                    isAlram: self.$isAlram)
                            }
                            PlayItemInfo(data: self.data)
                        }
                    }
                    .padding(.top, SystemEnvironment.isTablet ? 0 : Dimen.margin.lightExtra)
                    .padding(.all, SystemEnvironment.isTablet ? Dimen.margin.thin : 0)
                    .frame(height:Self.bottomSize)
                }
            }
        }
        
        .background(SystemEnvironment.isTablet ? Color.app.blueLight : Color.transparent.clear)
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
            let isAuto = !data.isCompleted && self.setup.autoPlay && isSelect
            if isAuto {
                PageLog.d("currentPlayData autoLoad " + (selectData.title ?? ""), tag: self.tag)
                self.autoLoad()
            } else {
                PageLog.d("currentPlayData cancelAutoLoad " + (selectData.title ?? ""), tag: self.tag)
                self.playerModel.event = .pause
                self.isPlay = false
                self.isLoading = false
                self.isRecovery = false
                self.cancelAutoLoad()
            }
        }
        .onReceive(self.viewModel.$isPlayStatusUpdate){ update in
            if self.isSelected && update {
                self.load()
            }
        }
        
        .onReceive(self.playerModel.$streamEvent){stat in
            if !self.isSelected {return}
            switch stat {
            case .recovery :
                PageLog.d("recovery " + (self.data.title ?? ""), tag: self.tag)
                self.isRecovery = true
                self.autoLoad()
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
            guard let epsdRsluId = data.epsdRsluId else { return }
            if !res.id.hasPrefix(epsdRsluId) { return }
            self.setupPreview(res: res)
        }
        .onReceive(self.dataProvider.$error){ err in
            guard let err = err else { return }
            if !self.isSelected {return}
            guard let epsdRsluId = data.epsdRsluId else { return }
            if !err.id.hasPrefix(epsdRsluId) { return }
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
        self.isRecovery = false
        if !self.isSelected { return }
        guard let epsdRsluId = data.epsdRsluId else { return }
        let watchLv = self.data.watchLv
        if watchLv >= 19 {
            if self.pairing.status != .pairing {
                self.isPlay = false
                return
            }
            if !SystemEnvironment.isAdultAuth {
                self.isPlay = false
                return
            }
        }
        if !SystemEnvironment.isAdultAuth ||
            ( !SystemEnvironment.isWatchAuth && SystemEnvironment.watchLv != 0 )
        {
            if SystemEnvironment.watchLv != 0 && SystemEnvironment.watchLv <= watchLv {
                self.isPlay = false
                return
            }
        }
        withAnimation{ self.isLoading = true }
        self.playerModel.currentIdx = self.data.index
        self.playerModel.currentEpsdRsluId = self.data.epsdRsluId
        if pairing.status == .pairing {
            dataProvider.requestData(q: .init(id:epsdRsluId, type: .getPreview(epsdRsluId, self.pairing.hostDevice)))
        }
        else {
            dataProvider.requestData(q: .init(id:epsdRsluId, type: .getPreplay(epsdRsluId, false)))
        }
    }
    
    private func setupPreview(res:ApiResultResponds){
        guard let epsdRsluId = data.epsdRsluId else { return }
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
        PageLog.d("load Preview", tag: self.tag)
        DispatchQueue.main.async {
            self.playerModel.setData(data: dataInfo,
                                     type: .preview(epsdRsluId, isList:true),
                                     autoPlay: true,
                                     continuousTime: self.data.playTime)
        }
       
    }
    
    
    @State private var autoPlayer:AnyCancellable?
    private func autoLoad(){
        self.isPlay = false
        self.autoPlayer?.cancel()
        self.autoPlayer = Timer.publish(
            every: self.isRecovery ? 1.0 : 0.5, on: .current, in: .common)
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


struct PlayItemScreen: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var setup:Setup
    @ObservedObject var pageObservable:PageObservable 
    @ObservedObject var playerModel: BtvPlayerModel
    var data:PlayData
    var isSelected:Bool
    var isRecovery:Bool
    var isPlay:Bool = false
    var isLoading:Bool = false
    var action:()->Void
    
    var body: some View {
        ZStack{
            if self.isSelected && !self.isRecovery{
                SimplePlayer(
                    pageObservable:self.pageObservable,
                    viewModel:self.playerModel
                )
                .modifier(MatchParent())
                
            }
            if !self.isPlay || !self.isSelected || self.isLoading || self.isRecovery {
                if self.data.image == nil {
                    Image(Asset.noImg16_9)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .modifier(MatchParent())
                } else {
                    KFImage(URL(string: self.data.image!))
                        .resizable()
                        .placeholder {
                            Image(Asset.noImg16_9)
                                .resizable()
                        }
                        .cancelOnDisappear(true)
                        .loadImmediately()
                        .aspectRatio(contentMode: .fill)
                        .modifier(MatchParent())
                }
                
                if (self.isLoading || self.isRecovery) && self.isSelected{
                    CircularSpinner(resorce: Asset.ani.loading)
                } else {
                    Button(action: {
                        self.data.reset()
                        self.action()
                    }) {
                        Image(Asset.icon.thumbPlay)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.heavyExtra, height: Dimen.icon.heavyExtra)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            
        }
    }
}

struct PlayItemInfo: PageView {
    var data:PlayData
    var body: some View {
        HStack(spacing: SystemEnvironment.isTablet ? Dimen.margin.tiny : Dimen.margin.thin){
            if self.data.date != nil {
                Text(self.data.date!)
                    .modifier(MediumTextStyle(
                            size: Font.size.lightExtra,
                            color: Color.brand.primary)
                    )
                    .lineLimit(1)
            }
            if let icon = data.ppmIcon {
                KFImage(URL(string: icon))
                    .resizable()
                    .cancelOnDisappear(true)
                    .loadImmediately()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: Dimen.icon.tinyUltra)
                
            }else if self.data.provider != nil {
                Text(self.data.provider!)
                    .modifier(BoldTextStyle(
                            size: Font.size.lightExtra,
                                color: Color.app.white)
                    )
                    .lineLimit(1)
            }
            if self.data.restrictAgeIcon != nil {
                Image( self.data.restrictAgeIcon! )
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
            }
            
        }
        .padding(.top, SystemEnvironment.isTablet ? Dimen.margin.tiny : Dimen.margin.light)
        
        if self.data.summary != nil  {
            Text(self.data.summary!)
                .modifier(MediumTextStyle(size: Font.size.thin, color: Color.app.greyMedium))
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .padding(.top, Dimen.margin.thin)
        }
    }
}

struct PlayItemFunction: PageView {
    var data:PlayData
    var isInit:Bool
    @Binding var isLike:LikeStatus?
    @Binding var isAlram:Bool?
  
    var body: some View {
        if self.data.srisId != nil && self.isInit {
            LikeButton(srisId: self.data.srisId!, isLike: self.$isLike, useText:false, isThin:true){ value in
                self.data.isLike = value
            }
            .buttonStyle(BorderlessButtonStyle())
            if self.data.notificationData != nil {
                AlramButton(data: self.data.notificationData!, isAlram: self.$isAlram){ value in
                    self.data.isAlram = value
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
    }
}



