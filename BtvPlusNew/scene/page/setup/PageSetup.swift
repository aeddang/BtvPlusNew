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
                            VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
                                Text(String.pageText.setupApp).modifier(ContentTitle())
                                VStack(alignment:.leading , spacing:0) {
                                    SetupItem (
                                        isOn: self.$isDataAlram,
                                        title: String.pageText.setupAppDataAlram ,
                                        subTitle: String.pageText.setupAppDataAlramText
                                    )
                                    Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                                    SetupItem (
                                        isOn: self.$isAutoRemocon,
                                        title: String.pageText.setupAppAutoRemocon ,
                                        subTitle: String.pageText.setupAppAutoRemoconText
                                    )
                                    Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                                    SetupItem (
                                        isOn: self.$isRemoconVibration,
                                        title: String.pageText.setupAppRemoconVibration ,
                                        subTitle: String.pageText.setupAppRemoconVibrationText
                                    )
                                }
                                .background(Color.app.blueLight)
                            }
                            
                            VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
                                Text(String.pageText.setupPlay).modifier(ContentTitle())
                                VStack(alignment:.leading , spacing:0) {
                                    SetupItem (
                                        isOn: self.$isAutoPlay,
                                        title: String.pageText.setupPlayAuto ,
                                        subTitle: String.pageText.setupPlayAutoText
                                    )
                                    Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                                    SetupItem (
                                        isOn: self.$isNextPlay,
                                        title: String.pageText.setupPlayNext ,
                                        subTitle: String.pageText.setupPlayNextText
                                    )

                                }
                                .background(Color.app.blueLight)
                            }
                            
                            VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
                                Text(String.pageText.setupAlram).modifier(ContentTitle())
                                VStack(alignment:.leading , spacing:0) {
                                    SetupItem (
                                        isOn: .constant(true),
                                        title: String.pageText.setupAlramMarketing ,
                                        subTitle: String.pageText.setupAlramMarketingText,
                                        tips: [
                                            String.pageText.setupAlramMarketingTip1,
                                            String.pageText.setupAlramMarketingTip2,
                                            String.pageText.setupAlramMarketingTip3,
                                            String.pageText.setupAlramMarketingTip4,
                                            String.pageText.setupAlramMarketingTip5
                                        ]
                                    )
                                }
                                .background(Color.app.blueLight)
                            }
                            
                            VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
                                Text(String.pageText.setupCertification).modifier(ContentTitle())
                                VStack(alignment:.leading , spacing:0) {
                                    SetupItem (
                                        isOn: .constant(true),
                                        title: String.pageText.setupCertificationPurchase,
                                        subTitle: String.pageText.setupCertificationPurchaseText
                                    )
                                    Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                                    SetupItem (
                                        isOn: self.$isSetWatchLv,
                                        title: String.pageText.setupCertificationAge,
                                        subTitle: String.pageText.setupCertificationAgeText,
                                        radios: self.isSetWatchLv ? self.watchLvs : nil,
                                        selectedRadio: self.isSetWatchLv ? self.selectedWatchLv : nil,
                                        selected: { select in
                                            self.setupWatchLv(select: select)
                                        }
                                    )
                                }
                                .background(Color.app.blueLight)
                            }
                            
                            VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
                                Text(String.pageText.setupChildren).modifier(ContentTitle())
                                VStack(alignment:.leading , spacing:0) {
                                    SetupItem (
                                        isOn: .constant(true),
                                        title: String.pageText.setupChildrenHabit,
                                        subTitle: String.pageText.setupChildrenHabitText,
                                        more:{
                                            
                                        }
                                    )
                                }
                                .background(Color.app.blueLight)
                            }
                            
                            VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
                                Text(String.pageText.setupHappySenior).modifier(ContentTitle())
                                VStack(alignment:.leading , spacing:0) {
                                    SetupItem (
                                        isOn: .constant(true),
                                        title: String.pageText.setupHappySeniorPicture,
                                        subTitle: String.pageText.setupHappySeniorPictureText,
                                        more:{
                                            
                                        }
                                    )
                                }
                                .background(Color.app.blueLight)
                            }
                            
                            VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
                                Text(String.pageText.setupGuideNVersion).modifier(ContentTitle())
                                VStack(alignment:.leading , spacing:0) {
                                    SetupItem (
                                        isOn: .constant(true),
                                        title: String.pageText.setupGuide,
                                        more:{
                                            
                                        }
                                    )
                                    Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                                    SetupItem (
                                        isOn: .constant(true),
                                        title: String.pageText.setupGuideNVersion,
                                        more:{
                                            
                                        }
                                    )
                                    Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                                    SetupItem (
                                        isOn: .constant(true),
                                        title: SystemEnvironment.bundleVersion + "(" + SystemEnvironment.buildNumber + ")",
                                        more:{
                                            
                                        }
                                    )
                                    #if DEBUG
                                        Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                                        SetupItem (
                                            isOn: .constant(true),
                                            title: "실서버",
                                            more:{
                                                self.repository.reset(isReleaseMode: true, isEvaluation: false)
                                            }
                                        )
                                        Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                                        SetupItem (
                                            isOn: .constant(true),
                                            title: "스테이지",
                                            more:{
                                                self.repository.reset(isReleaseMode: false, isEvaluation: false)
                                            }
                                        )
                                    #endif
                                }
                                .background(Color.app.blueLight)
                            }
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
            .onReceive( [self.isNextPlay].publisher ) { value in
                if !self.isInitate { return }
                if self.setup.nextPlay == self.isNextPlay { return }
                self.setup.nextPlay = self.isNextPlay
                self.appSceneObserver.event = .toast(
                    self.isNextPlay ? String.alert.nextPlayOn : String.alert.nextPlayOff
                )
            }
            .onReceive( [self.isSetWatchLv].publisher ) { value in
                if !self.isInitate { return }
                if (SystemEnvironment.watchLv > 0) == self.isSetWatchLv { return }
                if self.isPairing == false && value == true {
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
                
                self.repository.updateWatchLv(self.isSetWatchLv ? .lv4 : nil)
                self.selectedWatchLv = Setup.WatchLv.getLv(SystemEnvironment.watchLv)?.getName()
            }
            .onAppear{
               
            }
            
        }//geo
    }//body
    
    @State var isPairing:Bool = false
    @State var isDataAlram:Bool = false
    @State var isAutoRemocon:Bool = false
    @State var isRemoconVibration:Bool = false
    @State var isAutoPlay:Bool = false
    @State var isNextPlay:Bool = false
    @State var isSetWatchLv:Bool = false
    
    @State var watchLvs:[String]? = nil
    @State var selectedWatchLv:String? = nil
    
    
    @State var isInitate:Bool = false
    
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
        self.isInitate = true
        self.isSetWatchLv = self.isPairing ? (SystemEnvironment.watchLv > 0) : false
        
        self.watchLvs = Setup.WatchLv.allCases.map{$0.getName()}
        self.selectedWatchLv = Setup.WatchLv.getLv(SystemEnvironment.watchLv)?.getName()
    }
    
    private func setupWatchLv(select:String){
        guard let find = self.watchLvs?.firstIndex(where: {$0 == select}) else {return}
        self.selectedWatchLv = select
        self.repository.updateWatchLv(Setup.WatchLv.allCases[find])
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
