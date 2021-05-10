//
//  VideoList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

class WatchedData:InfinityData{
    private(set) var originImage: String? = nil
    private(set) var image: String? = nil
    private(set) var title: String? = nil
    private(set) var watchLv:Int = 0
    private(set) var isAdult:Bool = false
    private(set) var isLock:Bool = false
    private(set) var subTitle: String? = nil
    private(set) var count: String = "0"
    private(set) var progress:Float? = nil
    private(set) var synopsisData:SynopsisData? = nil

    private(set) var srisId:String? = nil
    
    func setData(data:WatchItem, idx:Int = -1) -> WatchedData {
        if let rt = data.watch_rt?.toInt() {
            self.progress = Float(rt) / 100.0
            self.subTitle = rt.description + "% " + String.app.watch
        }
        watchLv = data.level?.toInt() ?? 0
        isAdult = data.adult?.toBool() ?? false
        isLock = !SystemEnvironment.isImageLock ? false : isAdult
        title = data.title
        
        originImage = data.thumbnail
        image = ImagePath.thumbImagePath(filePath: data.thumbnail, size: ListItem.watched.size, isAdult:isAdult)
        
        index = idx
        srisId = data.sris_id
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.sris.rawValue,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id, prdPrcId: "",  kidZone:nil)
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
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[WatchedData]
    var useTracking:Bool = false
    var delete: ((_ data:WatchedData) -> Void)? = nil
    var onBottom: ((_ data:WatchedData) -> Void)? = nil
    @State var horizontalMargin:CGFloat = Dimen.margin.thin
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .vertical,
            scrollType : .reload(isDragEnd:false),
            marginTop: Dimen.margin.regular,
            marginBottom: Dimen.app.bottom,
            spacing:0,
            isRecycle: true,
            useTracking: self.useTracking
        ){
            
            InfoAlert(text: String.pageText.myWatchedInfo)
                .modifier(ListRowInset(marginHorizontal:self.horizontalMargin ,spacing: Dimen.margin.thin))
            
            if !self.datas.isEmpty {
                ForEach(self.datas) { data in
                    WatchedItem( data:data , delete:self.delete)
                        .modifier(ListRowInset(marginHorizontal:self.horizontalMargin ,spacing: Dimen.margin.tinyExtra))
                        .onTapGesture {
                            guard let synopsisData = data.synopsisData else { return }
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.synopsis)
                                    .addParam(key: .data, value: synopsisData)
                            )
                        }
                        .onAppear{
                            if data.index == self.datas.last?.index {
                                self.onBottom?(data)
                            }
                        }
                }
            } else {
                EmptyMyData(
                    text:String.pageText.myWatchedEmpty)
                    .modifier(PageBody())
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
                ImageView(url: self.data.image, contentMode: .fill, noImg: Asset.noImg9_16)
                    .modifier(MatchParent())
                if self.data.isLock {
                    Image(Asset.icon.itemRock)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:Dimen.icon.light, height: Dimen.icon.light)
                }else if self.data.progress != nil  {
                    Image(Asset.icon.thumbPlay)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.regularExtra, height: Dimen.icon.regularExtra)
                }
                VStack(alignment: .leading, spacing:0){
                    HStack(spacing:0){}
                    Spacer().modifier(MatchParent())
                    if self.data.progress != nil {
                        Spacer().frame(
                            width: ListItem.video.size.width * CGFloat(self.data.progress!),
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

