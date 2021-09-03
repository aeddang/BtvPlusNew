//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine


struct PageKidsCategoryList: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var naviLogManager:NaviLogManager
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var viewModel:CateBlockModel = CateBlockModel(pageType: .kids)
    @State var title:String? = nil
    @State var listType:CateBlock.ListType = .poster
    @State var cardType:BlockData.CardType? = nil
    @State var menuId:String? = nil
    @State var blockData:BlockData? = nil
    
    @State var marginBottom:CGFloat = 0
    @State var marginHorizontal:CGFloat = 0
    @State var isUiInit:Bool = false
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(spacing:0){
                    PageKidsTab(
                        title: self.title,
                        isBack : true,
                        style: .kidsWhite
                    ){
                        if let action = self.blockData?.pageCloseActionLog {
                            self.naviLogManager.actionLog(.clickContentsSeriesBack, actionBody: action)
                        }
                        self.pagePresenter.goBack()
                    }
                    CateBlock(
                        pageObservable: self.pageObservable,
                        infinityScrollModel:self.infinityScrollModel,
                        viewModel:self.viewModel,
                        useTracking:true,
                        marginBottom:self.marginBottom,
                        marginHorizontal: self.marginHorizontal,
                        spacing: DimenKids.margin.thinUltra
                    )
                    
                }
                .modifier(PageFullScreen(style:.kids))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }
            
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    if self.isUiInit {return}
                    DispatchQueue.main.async {
                        self.isUiInit = true
                        if let data = self.blockData {
                            self.viewModel.update(data: data, listType:self.listType,
                                                  cardType: self.cardType, isAdult:data.isAdult, key:nil)
                        }else{
                            self.viewModel.update(menuId:self.menuId, listType:self.listType,
                                                  cardType: self.cardType, isAdult:false, key:nil)
                        }
                    }
                }
            }
            
            
            .onReceive(self.sceneObserver.$isUpdated){ update in
                if !update {return}
                self.marginBottom = self.sceneObserver.safeAreaIgnoreKeyboardBottom
                self.marginHorizontal = max(self.sceneObserver.safeAreaStart,self.sceneObserver.safeAreaEnd) + DimenKids.margin.regular
            }
            .onAppear{
                self.marginBottom = self.sceneObserver.safeAreaIgnoreKeyboardBottom
                self.marginHorizontal = max(self.sceneObserver.safeAreaStart,self.sceneObserver.safeAreaEnd) + DimenKids.margin.regular
                
                guard let obj = self.pageObject  else { return }
                if let data = obj.getParamValue(key: .data) as? BlockData {
                    self.title = data.name
                    self.blockData = data
                } else {
                    self.menuId = obj.getParamValue(key: .id) as? String
                    
                }
                self.title = obj.getParamValue(key: .title) as? String ?? self.title
                self.listType = obj.getParamValue(key: .type) as? CateBlock.ListType ?? .poster
                self.cardType = obj.getParamValue(key: .subType) as? BlockData.CardType
                if let action = self.blockData?.pageShowActionLog {
                    self.naviLogManager.actionLog(.pageShow, actionBody: action)
                }
            }
            .onDisappear{
               
            }
        }//geo
    }//body
        
    
}


#if DEBUG
struct PageKidsCategoryList_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageKidsCategoryList().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(AppSceneObserver())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

