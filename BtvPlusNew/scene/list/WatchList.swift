//
//  VideoList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

class WatchedData:InfinityData{
    private(set) var image: String? = nil
    private(set) var title: String? = nil
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
        title = data.title
        if let thumb = data.thumbnail {
            image = ImagePath.thumbImagePath(filePath: thumb, size: ListItem.video.size)
        }
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
    
}


struct WatchedList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[WatchedData]
    var useTracking:Bool = false
    var marginTop:CGFloat = Dimen.margin.tinyExtra
    var marginBottom:CGFloat = Dimen.margin.tinyExtra
    var margin:CGFloat = Dimen.margin.tinyExtra
    var delete: ((_ data:WatchedData) -> Void)? = nil
    var onBottom: ((_ data:WatchedData) -> Void)? = nil
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .vertical,
            marginTop: self.marginTop,
            marginBottom: self.marginBottom,
            marginHorizontal: self.margin,
            spacing:0,
            isRecycle: true,
            useTracking: self.useTracking
        ){
            
            InfoAlert(text: String.pageText.myWatchedInfo)
                .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin ,spacing: Dimen.margin.thin))
            ForEach(self.datas) { data in
                WatchedItem( data:data , delete:self.delete)
                    .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin ,spacing: Dimen.margin.thin))
                    .onTapGesture {
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.synopsis)
                                .addParam(key: .data, value: data.synopsisData)
                        )
                    }
                    .onAppear{
                        if data.index == self.datas.last?.index {
                            self.onBottom?(data)
                        }
                    }
            }
        }
        
    }//body
}

struct WatchedItem: PageView {
    var data:WatchedData
    var delete: ((_ data:WatchedData) -> Void)? = nil
    var body: some View {
        HStack( spacing:Dimen.margin.light){
            ZStack{
                if self.data.image == nil {
                    Image(Asset.noImg16_9)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .modifier(MatchParent())
                } else {
                    ImageView(url: self.data.image!, contentMode: .fill, noImg: Asset.noImg9_16)
                        .modifier(MatchParent())
                }
                if self.data.progress != nil  {
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

