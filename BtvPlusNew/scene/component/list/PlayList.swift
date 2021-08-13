//
//  VideoList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import struct Kingfisher.KFImage
class PlayData:InfinityData,ObservableObject{
    private(set) var image: String? = nil
    private(set) var title: String? = nil
    private(set) var watchLv:Int = 0
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
    private(set) var notificationData: NotificationData? = nil
    private(set) var notiType: String? = nil
    var playTime:Double = 0
    @Published private(set) var isUpdated: Bool = false
        {didSet{ if isUpdated { isUpdated = false} }}
    
    func setData(data:PreviewContentsItem,idx:Int = -1) -> PlayData {
        title = data.title
        srisId = data.sris_id
        summary = data.epsd_snss_cts
        epsdId = data.epsd_id
        epsdRsluId = data.epsd_rslu_id
        if let poster = data.poster_filename_h {
            image = ImagePath.thumbImagePath(filePath: poster, size: ListItem.play.size)
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
   
    func setDummy(_ idx:Int = -1) -> PlayData {
        title = "조커"
        date = "4월 10일 월정액 업데이트"
        summary = "‘내 인생이 비극인줄 알았는데, 코미디였어고담시의 광대 아서 플렉은 코미디언을 꿈꾸는 남자 하지만 모두가 미쳐가는 코미디 같은 세상에서 맨 정신으로는 그가 설 자리가 없음을 깨닫게 되는데 …"
        index = idx
        self.restrictAgeIcon = Asset.age.getIcon(age: "")
        return self
    }
    
}

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
                PlayItem(data: data)
            }
        }
        
    }//body
}

struct PlayItem: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var setup:Setup
    var pageObservable:PageObservable? = nil
    var playerModel: BtvPlayerModel? = nil
    var data:PlayData
    var isSelected:Bool = false
    @State var isPlay:Bool = false
    @State var sceneOrientation: SceneOrientation = .portrait

    var body: some View {
        ZStack{
            if self.sceneOrientation == .landscape {
                HStack(alignment: .center, spacing:0){
                    PlayItemScreen(
                        pageObservable : self.pageObservable,
                        playerModel : self.playerModel,
                        data: self.data,
                        isSelected : self.isSelected,
                        isPlay: self.$isPlay,
                        isError: self.$isError){
                        
                        self.loadPreview()
                    }
                    .frame(width: 520, height: 292)
                    .clipped()
                    VStack(alignment: .leading, spacing:0){
                        Text(self.data.title!)
                            .modifier(BoldTextStyle(
                                    size: Font.size.large,
                                    color: Color.app.white)
                            )
                            .lineLimit(1)
                        
                        PlayItemInfo(data: self.data)
                        HStack(spacing:Dimen.margin.thin){
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
                        pageObservable : self.pageObservable,
                        playerModel : self.playerModel,
                        data: self.data,
                        isSelected : self.isSelected,
                        isPlay: self.$isPlay,
                        isError: self.$isError){
                        
                        self.loadPreview()
                    }
                    .modifier(
                        Ratio16_9(
                            width: self.sceneObserver.screenSize.width,
                            horizontalEdges: Dimen.margin.thin
                        )
                    )
                    .clipped()
                    VStack(alignment: .leading, spacing:0){
                        HStack(spacing:Dimen.margin.thin){
                            if self.data.title != nil {
                                VStack(alignment: .leading, spacing:0){
                                    Text(self.data.title!)
                                        .modifier(BoldTextStyle(
                                                size: Font.size.large,
                                                color: Color.app.white)
                                        )
                                        .lineLimit(1)
                                    
                                    Spacer().modifier(MatchHorizontal(height: 0))
                                }
                                .modifier(MatchHorizontal(height: Font.size.large))
                            } else{
                                Spacer().modifier(MatchHorizontal(height: 1))
                            }
                            PlayItemFunction(
                                data: self.data,
                                isInit: self.isInit,
                                isLike: self.$isLike,
                                isAlram: self.$isAlram)
                        }
                        PlayItemInfo(data: self.data)
                    }
                    .padding(.top, SystemEnvironment.isTablet ? 0 : Dimen.margin.lightExtra)
                    .padding(.all, SystemEnvironment.isTablet ? Dimen.margin.thin : 0)
                }
            }
        }
        .background(SystemEnvironment.isTablet ? Color.app.blueLight : Color.transparent.clear)
        .opacity(self.isSelected ? 1.0 : 0.4)
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
            self.isError = true
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
            self.isPlay = self.setup.autoPlay
            self.isInit = true
        }
        .onDisappear{
            self.isInit = false
        }
    }
    
    @State var isInit:Bool = false
    @State var isLike:LikeStatus? = nil
    @State var isAlram:Bool? = nil
    @State var isError:Bool = false
     
    private func loadPreview(){
        guard let epsdRsluId = data.epsdRsluId else { return }
        self.playerModel?.currentIdx = self.data.index
        self.playerModel?.currentEpsdRsluId = self.data.epsdRsluId
        self.isError = false
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
            self.isError = true
            return
        }
        if data.result != ApiCode.success {
            PageLog.d("fail PreviewInfo", tag: self.tag)
            self.isError = true
            return
        }
        guard let dataInfo = data.CTS_INFO else {
            PageLog.d("error PreviewInfo", tag: self.tag)
            self.isError = true
            return
        }
        self.playerModel?.setData(data: dataInfo, type: .preview(epsdRsluId), autoPlay: true, continuousTime: self.data.playTime)
        

    }
}


struct PlayItemScreen: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var setup:Setup
    var pageObservable:PageObservable?
    var playerModel: BtvPlayerModel?
    var data:PlayData
    var isSelected:Bool
    
    @Binding var isPlay:Bool
    @Binding var isError:Bool
    var action:() -> Void
    var body: some View {
        ZStack{
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
            if self.data.isPlayAble {
                if self.isSelected {
                    Button(action: {
                        self.isPlay = true
                    }) {
                        Image(Asset.icon.thumbPlay)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.medium, height: Dimen.icon.medium)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                if self.isPlay && self.isSelected && self.playerModel != nil {
                    if !self.isError {
                        SimplePlayer(
                            pageObservable:self.pageObservable,
                            viewModel:self.playerModel!
                        )
                        .modifier(MatchParent())
                        .onAppear{
                            if self.pagePresenter.isFullScreen { return }
                            self.action()
                            self.pagePresenter.orientationLock(lockOrientation: .all)
                        }
                        .onDisappear{
                            self.isPlay = self.setup.autoPlay
                        }
                    } else {
                        Button(action: {
                            self.isError = false
                        }) {
                            Spacer().background(Color.transparent.black15).modifier(MatchParent())
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
        }
    }
}

struct PlayItemInfo: PageView {
    var data:PlayData
    var body: some View {
        HStack(spacing:Dimen.margin.thin){
            if self.data.date != nil {
                Text(self.data.date!)
                    .modifier(MediumTextStyle(
                            size: Font.size.lightExtra,
                            color: Color.brand.primary)
                    )
                    .lineLimit(1)
            }
            
            if self.data.provider != nil {
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
        .padding(.top, SystemEnvironment.isTablet ? Dimen.margin.thin : Dimen.margin.light)
        
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


#if DEBUG
struct PlayList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PlayList( datas: [
                PlayData().setDummy(0),
                PlayData().setDummy(),
                PlayData().setDummy(),
                PlayData().setDummy()
            ])
            .environmentObject(PagePresenter())
            .environmentObject(PageSceneObserver())
            .environmentObject(DataProvider())
            .environmentObject(Pairing())
            .environmentObject(AppSceneObserver())
            .frame(width:320,height:600)
            
        }
    }
}
#endif

