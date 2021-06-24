//
//  VideoList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

struct PlayerList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[PlayerListData]
    var contentID:String? = nil
    var margin:CGFloat = Dimen.margin.thin
   
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
                if data.index == -1 {
                    PlayerListItem( viewModel: self.viewModel, data:data , isSelect:  self.contentID == data.epsdId)
                    .onTapGesture {
                        action(data)
                        
                    }
                } else {
                    PlayerListItem( viewModel: self.viewModel, data:data , isSelect:  self.contentID == data.epsdId)
                    .id(data.index)
                    .onTapGesture {
                        action(data)

                    }
                }
            }
        }
        .onAppear{
            
        }
    }//body
}


struct PlayerListItem: PageView {
    @ObservedObject var viewModel: InfinityScrollModel
    var data:PlayerListData
    var isSelect:Bool = false
    @State var isSelected:Bool = false
    var body: some View {
        ZStack{
            ImageView(url: self.data.image,contentMode: .fill, noImg: Asset.noImg16_9)
                .modifier(MatchParent())
            Spacer().modifier(MatchParent()).background(
                self.isSelected ? Color.transparent.black45 : Color.transparent.black70)
            
            if  self.isSelected  {
                Image(Asset.icon.thumbPlay)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.regularExtra, height: Dimen.icon.regularExtra)
            }
            VStack(alignment: .leading, spacing:0){
                Spacer().modifier(MatchParent())
                if self.data.title != nil {
                    VStack(alignment: .center, spacing:0){
                        Spacer().modifier(MatchHorizontal(height: 0))
                        Text(self.data.count + " " + self.data.title!)
                            .modifier(MediumTextStyle(size: Font.size.thinExtra))
                            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, Dimen.margin.thinExtra)
                            .lineLimit(1)
                    }
                }
            }
        }
        .frame(
            width: ListItem.video.size.width,
            height: ListItem.video.size.height)
        .clipped()
        .background(Color.app.blueLight)
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



