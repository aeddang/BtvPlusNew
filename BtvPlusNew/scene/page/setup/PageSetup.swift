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
                        VStack(alignment:.leading , spacing:Dimen.margin.medium) {
                            SetupApp(isDataAlram: self.$isDataAlram, isAutoRemocon: self.$isAutoRemocon, isRemoconVibration: self.$isRemoconVibration)
                            SetupPlay(isAutoPlay: self.$isAutoPlay, isNextPlay: self.$isNextPlay)
                            SetupAlram(isPush:self.$isPush)
                            SetupCertification(
                                isPurchaseAuth: self.$isPurchaseAuth,
                                isSetWatchLv: self.$isSetWatchLv,
                                watchLvs: self.watchLvs,
                                selectedWatchLv: self.selectedWatchLv){ select in
                                self.setupWatchLv(select: select)
                            }
                            SetupChildren(){
                                self.setupWatchHabit()
                            }
                            SetupPossession(isPossession: self.$isPossession)
                            SetupHappySenior()
                            SetupGuideNVersion()
                            #if DEBUG
                                SetupTest()
                            #endif
                            
                        }
                        .padding(.vertical, Dimen.margin.medium)
                       
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
            .onReceive( [self.isDataAlram].publisher ) { value in
                if !self.isInitate { return }
                if self.setup.dataAlram == self.isDataAlram { return }
                self.setup.dataAlram = self.isDataAlram
                DispatchQueue.main.async {
                    self.appSceneObserver.event = .toast(
                        self.isDataAlram ? String.alert.dataAlramOn : String.alert.dataAlramOff
                    )
                }
            }
            .onReceive( [self.isAutoRemocon].publisher ) { value in
                if !self.isInitate { return }
                if self.setup.autoRemocon == self.isAutoRemocon { return }
                if self.isPairing == false && value == true {
                    self.appSceneObserver.alert = .needPairing()
                    self.isAutoRemocon = false
                    return
                }
                self.setup.autoRemocon = self.isAutoRemocon
                self.appSceneObserver.event = .toast(
                    self.isAutoRemocon ? String.alert.autoRemoconOn : String.alert.autoRemoconOff
                )
                
            }
            .onReceive( [self.isRemoconVibration].publisher ) { value in
                if !self.isInitate { return }
                if self.setup.remoconVibration == self.isRemoconVibration { return }
                if self.isPairing == false && value == true {
                    self.appSceneObserver.alert = .needPairing()
                    self.isRemoconVibration = false
                    return
                }
                self.setup.remoconVibration = self.isRemoconVibration
                self.appSceneObserver.event = .toast(
                    self.isRemoconVibration ? String.alert.remoconVibrationOn : String.alert.remoconVibrationOff
                )
                
            }
            .onReceive( [self.isAutoPlay].publisher ) { value in
                if !self.isInitate { return }
                if self.setup.autoPlay == self.isAutoPlay { return }
                self.setup.autoPlay = self.isAutoPlay
                self.appSceneObserver.event = .toast(
                    self.isAutoPlay ? String.alert.autoPlayOn : String.alert.autoPlayOff
                )
                
            }
            .onReceive( [self.isPush].publisher ) { value in
                if !self.isInitate { return }
                if self.willPush != nil { return }
                
                if self.pairing.user?.isAgree3 == self.isPush { return }
                if self.isPairing == false {
                    if value {
                        self.appSceneObserver.alert = .needPairing()
                        self.isPush = false
                    }
                    return
                }
                
                self.setupPush(value)
                
            }
            .onReceive( [self.isNextPlay].publisher ) { value in
                if !self.isInitate { return }
                if self.setup.nextPlay == self.isNextPlay { return }
                self.setup.nextPlay = self.isNextPlay
                self.appSceneObserver.event = .toast(
                    self.isNextPlay ? String.alert.nextPlayOn : String.alert.nextPlayOff
                )
            }
            .onReceive( [self.isPossession].publisher ) { value in
                if !self.isInitate { return }
                if self.willPossession != nil { return }
                if !value { return }
                self.setupPossession()
               
                
            }
            .onReceive( [self.isPurchaseAuth].publisher ) { value in
                if !self.isInitate { return }
                if self.willPurchaseAuth != nil { return }
                if self.isPairing && self.setup.isPurchaseAuth == self.isPurchaseAuth { return }
                if !self.isPairing && !self.isPurchaseAuth { return }
                
                if self.isPairing == false && value == true {
                    self.appSceneObserver.alert = .needPairing()
                    self.isPurchaseAuth = false
                    return
                }
                self.setupPurchaseAuth(value)
                self.isPurchaseAuth = !value
                
            }
            .onReceive( [self.isSetWatchLv].publisher ) { value in
                if !self.isInitate { return }
                if self.willSelectedWatchLv != nil { return }
                if self.isPairing && (SystemEnvironment.watchLv > 0) == self.isSetWatchLv { return }
                if !self.isPairing && !self.isSetWatchLv { return }
                if self.isPairing == false {
                    self.appSceneObserver.alert = .needPairing()
                    self.isSetWatchLv = false
                    return
                }
                if !SystemEnvironment.isAdultAuth && value == true {
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.adultCertification)
                    )
                    self.isSetWatchLv = false
                    return
                }
                self.setupWatchLv(select: value ? Setup.WatchLv.lv4.getName() : nil)
                self.isSetWatchLv = !value
            }
            .onReceive(self.dataProvider.$result){ res in
                guard let res = res else { return }
                switch res.type {
                case .updateAgreement(let isAgree) : self.onUpdatedPush(res, isAgree: isAgree)
                default: do{}
                }
            }
            .onReceive(self.dataProvider.$error){ err in
                guard let err = err else { return }
                switch err.type {
                case .updateAgreement : self.onUpdatePushError()
                default: do{}
                }
            }
            
           
            .onReceive(self.pagePresenter.$event){ evt in
                guard let evt = evt else {return}
                
                switch evt.type {
                case .completed :
                    guard let type = evt.data as? ScsNetwork.ConfirmType  else { return }
                    switch type {
                    case .adult:
                        guard let willSelectedWatchLv = self.willSelectedWatchLv  else { return }
                        self.onSetupWatchLv(select: willSelectedWatchLv)
                    case .purchase:
                        guard let willPurchaseAuth = self.willPurchaseAuth  else { return }
                        self.onPurchaseAuth(willPurchaseAuth)
                    }
                case .cancel :
                    guard let type = evt.data as? ScsNetwork.ConfirmType  else { return }
                    switch type {
                    case .adult: self.willSelectedWatchLv = nil
                    case .purchase: self.willPurchaseAuth = nil
                    }
                    
                default : break
                }
            }
            .onAppear{
               
            }
            
        }//geo
    }//body
    
    @State var isPairing:Bool = false
    @State var isDataAlram:Bool = false
    @State var isPush:Bool = false
    @State var willPush:Bool? = nil
    @State var isAutoRemocon:Bool = false
    @State var isRemoconVibration:Bool = false
    @State var isAutoPlay:Bool = false
    @State var isNextPlay:Bool = false
    @State var isSetWatchLv:Bool = false
    @State var isPurchaseAuth:Bool = false
    @State var willPurchaseAuth:Bool? = nil
    @State var isPossession:Bool = false
    @State var willPossession:Bool? = nil
    @State var willSelectedWatchLv:String? = nil
    
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
        self.isPossession = self.setup.possession.isEmpty == false
        self.isInitate = true
    }
    
    private func setupPossession(){
        self.willPossession = true
        self.appSceneObserver.alert = .needCertification(
            String.alert.possession, String.alert.possessionText, String.alert.possessionInfo){
            
            self.setupPossessionCancel()
        }
    }
    private func setupPossessionCancel(){
        self.willPossession = nil
        self.isPossession = false
    }
    
    private func setupPossessionCertificationCompleted(){
        
    }
    
    private func setupWatchLv(select:String?){
        if self.isPairing == false {
            self.appSceneObserver.alert = .needPairing()
            return
        }
        self.willSelectedWatchLv = select ?? ""
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.confirmNumber)
                .addParam(key: .type, value: ScsNetwork.ConfirmType.adult)
        )
    }
   
    private func onSetupWatchLv(select:String){
        if self.isPairing == false { return }
        if select.isEmpty {
            self.isSetWatchLv = false
            self.repository.updateWatchLv(nil)
            self.selectedWatchLv = nil
            self.willSelectedWatchLv = nil
            return
        }
        guard let find = self.watchLvs?.firstIndex(where: {$0 == select}) else {return}
        self.isSetWatchLv = true
        self.repository.updateWatchLv(Setup.WatchLv.allCases[find])
        self.selectedWatchLv = select
        self.willSelectedWatchLv = nil
    }
    
    private func setupPurchaseAuth(_ select:Bool){
        if self.isPairing == false { return }
        self.willPurchaseAuth = select
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.confirmNumber)
                .addParam(key: .type, value: ScsNetwork.ConfirmType.purchase)
        )
    }
   
    private func onPurchaseAuth(_ select:Bool){
        self.setup.isPurchaseAuth = select
        self.isPurchaseAuth = select
        self.willPurchaseAuth = nil
        self.appSceneObserver.alert = .alert(String.alert.purchaseAuthCompleted, String.alert.purchaseAuthCompleteInfo)
    }
    
    private func setupWatchHabit(){
        if self.isPairing == false {
            self.appSceneObserver.alert = .needPairing()
            return
        }
        if !SystemEnvironment.isAdultAuth {
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.adultCertification)
            )
            self.isSetWatchLv = false
            return
        }
        let move = PageProvider.getPageObject(.watchHabit)
        move.isPopup = true
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.confirmNumber)
                .addParam(key: .data, value:move)
                .addParam(key: .type, value: ScsNetwork.ConfirmType.adult)
        )
    }
    
    private func setupPush(_ select:Bool){
        if self.isPairing == false { return }
        self.willPush = select
        self.dataProvider.requestData(q: .init(type: .updateAgreement(select)))
    }
    
    private func onUpdatedPush(_ res:ApiResultResponds, isAgree:Bool){
        guard let data = res.data as? NpsResult  else { return onUpdatePushError() }
        guard let resultCode = data.header?.result else { return onUpdatePushError() }
        if resultCode == NpsNetwork.resultCode.success.code {
            self.repository.updatePush(isAgree)
            self.isPush = isAgree
            self.appSceneObserver.event = .toast(
                isAgree ? String.alert.pushOn : String.alert.pushOff
            )
            self.willPush = nil
        } else {
            onUpdatePushError()
        }
    }
    
    private func onUpdatePushError(){
        self.appSceneObserver.event = .toast( String.alert.pushError )
        self.willPush = nil
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
