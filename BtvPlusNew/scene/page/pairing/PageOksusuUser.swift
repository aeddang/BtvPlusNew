//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
import CoreLocation

struct PageOksusuUser: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    @State var datas:[UserData] = []
    @State var selectedData:UserData? = nil
    @State var sceneOrientation: SceneOrientation = .portrait
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: String.oksusu.connect ,
                        isClose: true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    ZStack(alignment: .topLeading){
                        DragDownArrow(
                            infinityScrollModel: self.infinityScrollModel)
                        InfinityScrollView(
                            viewModel: self.infinityScrollModel,
                            marginBottom:self.sceneObserver.safeAreaIgnoreKeyboardBottom,
                            useTracking:true
                            
                        ){
                            VStack(alignment:.leading , spacing:0) {
                                Text(String.oksusu.connectText)
                                    .modifier(MediumTextStyle( size: Font.size.regular ))
                                    .padding(.top, Dimen.margin.light)
                                    .fixedSize(horizontal: false, vertical:true)
                                Text(String.oksusu.connectSub)
                                    .modifier(MediumTextStyle( size: Font.size.light ))
                                    .padding(.top, Dimen.margin.thin)
                                    .fixedSize(horizontal: false, vertical:true)
                                
                            }
                            .modifier(ListRowInset(
                                        marginHorizontal:self.sceneOrientation == .landscape ? Dimen.margin.heavy : Dimen.margin.regular,
                                        spacing: 0))
                            
                            VStack(alignment:.leading , spacing:0) {
                                Text(String.oksusu.connectUser + "OKSUSU")
                                    .modifier(MediumTextStyle( size: Font.size.light  ))
                                    .padding(.top, Dimen.margin.light)
                                    .fixedSize(horizontal: false, vertical:true)
                                Text(String.oksusu.connectIdNum.replace("999"))
                                    .modifier(MediumTextStyle( size: Font.size.light  ))
                                    .padding(.top, Dimen.margin.thin)
                                    .fixedSize(horizontal: false, vertical:true)
                                
                            }
                            .modifier(ListRowInset(
                                        marginHorizontal:self.sceneOrientation == .landscape ? Dimen.margin.heavy : Dimen.margin.regular,
                                        spacing: 0))
                            
                            if !self.datas.isEmpty {
                                UserList(datas: self.datas){ stb in
                                    self.selectedData = stb
                                    self.pagePresenter.onPageEvent(
                                        self.pageObject,
                                        event:.init(type: .selected, data: stb))
                                }
                                .padding(.top, Dimen.margin.heavy)
                                .modifier(ListRowInset(
                                            marginHorizontal:self.sceneOrientation == .landscape ? Dimen.margin.heavy : 0,
                                            spacing: 0))
                            }
                            //.padding(.horizontal, self.sceneOrientation == .landscape ? Dimen.margin.heavy : 0)
                        }
                    }
                    .background(Color.brand.bg)
                    .modifier(MatchParent())
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
                .onReceive(self.infinityScrollModel.$event){evt in
                    guard let evt = evt else {return}
                    switch evt {
                    case .pullCompleted :
                        self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                    case .pullCancel :
                        self.pageDragingModel.uiEvent = .pullCancel(geometry)
                    default : do{}
                    }
                }
                .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                    self.pageDragingModel.uiEvent = .pull(geometry, pos)
                }
            }
            .onReceive(self.sceneObserver.$isUpdated){ _ in
                self.sceneOrientation = self.sceneObserver.sceneOrientation
            }
            .onAppear{
                self.sceneOrientation = self.sceneObserver.sceneOrientation
                guard let obj = self.pageObject  else { return }
                guard let data = (obj.getParamValue(key: .data) as? [StbListInfoDataItem]) else { return }
                self.datas = data.map{ _ in UserData().setDummy() }
            }
            .onDisappear{
                if self.selectedData == nil {
                    self.pagePresenter.onPageEvent(
                        self.pageObject,
                        event:.init(type: .selected, data: nil))
                }
            }
            
            
            
        }//geo
    }//body
    
    
    
    
}



#if DEBUG
struct PageOksusuUser_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageOksusuUser().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(DataProvider())
                .environmentObject(AppSceneObserver())
                .environmentObject(NetworkObserver())
                .environmentObject(LocationObserver())
                .environmentObject(Pairing())
                .frame(width: 400, height: 640, alignment: .center)
        }
    }
}
#endif
