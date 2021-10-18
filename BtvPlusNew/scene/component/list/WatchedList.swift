//
//  VideoList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import struct Kingfisher.KFImage
class WatchedData:InfinityData{
    private(set) var originImage: String? = nil
    private(set) var image: String? = nil
    private(set) var title: String? = nil
    private(set) var count: String? = nil
    private(set) var watchLv:Int = 0
    private(set) var isAdult:Bool = false
    private(set) var isLock:Bool = false
    private(set) var subTitle: String? = nil
    private(set) var isContinueWatch:Bool = false
    private(set) var progress:Float? = nil
    private(set) var synopsisData:SynopsisData? = nil
    private(set) var restrictAgeIcon: String? = nil
    private(set) var srisId:String? = nil
    private(set) var actionLog:MenuNaviActionBodyItem? = nil
    private(set) var contentLog:MenuNaviContentsBodyItem? = nil
    private(set) var originData:WatchItem? = nil
    
    
    func setData(data:WatchItem, idx:Int = -1, isAll:Bool) -> WatchedData {
        self.originData = data
        if let rt = data.watch_rt?.toInt() {
            self.progress = Float(rt) / 100.0
            self.subTitle = rt.description + "% " + String.app.watch
            self.isContinueWatch = MetvNetwork.isWatchCardRateIn(data: data, isAll:isAll)
        }
        watchLv = data.level?.toInt() ?? 0
        restrictAgeIcon = Asset.age.getListIcon(age: data.level)
        isAdult = data.adult?.toBool() ?? false
        isLock = !SystemEnvironment.isImageLock ? false : isAdult
        title = data.title
        if data.yn_series == "Y" {
            if data.series_no?.isEmpty == false , let count = data.series_no {
                self.count = count
                title = count + String.app.broCount + " " + (self.title ?? "")
            }
        }
        originImage = data.thumbnail
        image = ImagePath.thumbImagePath(filePath: data.thumbnail, size: ListItem.watched.size, isAdult:isAdult)
        
        index = idx
        srisId = data.sris_id
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.prd,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id,
            prdPrcId: "",  kidZone:nil, progress:self.progress, synopType: .none)
        
        return self
    }
    
    func setDummy(_ idx:Int = -1) -> WatchedData {
        title = "[Q&A] 이민?레나채널 삭제 안하는 이유?외국인남친?"
        subTitle = "subTitlesubTitlesubTitle"
        index = idx
        return self
    }
    
    fileprivate func updatedImage(){
        image = ImagePath.thumbImagePath(filePath: self.originImage, size: ListItem.watched.size, isAdult: self.isAdult)
    }
}


struct WatchedList: PageComponent{
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var naviLogManager:NaviLogManager
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[WatchedData]
    var watchedType:WatchedBlockType = .btv
    var deleteAble:Bool = true
    var useTracking:Bool = false
    var marginBottom:CGFloat = Dimen.margin.regular
    
    var delete: ((_ data:WatchedData) -> Void)? = nil
    var onBottom: ((_ data:WatchedData) -> Void)? = nil
    @State var horizontalMargin:CGFloat = Dimen.margin.thin
   
    var body: some View {
        ZStack(alignment:.center){
            if !self.datas.isEmpty {
                InfinityScrollView(
                    viewModel: self.viewModel,
                    axes: .vertical,
                    scrollType : .reload(isDragEnd:false),
                    header: self.watchedType == .kids
                        ? nil
                        : WatchedHeader(
                            type: self.watchedType,
                            horizontalMargin:self.horizontalMargin
                        ),
                    headerSize: self.watchedType == .btv
                        ? (Dimen.button.thinUltra + Dimen.margin.thin)
                        : (Dimen.button.thinUltra * 2 + Dimen.margin.tiny ),
                    marginTop: Dimen.margin.regular ,
                    marginBottom: self.marginBottom,
                    spacing:0,
                    isRecycle: true,
                    useTracking: self.useTracking
                ){
                    
                    ForEach(self.datas) { data in
                        WatchedItem( data:data ,
                                     watchedType: self.watchedType,
                                     delete:self.deleteAble ? self.delete : nil)
                            .modifier(ListRowInset(marginHorizontal:self.horizontalMargin ,spacing: Dimen.margin.tinyExtra))
                            .accessibility(label: Text(data.title ?? ""))
                            .onTapGesture {
                                guard let synopsisData = data.synopsisData else { return }
                                self.sendLogData(data)
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.synopsis)
                                        .addParam(key: .data, value: synopsisData)
                                        .addParam(key: .watchLv, value: data.watchLv)
                                )
                            }
                            .onAppear{
                                if data.index == self.datas.last?.index {
                                    self.onBottom?(data)
                                }
                            }
                    }
                    
                }
            } else {
                if self.watchedType == .kids {
                    EmptyMyKidsData()
                       
                } else {
                    VStack{
                        InfoAlert(
                            text: String.pageText.myWatchedInfo,
                            horizontalMargin: self.horizontalMargin)
                        
                        EmptyMyData(
                            text:String.pageText.myWatchedEmpty)
                            .modifier(MatchParent())
                    }
                    .padding(.top, Dimen.margin.regular)
                }
            }
           
            
        }
        .onReceive(self.sceneObserver.$isUpdated){ update in
            if !update {return}
            self.horizontalMargin
                = self.sceneObserver.sceneOrientation == .portrait ? Dimen.margin.thin : Dimen.margin.heavy
        }
        .onAppear{
            self.horizontalMargin
                = self.sceneObserver.sceneOrientation == .portrait ? Dimen.margin.thin : Dimen.margin.heavy
        }
    }//body
    
    
    private func sendLogData(_ data:WatchedData){
        let content = MenuNaviContentsBodyItem(
            type: "vod",
            title: data.title,
            genre_text: nil,
            genre_code: nil,
            paid: nil,
            purchase: nil,
            episode_id: data.originData?.epsd_id,
            episode_resolution_id: data.originData?.epsd_rslu_id,
        
            product_id: data.originData?.prod_id,
            purchase_type: nil,
            monthly_pay: nil,
            running_time: data.originData?.watch_time,
            list_price: nil,
            payment_price: nil)
        
        let action = MenuNaviActionBodyItem(category : self.watchedType.category)
        self.naviLogManager.actionLog(.clickRecentContentsList ,pageId: .recentContents,
                                      actionBody: action, contentBody: content)
    }
}
struct WatchedHeader: PageView{
    let type:WatchedBlockType
    var horizontalMargin:CGFloat = Dimen.margin.thin
    var body: some View {
        VStack(alignment:.leading , spacing:Dimen.margin.tiny){
            InfoAlert(
                text: String.pageText.myWatchedInfo,
                horizontalMargin: self.horizontalMargin)
            if self.type == .mobile {
                InfoAlert(
                    icon: Asset.icon.watchBTvListInfo,
                    text: String.pageText.myWatchedInfoBtv,
                    horizontalMargin: self.horizontalMargin)
            }
         }
    }
}


struct WatchedItem: PageView {
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var setup:Setup
    var data:WatchedData
    var watchedType:WatchedBlockType = .btv
    var delete: ((_ data:WatchedData) -> Void)? = nil
    var body: some View {
        HStack( spacing:Dimen.margin.light){
            ZStack{
                KFImage(URL(string: self.data.image ?? ""))
                    .resizable()
                    .placeholder {
                        Image(Asset.noImg16_9)
                            .resizable()
                    }
                    .cancelOnDisappear(true)
                    .aspectRatio(contentMode: .fill)
                    .modifier(MatchParent())
                
                if self.data.isLock {
                    Image(Asset.icon.itemRock)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:Dimen.icon.light, height: Dimen.icon.light)
                }else if self.data.progress != nil  {
                    /*
                    Image(Asset.icon.thumbPlay)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.regularExtra, height: Dimen.icon.regularExtra)
                    */
                }
                VStack(alignment: .leading, spacing:0){
                    HStack(spacing:0){
                        Spacer()
                        if let icon = data.restrictAgeIcon {
                            Image(icon)
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width:Dimen.icon.light, height: Dimen.icon.light)
                        }
                    }
                    Spacer().modifier(MatchParent())
                    if self.data.progress != nil {
                        Spacer().frame(
                            width: ListItem.watched.size.width * CGFloat(self.data.progress!),
                            height: Dimen.line.regular)
                            .background(Color.brand.primary)
                    }
                }
                
            }
            .frame(
                width: ListItem.watched.size.width,
                height: ListItem.watched.size.height)
            .clipped()
            VStack( alignment:.leading ,spacing:0){
                Spacer().modifier(MatchHorizontal(height: 0))
                if self.data.title != nil {
                    Text(self.data.title!)
                        .modifier(BoldTextStyle(size: Font.size.lightExtra))
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                }
                if self.data.subTitle != nil {
                    Text(self.data.subTitle!)
                        .modifier(MediumTextStyle(size: Font.size.tiny, color: Color.app.greyLight))
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                        .padding(.top, Dimen.margin.tinyExtra)
                }
            }
            .modifier(MatchParent())
            HStack(spacing:Dimen.margin.thin){
                if self.watchedType == .mobile {
                    Button(action: {
                        self.checkWatchBtv()
                    }) {
                        Image(Asset.icon.watchBTvList)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.tiny,
                                   height: Dimen.icon.tiny)
                            
                    }
                    Spacer().modifier(MatchVertical(width: 1))
                        .background(Color.app.white.opacity(0.1))
                        .frame(height: Dimen.icon.tiny)
                }
                if let del = self.delete {
                    Button(action: {
                        del(self.data)
                    }) {
                        Image(Asset.icon.deleteList)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.tiny,
                                   height: Dimen.icon.tiny)
                    }
                }
            }
        }
        .padding(.trailing, Dimen.margin.thin)
        .modifier(MatchHorizontal(height: ListItem.watched.size.height))
        .background(Color.app.blueLight)
        .onReceive(self.repository.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .updatedWatchLv : self.data.updatedImage()
            default : break
            }
        }
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else {return}
            if !res.id.hasPrefix(self.data.id) {return}
            switch res.type {
            case .getSynopsis :
                guard let data = res.data as? Synopsis else {return}
                self.checkWatchBtvAuth(synop: data)
            case .getDirectView :
                guard let data = res.data as? DirectView else {return}
                self.onWatchBtvAuth(data: data)
            case .sendMessage :
                guard let data = res.data as? ResultMessage else { return }
                self.watchBtvCompleted(isSuccess: data.header?.result == ApiCode.success)
            default : break
            }
        }
        .onReceive(self.dataProvider.$error){ err in
            guard let err = err else {return}
            if !err.id.hasPrefix(self.data.id) {return}
            switch err.type {
            case .getSynopsis, .getDirectView, .sendMessage :
                self.watchBtvCompleted(isSuccess: false)
            default : break
            }
        }
    }
    
    @State var synopsisModel:SynopsisModel? = nil
    @State var purchaseViewerData:PurchaseViewerData? = nil
    @State var purchaseWebviewModel:PurchaseWebviewModel? = nil
    private func checkWatchBtv(){
        if let purchaseViewerData = self.purchaseViewerData {
            self.watchBtv(purchaseViewerData: purchaseViewerData)
            return
        }
        
        guard let synop = data.synopsisData else {return}
        self.dataProvider.requestData( q: .init(id:self.data.id, type: .getSynopsis(synop), isOptional: true))
    }
    
    private func checkWatchBtvAuth(synop:Synopsis){
        let model = SynopsisModel(type: .seasonFirst).setData(data: synop)
        self.synopsisModel = model
        self.purchaseWebviewModel = PurchaseWebviewModel().setParam(synopsisData: synop)
        self.dataProvider.requestData( q: .init(id:self.data.id, type: .getDirectView(model), isOptional: true))
    }
    
    
    func onWatchBtvAuth(data:DirectView){
        guard let synopsisModel = self.synopsisModel else {return}
        synopsisModel.setData(directViewData: data)
        self.purchaseViewerData = PurchaseViewerData(type: .btv).setData(synopsisModel: synopsisModel, isPairing: true)
        self.purchaseWebviewModel?.setParam(directView: data, monthlyPid: self.synopsisModel?.salePPMItem?.prdPrcId)
        if let purchaseViewerData = self.purchaseViewerData {
            self.watchBtv(purchaseViewerData: purchaseViewerData)
        }
        
    }
    func watchBtv(purchaseViewerData:PurchaseViewerData){
        guard let synopsisModel = self.synopsisModel else {return}
       
        let playAble = purchaseViewerData.isPlayAble
        let playAbleBtv = purchaseViewerData.isPlayAbleBtv
        let hasAuthority = purchaseViewerData.hasAuthority
         
        if self.synopsisModel?.isDistProgram == false {
            self.appSceneObserver.alert = .alert(
                String.alert.purchaseDisable,
                String.alert.purchaseDisableService
            )
            return
        }
       
        if self.synopsisModel?.isCancelProgram == false{ //결방일경우 비티비로 보냄
            if !(!playAble && playAbleBtv) && !hasAuthority{
                //btv에서만 가능한 컨텐츠 권한없어도 비티로 보기 지원
                self.purchaseConfirm(msg: String.alert.purchaseContinueBtv)
                return
            }
        }
        let msg:NpsMessage = NpsMessage().setPlayVodMessage(
            contentId: synopsisModel.epsdRsluId ?? "" ,
            playTime: 0)
        self.dataProvider.requestData( q: .init(id:self.data.id, type: .sendMessage( msg), isOptional: true))
    }
    
    func watchBtvCompleted(isSuccess:Bool){
        if isSuccess {
            if self.setup.autoRemocon {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.remotecon)
                )
            }
            self.appSceneObserver.event = .toast(String.alert.btvplaySuccess)
        } else {
            self.appSceneObserver.event = .toast(String.alert.btvplayFail)
        }
    }
    func purchaseConfirm(msg:String? = nil){
        guard  let model = self.purchaseWebviewModel else { return }
        self.appSceneObserver.alert = .needPurchase(model, msg)
    }
}

struct EmptyMyKidsData: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    var icon:String = Asset.image.myEmpty3
    var text:String = String.pageText.myWatchedKids
    var body: some View {
        VStack(alignment: .center, spacing: 0){
            Image(icon)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Dimen.icon.heavyUltra, height: Dimen.icon.heavyUltra)
            Text(text)
                .modifier(BoldTextStyle(size: SystemEnvironment.isTablet ? Font.size.thin : Font.size.regular, color: Color.app.white))
                    .multilineTextAlignment(.center)
                    .padding(.top, Dimen.margin.mediumExtra)
            FillButton(
                text: String.pageText.myWatchedKidsButton,
                size: Dimen.button.regular
            ){ _ in
                
                self.pagePresenter.openPopup(
                    PageKidsProvider.getPageObject( .kidsMy, animationType: .opacity)
                        .addParam(key: .subId, value: PageKidsMy.recentlyWatchCode)
                       
                )
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding(.top, Dimen.margin.medium)
            .frame(width: Dimen.button.mediumHorizontal)
        }
        .padding(.all, Dimen.margin.medium)
        
    }//body
}


#if DEBUG
struct WatchedList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            WatchedList( datas: [
                WatchedData().setDummy(0),
                WatchedData().setDummy(),
                WatchedData().setDummy(),
                WatchedData().setDummy()
            ]){ _ in
                
            }
            .environmentObject(PagePresenter()).frame(width:320,height:600)
        }
    }
}
#endif

