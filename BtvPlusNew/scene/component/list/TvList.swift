//
//  VideoList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

class TvData:InfinityData, Copying{
    private(set) var title: String? = nil
    private(set) var subTitle: String? = nil
    private(set) var channel:String? = nil
    private(set) var startDate: Date? = nil
    private(set) var endDate: Date? = nil
    private(set) var data:CategoryTvItem? = nil
    private(set) var type:TvType = .list
    private(set) var actionLog:MenuNaviActionBodyItem? = nil
    private(set) var contentLog:MenuNaviContentsBodyItem? = nil
    
    required init(original: TvData) {
        title = original.title
        subTitle = original.subTitle
        channel = original.channel
        startDate = original.startDate
        endDate = original.endDate
        data = original.data
        type = original.type
        actionLog = original.actionLog
        contentLog = original.contentLog
    }
    
    
    var hasLog:Bool {
        get{
            return actionLog != nil || contentLog != nil
        }
    }
    override init() {
        super.init()
    }
    
    func setNaviLog(action:MenuNaviActionBodyItem?) -> TvData {
        self.actionLog = action
        return self
    }
  
    func setNaviLog(searchType:BlockData.SearchType) -> TvData {
        self.contentLog = MenuNaviContentsBodyItem(
            type: searchType.logType,
            title: self.title,
            channel_name: self.channel,
            genre_text: nil,
            genre_code: nil,
            paid: nil,
            purchase: nil,
            episode_id: nil,
            episode_resolution_id: nil,
            product_id: nil,
            purchase_type: nil,
            monthly_pay: nil,
            list_price: nil
        )
        return self
    }
    
    func setData(data:CategoryTvItem, searchType:BlockData.SearchType, idx:Int = -1) -> TvData {
        self.data = data
        title = data.title
        channel = data.channel_name
        if let start = data.start_time {
            let startYmd = start.count == 12 ? start : ("20" + start)
            startDate = startYmd.toDate(dateFormat: "yyyyMMddHHmm")
        }
        if let end = data.end_time {
            let endYmd = end.count == 12 ? end : ("20" + end)
            endDate = endYmd.toDate(dateFormat: "yyyyMMddHHmm")
        }
        if let sd = self.startDate, let ed = self.endDate {
            subTitle = sd.toDateFormatter(dateFormat: "HH:mm") + "~" + ed.toDateFormatter(dateFormat: "HH:mm")
        }
        index = idx
        return self.setNaviLog(searchType:searchType)
    }
    
    fileprivate func setCardType(width:CGFloat, height:CGFloat, padding:CGFloat) -> TvData {
        self.type = .cell(CGSize(width: width, height: height), padding)
        return self
    }
}

enum TvType {
    case list, cell(CGSize, CGFloat)
    var size:CGSize {
        get{
            switch self {
            case .list: return ListItem.tv.size
            case .cell(let size, _ ): return size
            }
        }
    }
}
    

struct TvList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[TvData]
    var contentID:String? = nil
    var margin:CGFloat =  Dimen.margin.thin
    var spacing:CGFloat = Dimen.margin.tiny
   
    var useTracking:Bool = false
    var action: ((_ data:VideoData) -> Void)? = nil
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: 0,
            marginHorizontal: self.margin,
            spacing: self.spacing,
            isRecycle: true,
            useTracking: self.useTracking
        ){
            ForEach(self.datas) { data in
                TvItem( data:data)
            }
        }
    }//body
}

struct TvDataSet:Identifiable {
    private(set) var id = UUID().uuidString
    var count:Int = 2
    var datas:[TvData] = []
    var isFull = false
    var index:Int = -1
}

extension TvSet{
    static func listSize(data:TvDataSet,
                         screenWidth:CGFloat,
                         padding:CGFloat =  Self.listPadding,
                         isFull:Bool = false) -> CGSize{
        
        let ratio = ListItem.tv.size.height / ListItem.tv.size.width
        let count = CGFloat(data.count)
        let w = screenWidth - ( padding * 2)
        let cellW = ( w - ( padding * (count-1)) ) / count
        let cellH = round(cellW * ratio)
        return CGSize(width: floor(cellW), height: cellH )
    }
    static let listPadding:CGFloat = SystemEnvironment.currentPageType == .btv
        ? SystemEnvironment.isTablet ? Dimen.margin.tiny : Dimen.margin.thin
        : DimenKids.margin.thinUltra
}

struct TvSet: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var pageObservable:PageObservable = PageObservable()
    var data:TvDataSet
    var screenSize:CGFloat? = nil
    var padding:CGFloat = Self.listPadding
    
    @State var cellDatas:[TvData] = []
    @State var isUiActive:Bool = true
    var body: some View {
        HStack(spacing:self.padding){
            if self.isUiActive {
                ForEach(self.cellDatas) { data in
                    TvItem( data:data )
                }
                if !self.data.isFull && self.data.count > 1{
                    Spacer()
                }
            }
        }
        .padding(.horizontal, self.padding)
        .frame(width: self.screenSize ?? self.sceneObserver.screenSize.width)
        .onAppear {
            if self.data.datas.isEmpty { return }
            let size = Self.listSize(data: self.data,
                                     screenWidth: self.screenSize ?? sceneObserver.screenSize.width,
                                     padding: self.padding,
                                     isFull: false)
            self.cellDatas = self.data.datas.map{
                $0.setCardType(width: size.width, height: size.height, padding:  self.padding)
            }
        }
        .onReceive(self.pageObservable.$layer ){ layer  in
            switch layer {
            case .bottom : self.isUiActive = false
            case .top, .below : self.isUiActive = true
            }
        }
    }//body
}


struct TvItem: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var naviLogManager:NaviLogManager
    var data:TvData
    var isSelected:Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            Spacer().modifier(MatchHorizontal(height: 0))
            HStack(alignment: .top, spacing: 0) {
                Text(self.data.title ?? "")
                    .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.white))
                    .lineLimit(2)
                Spacer().modifier(MatchVertical(width: 0))
            }
            HStack(spacing:Dimen.margin.tiny){
                if let channel = data.channel {
                    Text(channel)
                        .modifier(MediumTextStyle(size: Font.size.tiny, color: Color.app.greyMedium))
                        .lineLimit(1)
                    if self.data.subTitle != nil {
                        Spacer().modifier(MatchVertical(width: 1))
                            .background(Color.app.greyDeep)
                            .frame(height: Dimen.line.heavyExtra)
                    }
                }
                if let subTitle  = data.subTitle {
                    Text(subTitle )
                        .modifier(MediumTextStyle(size: Font.size.tiny, color: Color.app.greyMedium))
                        .lineLimit(1)
                }
            }
        }
        .onTapGesture {
            if self.data.hasLog {
                self.naviLogManager.actionLog(.clickContentsList, actionBody: data.actionLog, contentBody: data.contentLog) 
            }
            self.pagePresenter.openPopup(PageProvider.getPageObject(.schedule)
                                            .addParam(key: .id, value: self.data.data?.con_id))
            
        }
        .padding(.vertical, Dimen.margin.thin)
        .padding(.horizontal, Dimen.margin.tiny)
        .background(Color.app.blueLight)
        .frame(width: self.data.type.size.width, height:  self.data.type.size.height)
        
    }
    
}



#if DEBUG
struct  TvList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            VideoList( datas: [
                VideoData().setDummy(0),
                VideoData().setDummyWatching(),
                VideoData().setDummy(),
                VideoData().setDummy()
            ])
            .environmentObject(PagePresenter()).frame(width:320,height:600)
        }
    }
}
#endif

