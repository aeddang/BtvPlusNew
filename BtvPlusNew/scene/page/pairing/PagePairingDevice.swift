//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
import CoreLocation

struct PagePairingDevice: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var networkObserver:NetworkObserver
    @EnvironmentObject var locationObserver:LocationObserver
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @State var title:String? = nil
    @State var pairingType:PairingRequest = .wifi
    
    @State var textAvailableDevice:String = ""
    @State var textAvailableWifi:String? = nil
    @State var datas:[StbData] = []
    
    @State var isReady:Bool = false
    @State var useTracking:Bool = false
   
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: self.title,
                        isClose: true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    ZStack(alignment: .topLeading){
                        DragDownArrow(
                            infinityScrollModel: self.infinityScrollModel)
                        InfinityScrollView(
                            viewModel: self.infinityScrollModel,
                            useTracking:self.useTracking){
                            
                            VStack(alignment:.leading , spacing:0) {
                                Text(String.pageText.pairingDeviceText1)
                                    .modifier(MediumTextStyle( size: Font.size.bold ))
                                    .padding(.top, Dimen.margin.light)
                                    .fixedSize(horizontal: false, vertical:true)
                                if self.textAvailableWifi != nil {
                                    Text(self.textAvailableWifi!)
                                        .modifier(MediumTextStyle( size: Font.size.light, color: Color.brand.thirdly ))
                                        .padding(.top, Dimen.margin.medium)
                                }
                                HStack{
                                    Spacer()
                                    Text(self.textAvailableDevice)
                                        .modifier(MediumTextStyle( size: Font.size.thin ))
                                        .padding(.top, Dimen.margin.heavy)
                                }
                            }
                            .padding(.horizontal, Dimen.margin.regular)
                            StbList(datas: self.datas){ stb in
                                self.selectePairingDevice(stb: stb)
                            }
                            .padding(.top, Dimen.margin.heavy)
                        }
                    }
                    .background(Color.brand.bg)
                    .modifier(MatchParent())
                }
                .modifier(PageFull())
                .highPriorityGesture(
                    DragGesture(minimumDistance: PageDragingModel.MIN_DRAG_RANGE, coordinateSpace: .local)
                        .onChanged({ value in
                            self.pageDragingModel.uiEvent = .drag(geometry, value)
                        })
                        .onEnded({ value in
                            self.pageDragingModel.uiEvent = .draged(geometry, value)
                        })
                )
                .gesture(
                    self.pageDragingModel.cancelGesture
                        .onChanged({_ in self.pageDragingModel.uiEvent = .dragCancel})
                        .onEnded({_ in self.pageDragingModel.uiEvent = .dragCancel})
                )
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
                .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                    self.useTracking = ani
                }
            }
            .onReceive(self.pairing.$event){ evt in
                if !self.isReady { return }
                guard let evt = evt else { return }
                self.findDeviceCompleted(evt: evt)
            }
            .onReceive(self.networkObserver.$status){ status in
                if !self.isReady { return }
                if self.pairingType != .wifi { return } 
                switch status {
                case .wifi :
                    self.appSceneObserver.alert = .cancel
                    self.findSSID()
                default :
                    self.textAvailableWifi = String.alert.connectWifi
                }
            }
            .onReceive(self.appSceneObserver.$alertResult){ result in
                guard let result = result else {return}
                switch result {
                case .retry(let alert) :
                    if alert == .notFoundDevice {self.findDevice()}
                    if alert == .requestLocation { AppUtil.goLocationSettings() }
                case .cancel(let alert) :
                    if alert == .notFoundDevice {self.pagePresenter.goBack()}
                    if alert == .requestLocation { self.findDevice() }
                default : do{}
                }
            }
            .onReceive(self.pageObservable.$status){ status in
                switch status {
                case .enterForeground :
                    if self.isLocationRequest { self.updateSSID() }
                default : do{}
                }
            }
            .onReceive(self.locationObserver.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .updateAuthorization( _ ) : self.updateSSID()
                }
                
            }
            .onReceive(self.pairing.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .connected :
                    self.pagePresenter.closePopup(self.pageObject?.id)
                case .connectError(let header) :
                    self.appSceneObserver.alert = .pairingError(header)
                default : do{}
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                self.pairingType = (obj.getParamValue(key: .type) as? PairingRequest) ?? self.pairingType

                switch self.pairingType {
                case .user :
                    self.title = String.pageTitle.connectCertificationUser
                    self.findDevice()
                case .wifi :
                    self.title = String.pageTitle.connectWifi
                    self.findSSID()
                default : do{}
                }

                self.isReady = true
               
            }
            .onDisappear{
                self.pairing.requestPairing(.cancel)
            }
            
        }//geo
    }//body
    
    func getMyStbDevice(cid:String) {
        
    }
    
    @State var isLocationRequest:Bool = false
    func findSSID() {
        let status = self.locationObserver.status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.updateSSID()
        } else if status == .denied {
            self.isLocationRequest = true
            self.appSceneObserver.alert = .requestLocation
        } else {
            self.locationObserver.requestWhenInUseAuthorization()
        }
    }
    
    func updateSSID() {
        self.isLocationRequest = false
        AppUtil.getNetworkInfo(compleationHandler: { info in
            if let ssid = info["SSID"] as? String {
                self.textAvailableWifi = String.pageText.pairingDeviceText2 + ssid
            } else {
                self.textAvailableWifi = ""
            }
        })
        self.findDevice()
    }
    
    private func findDevice(){
        self.appSceneObserver.loadingInfo = [
            String.alert.findDevice,
            String.alert.findDeviceSub
        ]
        switch  self.pairingType {
        case .wifi, .user:
            self.pairing.requestPairing(self.pairingType)
        default: do{}
        }
    }
    
    private func findDeviceCompleted(evt:PairingEvent){
        self.appSceneObserver.loadingInfo = nil
        
        switch evt {
        case .findMdnsDevice(let findData) : do {
            self.datas = findData.map{StbData().setData(data: $0)}
            self.textAvailableDevice = String.pageText.pairingDeviceText3 + self.datas.count.description + String.pageText.pairingDeviceText4
        }
        case .findStbInfoDevice(let findData) : do {
            self.datas = findData.map{StbData().setData(data: $0)}
            self.textAvailableDevice = String.pageText.pairingDeviceText3 + self.datas.count.description + String.pageText.pairingDeviceText4
        }
        case .notFoundDevice : do {
            self.datas = []
            self.textAvailableDevice = ""
            self.appSceneObserver.alert = .notFoundDevice
        }
        default : do {}
        }
    }
    
    private func selectePairingDevice(stb:StbData){
        self.pairing.requestPairing(.device(stb))
    }
    
}



#if DEBUG
struct PagePairingDevice_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePairingDevice().contentBody
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
