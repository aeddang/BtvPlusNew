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
    var hasLog:Bool {
        get{
            return actionLog != nil || contentLog != nil
        }
    }
    
    func setNaviLog(data:WatchItem? = nil) -> WatchedData  {
        self.actionLog = .init(category:"모바일btv")
        self.contentLog = MenuNaviContentsBodyItem(
            type: "vod",
            title: self.title,
            channel_name: nil,
            genre_text: nil,
            genre_code: nil,
            paid: nil,
            purchase: nil,
            episode_id: self.synopsisData?.epsdId,
            episode_resolution_id: self.synopsisData?.epsdRsluId,
            product_id: nil,
            purchase_type: nil,
            monthly_pay: nil,
            running_time: data?.watch_time,
            list_price: nil
            
        )
        return self
    }
    func setData(data:WatchItem, idx:Int = -1, isAll:Bool) -> WatchedData {
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
            prdPrcId: "",  kidZone:nil, progress:self.progress)
        
        return self.setNaviLog(data: data)
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
                        : InfoAlert(
                            text: String.pageText.myWatchedInfo,
                            horizontalMargin: self.horizontalMargin
                    ),
                    headerSize: Dimen.button.thinUltra + Dimen.margin.thin,
                    marginTop: Dimen.margin.regular ,
                    marginBottom: self.marginBottom,
                    spacing:0,
                    isRecycle: true,
                    useTracking: self.useTracking
                ){
                    
                    ForEach(self.datas) { data in
                        WatchedItem( data:data , delete:self.delete)
                            .modifier(ListRowInset(marginHorizontal:self.horizontalMargin ,spacing: Dimen.margin.tinyExtra))
                            .onTapGesture {
                                guard let synopsisData = data.synopsisData else { return }
                                
                                if data.hasLog {
                                    self.naviLogManager.actionLog(.clickRecentContentsList, actionBody: data.actionLog, contentBody: data.contentLog)
                                }
                                
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
                    EmptyMyData(
                        text:String.pageText.myWatchedEmpty)
                        
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
    
    
}

struct WatchedItem: PageView {
    @EnvironmentObject var repository:Repository
    var data:WatchedData
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
            if let del = self.delete {
                Button(action: {
                    del(self.data)
                }) {
                    Image(Asset.icon.close)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.light,
                               height: Dimen.icon.light)
                        
                        .colorMultiply(Color.app.grey)
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

