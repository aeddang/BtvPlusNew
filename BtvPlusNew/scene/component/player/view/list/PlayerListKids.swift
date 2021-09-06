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




struct PlayerListKids: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[PlayerListData]
    var contentID:String? = nil
    var margin:CGFloat = DimenKids.margin.thinUltra
    var action: (_ data:PlayerListData) -> Void
    
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
                PlayerListItemKids(viewModel: self.viewModel, data:data , isSelect: self.contentID == data.epsdId)
                .id(data.hashId)
                .onTapGesture {
                    action(data)
                }
            }
        }
        
        
    }//body
}


struct PlayerListItemKids: PageView {
    @ObservedObject var viewModel: InfinityScrollModel
    var data:PlayerListData
    var isSelect:Bool = false
    @State var isSelected:Bool = false
    var body: some View {
        
        ZStack{
            ImageView(url: self.data.image,contentMode: .fill, noImg: Asset.noImg16_9)
                .modifier(MatchParent())
                .background(Color.kids.bg)
                .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.regularUltra))
            
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
                                color: self.isSelected ? Color.app.white : Color.app.brownDeep
                            ))
                            .lineLimit(1)
                            .frame(width: SystemEnvironment.isTablet ? 80 : 40)
                            .padding(.leading, DimenKids.margin.tinyExtra)
                        Spacer().modifier(MatchParent())
                        Text(title)
                            .modifier(BoldTextStyleKids(
                                size: Font.sizeKids.regularExtra,
                                color: Color.app.white
                            ))
                            .padding(.horizontal, DimenKids.margin.lightExtra)
                    }
                    .padding(.vertical, DimenKids.margin.lightExtra)
                }
            }
        }
        .frame(
            width: ListItemKids.video.size.width,
            height: ListItemKids.video.size.height)
        .onReceive(self.viewModel.$itemEvent) { evt in
            switch evt {
            case .select(let selectedData) :
                self.isSelected = selectedData.contentID == self.data.contentID
            default : return
            }
        }
        .onAppear(){
            self.isSelected = isSelect
        }
    }
    
}

#if DEBUG
struct VideoPlayerList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PlayerListKids( datas: [
                
            ]){ _ in
                
            }
            .environmentObject(PagePresenter()).frame(width:320,height:600)
        }
    }
}
#endif

