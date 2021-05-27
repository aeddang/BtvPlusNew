//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct PageSetup: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var setup:Setup
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    @State var sceneOrientation: SceneOrientation = .portrait
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: String.pageTitle.setup,
                        isBack : true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    
                    InfinityScrollView( viewModel: self.infinityScrollModel ){
                        if self.sceneOrientation == .landscape {
                            HStack(alignment:.center , spacing:Dimen.margin.thin) {
                                VStack(alignment:.leading , spacing:Dimen.margin.medium) {
                                    SetupApp(
                                        isInitate:self.isInitate, isPairing: self.isPairing,
                                        isDataAlram: self.$isDataAlram,
                                        isAutoRemocon: self.$isAutoRemocon,
                                        isRemoconVibration: self.$isRemoconVibration)
                                    SetupPlay(
                                        isInitate:self.isInitate, isPairing: self.isPairing,
                                        isAutoPlay: self.$isAutoPlay,
                                        isNextPlay: self.$isNextPlay)
                                    
                                    SetupAlram(
                                        isInitate:self.isInitate, isPairing: self.isPairing,
                                        isPush:self.$isPush)
                                
                                }
                                VStack(alignment:.leading , spacing:Dimen.margin.medium) {
                                    SetupCertification(
                                        isInitate:self.isInitate, isPairing: self.isPairing,
                                        isPurchaseAuth: self.$isPurchaseAuth,
                                        isSetWatchLv: self.$isSetWatchLv,
                                        watchLvs: self.$watchLvs,
                                        selectedWatchLv: self.$selectedWatchLv)
                                    
                                    SetupChildren(
                                        isInitate:self.isInitate, isPairing: self.isPairing)
                                    SetupPossession(
                                        isInitate:self.isInitate)
                                    SetupHappySenior()
                                   
                                }
                            }
                            .padding(.vertical, Dimen.margin.medium)
                        } else {
                            VStack(alignment:.leading , spacing:Dimen.margin.medium) {
                                SetupApp(
                                    isInitate:self.isInitate, isPairing: self.isPairing,
                                    isDataAlram: self.$isDataAlram,
                                    isAutoRemocon: self.$isAutoRemocon,
                                    isRemoconVibration: self.$isRemoconVibration)
                                SetupPlay(
                                    isInitate:self.isInitate, isPairing: self.isPairing,
                                    isAutoPlay: self.$isAutoPlay,
                                    isNextPlay: self.$isNextPlay)
                                
                                SetupAlram(
                                    isInitate:self.isInitate, isPairing: self.isPairing,
                                    isPush:self.$isPush)
                                SetupCertification(
                                    isInitate:self.isInitate, isPairing: self.isPairing,
                                    isPurchaseAuth: self.$isPurchaseAuth,
                                    isSetWatchLv: self.$isSetWatchLv,
                                    watchLvs: self.$watchLvs,
                                    selectedWatchLv: self.$selectedWatchLv)
                                
                                SetupChildren(
                                    isInitate:self.isInitate, isPairing: self.isPairing)
                                SetupPossession(
                                    isInitate:self.isInitate)
                                SetupHappySenior()
                                SetupGuideNVersion()
                                #if DEBUG
                                    SetupTest()
                                #endif
                                
                            }
                            .padding(.vertical, Dimen.margin.medium)
                        }
                        
                    }
                    .modifier(ContentHorizontalEdges())
                    .modifier(MatchParent())
                }
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                .modifier(PageFull())
            }
            .onReceive(self.pairing.$status){ status in
                self.resetSetup(status: status)
            }
            .onReceive(self.sceneObserver.$isUpdated){ _ in
                self.sceneOrientation = self.sceneObserver.sceneOrientation
            }
            .onAppear{
                self.sceneOrientation = self.sceneObserver.sceneOrientation
            }
            
        }//geo
    }//body
    
    @State var isPairing:Bool = false
    @State var isDataAlram:Bool = false
    @State var isPush:Bool = false
    @State var isAutoRemocon:Bool = false
    @State var isRemoconVibration:Bool = false
    @State var isAutoPlay:Bool = false
    @State var isNextPlay:Bool = false
    @State var isSetWatchLv:Bool = false
    @State var isPurchaseAuth:Bool = false
   
    @State var isInitate:Bool = false
    @State var watchLvs:[String]? = nil
    @State var selectedWatchLv:String? = nil
    
    func resetSetup(status:PairingStatus){
        switch status {
        case .pairing : self.isPairing = true
        default : self.isPairing = false
        }
        self.isDataAlram = self.setup.dataAlram
        self.isAutoRemocon = self.isPairing ? self.setup.autoRemocon : false
        self.isRemoconVibration = self.isPairing ? self.setup.remoconVibration : false
        self.isAutoPlay = self.setup.autoPlay
        self.isNextPlay = self.setup.nextPlay
        self.isPurchaseAuth = self.isPairing ? self.setup.isPurchaseAuth : false
        self.isSetWatchLv = self.isPairing ? (SystemEnvironment.watchLv > 0) : false
        self.watchLvs = Setup.WatchLv.allCases.map{$0.getName()}
        self.selectedWatchLv = Setup.WatchLv.getLv(SystemEnvironment.watchLv)?.getName()
        self.isPush = self.pairing.user?.isAgree3 ?? false
        
        self.isInitate = true
    }
    
    
    
    

    
}

#if DEBUG
struct PageSetup_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageSetup().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(Pairing())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
