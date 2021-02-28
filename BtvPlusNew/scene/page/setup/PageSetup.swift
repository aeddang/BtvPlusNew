//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct PageSetup: PageView {
    @EnvironmentObject var setup:Setup
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
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
                                        isOn: .constant(true),
                                        title: String.pageText.setupCertificationAge,
                                        subTitle: String.pageText.setupCertificationAgeText,
                                        radios: nil,
                                        selected: { select in
                                            
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
                                }
                                .background(Color.app.blueLight)
                            }
                        }
                        .padding(.vertical, Dimen.margin.medium)
                       
                    }
                    .modifier(ContentHorizontalEdges())
                    .modifier(MatchParent())
                }
                .highPriorityGesture(
                    DragGesture(minimumDistance: PageDragingModel.MIN_DRAG_RANGE, coordinateSpace: .local)
                        .onChanged({ value in
                            self.pageDragingModel.uiEvent = .drag(geometry, value)
                        })
                        .onEnded({ _ in
                            self.pageDragingModel.uiEvent = .draged(geometry)
                        })
                )
                .gesture(
                    self.pageDragingModel.cancelGesture
                        .onChanged({_ in self.pageDragingModel.uiEvent = .dragCancel})
                        .onEnded({_ in self.pageDragingModel.uiEvent = .dragCancel})
                )
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
                    self.pageSceneObserver.event = .toast(
                        self.isDataAlram ? String.alert.dataAlramOn : String.alert.dataAlramOff
                    )
                    
                }
                
            }
            .onReceive( [self.isAutoRemocon].publisher ) { value in
                if !self.isInitate { return }
                if self.setup.autoRemocon == self.isAutoRemocon { return }
                if self.isPairing == false && value == true {
                    self.pageSceneObserver.alert = .needPairing()
                    self.isAutoRemocon = false
                    return
                }
                self.setup.autoRemocon = self.isAutoRemocon
                self.pageSceneObserver.event = .toast(
                    self.isAutoRemocon ? String.alert.autoRemoconOn : String.alert.autoRemoconOff
                )
                
            }
            .onReceive( [self.isRemoconVibration].publisher ) { value in
                if !self.isInitate { return }
                if self.setup.remoconVibration == self.isRemoconVibration { return }
                if self.isPairing == false && value == true {
                    self.pageSceneObserver.alert = .needPairing()
                    self.isRemoconVibration = false
                    return
                }
                self.setup.remoconVibration = self.isRemoconVibration
                self.pageSceneObserver.event = .toast(
                    self.isRemoconVibration ? String.alert.remoconVibrationOn : String.alert.remoconVibrationOff
                )
                
            }
            .onReceive( [self.isAutoPlay].publisher ) { value in
                if !self.isInitate { return }
                if self.setup.autoPlay == self.isAutoPlay { return }
                self.setup.autoPlay = self.isAutoPlay
                self.pageSceneObserver.event = .toast(
                    self.isAutoPlay ? String.alert.autoPlayOn : String.alert.autoPlayOff
                )
                
            }
            .onReceive( [self.isNextPlay].publisher ) { value in
                if !self.isInitate { return }
                if self.setup.nextPlay == self.isNextPlay { return }
                self.setup.nextPlay = self.isNextPlay
                self.pageSceneObserver.event = .toast(
                    self.isNextPlay ? String.alert.nextPlayOn : String.alert.nextPlayOff
                )
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
    }
    
    
}

#if DEBUG
struct PageSetup_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageSetup().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(SceneObserver())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(Pairing())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
