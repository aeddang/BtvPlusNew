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
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
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
                        title: self.$title,
                        isClose: true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
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
                                    .modifier(MediumTextStyle( size: Font.size.light ))
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
                        StbList(datas: self.$datas){ stb in
                            
                        }
                        .padding(.top, Dimen.margin.heavy)
                        
                    }
                    .modifier(PageFull())
                    .modifier(MatchParent())
                    
                }
                .modifier(PageFull())
                .highPriorityGesture(
                    DragGesture(minimumDistance: 20, coordinateSpace: .local)
                        .onChanged({ value in
                            self.pageDragingModel.uiEvent = .drag(geometry, value)
                        })
                        .onEnded({ _ in
                            self.pageDragingModel.uiEvent = .draged(geometry)
                        })
                )
                .onReceive(self.infinityScrollModel.$event){evt in
                    guard let evt = evt else {return}
                    switch evt {
                    case .down, .up :
                        self.pageDragingModel.uiEvent = .dragCancel(geometry)
                    case .pullCancel :
                        self.pageDragingModel.uiEvent = .pulled(geometry)
                    default : do{}
                    }
                }
                .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                    self.pageDragingModel.uiEvent = .pull(geometry, pos)
                }
            }
            .onReceive(self.pairing.$event){ evt in
                if !self.isReady { return }
                guard let evt = evt else { return }
                switch evt {
                case .findMdnsDevice(let findData) : do {
                    self.datas = findData.map{StbData().setData(data: $0)}
                    self.textAvailableDevice = String.pageText.pairingDeviceText3 + self.datas.count.description + String.pageText.pairingDeviceText4 
                }
                case .notFoundDevice : do {
                    self.datas = []
                    self.textAvailableDevice = ""
                    self.pageSceneObserver.alert = .notFoundDevice
                }
                default : do {}
                }
            }
            .onReceive(self.networkObserver.$status){ status in
                if !self.isReady { return }
                if self.pairingType != .wifi { return }
                switch status {
                case .wifi :
                    self.textAvailableWifi = String.pageText.pairingDeviceText2 + self.networkObserver.reachability.connection.description
                    self.findDevice()
                    
                default :
                    self.textAvailableWifi = String.alert.connectWifi
                }
            }
            .onReceive(self.pageSceneObserver.$alertResult){ result in
                guard let result = result else {return}
                switch result {
                case .retry(let alert) :
                    if alert == .notFoundDevice {self.findDevice()}
                case .cancel(let alert) :
                    if alert == .notFoundDevice {self.pagePresenter.goBack()}
                default : do{}
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.useTracking = ani
            }
            .onReceive(self.pageObservable.$status){ status in
                switch status {
                case .enterForeground :
                    if self.isLocationRequest { self.findSSID() }
                default : do{}
                }
            }
            .onReceive(self.locationObserver.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .updateAuthorization(let auth) :
                    if auth == .authorizedWhenInUse || auth == .authorizedAlways { self.updateSSID() }
                default : do{}
                }
                
            }
            
            .onAppear{
                guard let obj = self.pageObject  else { return }
                self.pairingType = (obj.getParamValue(key: .type) as? PairingRequest) ?? self.pairingType
                
                switch self.pairingType {
                case .user :
                    self.title = String.pageTitle.connectCertificationUser
            
                case .wifi :
                    self.title = String.pageTitle.connectWifi
                    self.findDevice()
                default : do{}
                }
                self.isReady = true
                self.findSSID()
            }
            
            .onDisappear{
                self.pairing.requestPairing(.cancel)
            }
            
        }//geo
    }//body
    
    @State var isLocationRequest:Bool = false
    func findSSID() {
        let status = self.locationObserver.status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.updateSSID()
        } else if status == .denied {
            self.isLocationRequest = true
        } else {
            self.locationObserver.requestWhenInUseAuthorization()
        }
    }
    
    func updateSSID() {
        self.isLocationRequest = false
        if let ssid = AppUtil.getSSID(){
            self.textAvailableWifi = String.pageText.pairingDeviceText2 + ssid
        } else {
            self.textAvailableWifi = ""
        }
    }
    
    private func findDevice(){
        switch  self.pairingType {
        case .wifi:
            self.pairing.requestPairing(.wifi)
        case .user:do{}
        default: do{}
        }
        
    }

}



#if DEBUG
struct PagePairingDevice_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePairingDevice().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(SceneObserver())
                .environmentObject(PageSceneObserver())
                .environmentObject(NetworkObserver())
                .environmentObject(Pairing())
                .frame(width: 400, height: 640, alignment: .center)
        }
    }
}
#endif
