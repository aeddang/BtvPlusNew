//
//  PosterBox.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI
import Combine


struct KidsHomeBlock:PageComponent, BlockProtocol {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pairing:Pairing
    var pageObservable:PageObservable
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var data: BlockData
    var useTracking:Bool = false
   
    @State var homeBlockData:KidsHomeBlockData? = nil
    @State var isUiView:Bool = false
    var body :some View {
        ScrollView(.horizontal,showsIndicators: false) {
            HStack(alignment: .bottom, spacing:Dimen.margin.light){
                if let homeBlockData = self.homeBlockData {
                    ForEach(homeBlockData.datas) { data in
                        switch data.type {
                        case .myHeader :
                            if let myData = data as? KidsMyItemData {
                                KidsMyItem(data:myData)
                            }
                        case .playList:
                            if let playData = data as? KidsPlayListData {
                                KidsPlayList(data:playData)
                            }
                        case .cateHeader: Spacer().background(Color.app.yellow)
                        case .cateList: Spacer().background(Color.app.red)
                        case .banner:
                            if let bannerData = data as? KidsBannerData {
                                KidsBanner(data: bannerData)
                            }
                        case .none: Spacer()
                        }
                    }
                }
            }
            .modifier(ContentHorizontalEdgesKids())
            .opacity(self.isUiView ? 1 : 0)
            
        }
        .modifier(MatchParent())
        .onAppear{
            self.homeBlockData = KidsHomeBlockData().setData(data: self.data)
            withAnimation{
                self.isUiView = true
            }
        }
        .onDisappear{
            //self.datas.removeAll()
          
        }
       
    }
    
}
