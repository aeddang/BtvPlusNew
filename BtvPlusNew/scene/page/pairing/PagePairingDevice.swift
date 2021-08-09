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
    @State var sceneOrientation: SceneOrientation = .portrait
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
                            marginBottom:self.sceneObserver.safeAreaBottom,
                            useTracking:self.useTracking
                            
                        ){
                            
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
                            .modifier(ListRowInset(
                                        marginHorizontal:self.sceneOrientation == .landscape ? Dimen.margin.heavy : Dimen.margin.regular,
                                        spacing: 0))
                            //.padding(.horizontal, self.sceneOrientation == .landscape ? Dimen.margin.heavy : Dimen.margin.regular)
                            if !self.datas.isEmpty {
                                StbList(datas: self.datas){ stb in
                                    self.selectePairingDevice(stb: stb)
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
                case .notFoundDevice, .findMdnsDevice, .findStbInfoDevice :
                    if !self.isReady { return }
                    self.findDeviceCompleted(evt: evt)
                case .connected :
                    self.pagePresenter.closePopup(self.pageObject?.id)
                case .connectError(let header) :
                    if header?.result == NpsNetwork.resultCode.pairingLimited.code {
                        self.pairing.requestPairing(.hostInfo(auth: nil, device:self.selectedDevice?.stbid, prevResult: header))
                    } else {
                        self.appSceneObserver.alert = .pairingError(header)
                    }
                case .connectErrorReason(let info) :
                    self.appSceneObserver.alert = .limitedDevice(info)
                default : do{}
                }
            }
            .onReceive(self.sceneObserver.$isUpdated){ _ in
                self.sceneOrientation = self.sceneObserver.sceneOrientation
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.useTracking = ani
                if ani {
                    self.pageInit()
                }
            }
            .onAppear{
                self.sceneOrientation = self.sceneObserver.sceneOrientation
                guard let obj = self.pageObject  else { return }
                self.pairingType = (obj.getParamValue(key: .type) as? PairingRequest) ?? self.pairingType
            }
            .onDisappear{
                self.pairing.requestPairing(.cancel)
            }
            
        }//geo
    }//body
    
    func pageInit() {
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
    
    @State var isLocationRequest:Bool = false
    @State var selectedDevice:StbData? = nil
    func findSSID() {
        let status = self.locationObserver.status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.updateSSID()
        } else if status == .denied {
            self.isLocationRequest = true
            self.appSceneObserver.alert = .requestLocation{ retry in
                if retry { AppUtil.goLocationSettings() }
                else { self.findDevice() }
            }
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
            if self.datas.count == 1{
                self.selectePairingDevice(stb: self.datas.first!)
            }
        }
        case .findStbInfoDevice(let findData) : do {
            self.datas = findData.filter{$0.status_code != 2}.map{StbData().setData(data: $0)}
            self.textAvailableDevice = String.pageText.pairingDeviceText3 + self.datas.count.description + String.pageText.pairingDeviceText4
            
            if self.datas.count == 1{
                self.selectePairingDevice(stb: self.datas.first!)
            }
        }
        case .notFoundDevice : do {
            self.datas = []
            self.textAvailableDevice = ""
            switch self.pairingType {
            case .user:
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.pairingEmptyDevice)
                        .addParam(key: .title, value: self.title)
                        .addParam(key: .text, value: String.alert.userCertificationNeedPairing)
                )
                self.pagePresenter.closePopup(self.pageObject?.id)
                break
            default:
                self.appSceneObserver.alert = .notFoundDevice{ retry in
                    if retry { self.findDevice() }
                    else { self.pagePresenter.closePopup(self.pageObject?.id) }
                }
            }
        }
        default : do {}
        }
    }
    
    private func selectePairingDevice(stb:StbData){
        self.selectedDevice = stb
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
