//
//  VideoPlayer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/09.
//

import Foundation
//
//  VideoList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

class VideoPlayerData:InfinityData{
    private(set) var image: String? = nil
    private(set) var title: String? = nil
    private(set) var subTitle: String? = nil
    private(set) var count: String = ""
    
    private(set) var synopsisType:SynopsisType = .title
    private(set) var synopsisData:SynopsisData? = nil
    private(set) var epsdId:String? = nil
    private(set) var srisId:String? = nil
    
    func setData(data:SeriesInfoItem, title:String? = nil, idx:Int = -1) -> VideoPlayerData {
        self.title = title
        if let count = data.brcast_tseq_nm {
            self.count = count + String.app.broCount
        }
        image = ImagePath.thumbImagePath(filePath: data.poster_filename_h, size: ListItemKids.videoPlayer.size)
        index = idx
        epsdId = data.epsd_id
        return self
    }
}


struct VideoPlayerList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[VideoPlayerData]
    var contentID:String? = nil
    var margin:CGFloat = DimenKids.margin.thinUltra
    var action: (_ data:VideoPlayerData) -> Void
    
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: 0,
            marginHorizontal: self.margin,
            spacing: Dimen.margin.tiny,
            isRecycle: true,
            useTracking: false
        ){
            
            ForEach(self.datas) { data in
                if data.index == -1 {
                    VideoPlayerItem( data:data , isSelected: self.contentID == nil
                                ? false
                                : self.contentID == data.epsdId)
                    .onTapGesture {
                         action(data)
                    }
                } else {
                    VideoPlayerItem( data:data , isSelected: self.contentID == nil
                                ? false
                                : self.contentID == data.epsdId)
                    .id(data.index)
                    .onTapGesture {
                        action(data)
                    }
                }
            }
        }
        
        
    }//body
}


struct VideoPlayerItem: PageView {
    @EnvironmentObject var repository:Repository
    var data:VideoPlayerData
    var isSelected:Bool = false
    var body: some View {
        
        ZStack{
            ImageView(url: self.data.image,contentMode: .fill, noImg: Asset.noImg16_9)
                .modifier(MatchParent())
                .background(Color.kids.bg)
                .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.regular))
            
            Image(self.isSelected ? AssetKids.player.listBgOn : AssetKids.player.listBg)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .modifier(MatchParent())
            
            VStack(alignment: .leading, spacing:0){
                if let title = self.data.title {
                    VStack(alignment: .leading, spacing:0){
                        Text(self.data.count)
                            .modifier(BoldTextStyleKids(
                                size: Font.sizeKids.thin,
                                color: Color.app.brownDeep
                            ))
                            .lineLimit(1)
                        Spacer().modifier(MatchParent())
                        Text(title)
                            .modifier(BoldTextStyleKids(
                                size: Font.sizeKids.regularExtra,
                                color: Color.app.white
                            ))
                            
                    }
                    .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, DimenKids.margin.lightExtra)
                }
            }
        }
        .frame(
            width: ListItemKids.videoPlayer.size.width,
            height: ListItemKids.videoPlayer.size.height)
        .onAppear(){
        }
    }
    
}

#if DEBUG
struct VideoPlayerList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            VideoPlayerList( datas: [
                
            ]){ _ in
                
            }
            .environmentObject(PagePresenter()).frame(width:320,height:600)
        }
    }
}
#endif

