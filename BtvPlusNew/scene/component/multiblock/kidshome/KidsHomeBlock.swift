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
                        case .cateHeader:
                            if let cateData = data as? KidsCategoryItemData {
                                KidsCategoryItem(data:cateData)
                            }
                            
                        case .cateList:
                            if let listData = data as? KidsCategoryListData {
                                KidsCategoryList(data: listData)
                            }
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
            if let prevData =  self.data.kidsHomeBlockData {
                self.homeBlockData = prevData
                self.isUiView = true
            } else {
                let homeData = KidsHomeBlockData().setData(data: self.data)
                self.homeBlockData = homeData
                self.data.kidsHomeBlockData = homeData
                withAnimation{
                    self.isUiView = true
                }
            }
        }
        .onDisappear{
            //self.datas.removeAll()
          
        }
       
    }
    
}
