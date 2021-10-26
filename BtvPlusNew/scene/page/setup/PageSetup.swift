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
    @EnvironmentObject var naviLogManager:NaviLogManager
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    @State var sceneOrientation: SceneOrientation = .portrait
    @State var pairingStbType:PairingDeviceType = .btv
    @State var isQAMode:Bool = false
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
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
                            HStack(alignment:.top , spacing:Dimen.margin.thin) {
                                VStack(alignment:.leading , spacing:Dimen.margin.medium) {
                                    SetupApp(
                                        isInitate:self.isInitate,
                                        isPairing: self.isPairing,
                                        pairingStbType: self.pairingStbType,
                                        isDataAlram: self.$isDataAlram,
                                        isAutoRemocon: self.$isAutoRemocon,
                                        isRemoconVibration: self.$isRemoconVibration)
                                    SetupPlay(
                                        isInitate:self.isInitate,
                                        isPairing: self.isPairing,
                                        isAutoPlay: self.$isAutoPlay,
                                        isNextPlay: self.$isNextPlay)
                                    
                                    SetupAlram(
                                        isInitate:self.isInitate, isPairing: self.isPairing,
                                        isPush:self.$isPush)
                                
                                }
                                VStack(alignment:.leading , spacing:Dimen.margin.medium) {
                                    SetupCertification(
                                        isInitate:self.isInitate,
                                        isPairing: self.isPairing,
                                        pairingStbType: self.pairingStbType,
                                        isPurchaseAuth: self.$isPurchaseAuth,
                                        isSetWatchLv: self.$isSetWatchLv,
                                        isKidsExitAuth: self.$isKidsExitAuth,
                                        watchLvs: self.$watchLvs,
                                        selectedWatchLv: self.$selectedWatchLv)
                                    
                                    
                                    if self.pairingStbType == .btv && !self.isPairing{
                                        //SetupChildren(isInitate:self.isInitate, isPairing: self.isPairing)
                                        SetupPossession(isInitate:self.isInitate)
                                        //SetupHappySenior()
                                    }
                                    //SetupOksusu(isInitate:self.isInitate)
                                    SetupGuideNVersion(isQAMode: self.$isQAMode)
                                   
                                }
                            }
                            .padding(.vertical, Dimen.margin.medium)
                        } else {
                            VStack(alignment:.leading , spacing:Dimen.margin.medium) {
                                SetupApp(
                                    isInitate:self.isInitate,
                                    isPairing: self.isPairing,
                                    pairingStbType: self.pairingStbType,
                                    isDataAlram: self.$isDataAlram,
                                    isAutoRemocon: self.$isAutoRemocon,
                                    isRemoconVibration: self.$isRemoconVibration)
                                SetupPlay(
                                    isInitate:self.isInitate,
                                    isPairing: self.isPairing,
                                    isAutoPlay: self.$isAutoPlay,
                                    isNextPlay: self.$isNextPlay)
                                
                                SetupAlram(
                                    isInitate:self.isInitate,
                                    isPairing: self.isPairing,
                                    isPush:self.$isPush)
                                SetupCertification(
                                    isInitate:self.isInitate,
                                    isPairing: self.isPairing,
                                    pairingStbType: self.pairingStbType,
                                    isPurchaseAuth: self.$isPurchaseAuth,
                                    isSetWatchLv: self.$isSetWatchLv,
                                    isKidsExitAuth: self.$isKidsExitAuth,
                                    watchLvs: self.$watchLvs,
                                    selectedWatchLv: self.$selectedWatchLv)
                                
                                
                                if self.pairingStbType == .btv && !self.isPairing {
                                    //SetupChildren(isInitate:self.isInitate, isPairing: self.isPairing)
                                    SetupPossession(isInitate:self.isInitate)
                                    //SetupHappySenior()
                                }
                                //SetupOksusu(isInitate:self.isInitate)
                                SetupGuideNVersion(isQAMode: self.$isQAMode)
                                    
                                //#if DEBUG
                                if self.isQAMode {
                                    SetupQA()
                                    SetupLaboratory()
                                }
                                //#endif
                                
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
            .onReceive(self.pairing.$event){ evt in
                switch evt{
                case .connected :
                    self.pairingStbType = self.pairing.pairingStbType
                    break
                case .disConnected :
                    self.pairingStbType = self.pairing.pairingStbType
                    break
                default :break
                }
            }
            .onReceive(self.pairing.$status){ status in
                self.resetSetup(status: status)
            }
            .onReceive(self.sceneObserver.$isUpdated){ _ in
                self.sceneOrientation = self.sceneObserver.sceneOrientation
            }
            .onAppear{
                self.sceneOrientation = self.sceneObserver.sceneOrientation
                self.pairingStbType = self.pairing.pairingStbType
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
    @State var isKidsExitAuth:Bool = false
    @State var isInitate:Bool = false
    @State var watchLvs:[String]? = nil
    @State var selectedWatchLv:String? = nil
    
    func resetSetup(status:PairingStatus){
        switch status {
        case .pairing : self.isPairing = true
        default : self.isPairing = false
        }
        self.isDataAlram = self.setup.dataAlram
        self.isAutoRemocon = self.setup.autoRemocon  //self.isPairing ? self.setup.autoRemocon : false
        self.isRemoconVibration = self.setup.remoconVibration //self.isPairing ? self.setup.remoconVibration : false
        self.isAutoPlay = self.setup.autoPlay
        self.isNextPlay = self.setup.nextPlay
        self.isKidsExitAuth = self.isPairing ? self.setup.isKidsExitAuth : false
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
