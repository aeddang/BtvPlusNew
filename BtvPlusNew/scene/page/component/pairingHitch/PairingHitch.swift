//
//  PairingHitch.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/27.
//

import Foundation
//
//  VoiceRecorder.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
import SwiftUI

struct PairingHitch: PageComponent {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var networkObserver:NetworkObserver
    @EnvironmentObject var locationObserver:LocationObserver
    @EnvironmentObject var pairing:Pairing
   
    var body: some View {
        ZStack(alignment: SystemEnvironment.isTablet ?.center : .bottom){
            Spacer().modifier(MatchParent()).background(Color.transparent.black45)
                .onTapGesture {
                    self.closeHitch()
                }
                
            if self.isFullConnected, let fullConnectInfo = self.fullConnectInfo {
                ZStack(){
                    ZStack(alignment: .top){
                        VStack(spacing:0){
                            Spacer()
                                .frame(height: SystemEnvironment.isTablet ? 134 : 95)
                            ZStack{
                                RetryStbBox(
                                    datas: self.stbs ,
                                    info:fullConnectInfo,
                                    selected: self.selectedDevice
                                ) {select in
                                    self.selectePairingDevice(stb: select)
                                }
                            }
                            .frame(width: SystemEnvironment.isTablet ? 446 : 329)
                            .background(Color.app.white)
                            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.heavy))
                        }
                        Image( Asset.image.pairingHitch02)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: SystemEnvironment.isTablet ? 147 : 104,
                                   height: SystemEnvironment.isTablet ? 134 : 95)
                            .padding(.leading, Dimen.margin.mediumExtra)
                    }
                }
                .modifier(MatchParent())
            } else {
                ZStack(alignment: .topLeading){
                    VStack(alignment:.leading, spacing:0){
                        Spacer()
                            .frame(height: SystemEnvironment.isTablet ? 95 : 80)
                        if SystemEnvironment.isTablet {
                            ZStack(alignment: .topTrailing){
                                if let stbs = self.stbs {
                                    SelectStbBox(
                                        datas: stbs){ select , isAgree in
                                        self.isAgreeOption = isAgree
                                        self.selectePairingDevice(stb: select)
                                    }
                                } else {
                                    SelectPairingType()
                                }
                                Button(action: {
                                    self.closeHitch()
                                    self.appSceneObserver.event = .pairingHitchClose
                                    
                                }) {
                                    Image(Asset.icon.closeBlack)
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: Dimen.icon.regularExtra,
                                               height: Dimen.icon.regularExtra)
                                }
                                .padding(.all, Dimen.margin.thin)
                            }
                            .frame(width: 446)
                            .background(Color.app.white)
                            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.heavy))
                        } else {
                            ZStack(alignment: .topTrailing){
                                if let stbs = self.stbs {
                                    SelectStbBox(
                                        datas: stbs){ select, isAgree in
                                        self.isAgreeOption = isAgree
                                        self.selectePairingDevice(stb: select)
                                    }
                                } else {
                                    SelectPairingType()
                                }
                                Button(action: {
                                    self.closeHitch()
                                    self.appSceneObserver.event = .pairingHitchClose
                                    
                                }) {
                                    Image(Asset.icon.closeBlack)
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: Dimen.icon.regularExtra,
                                               height: Dimen.icon.regularExtra)
                                }
                                .padding(.all, Dimen.margin.thin)
                            }
                            .modifier(BottomFunctionTab())
                        }
                    }
                    Image( Asset.image.pairingHitch01 )
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: SystemEnvironment.isTablet ? 207 : 176,
                               height: SystemEnvironment.isTablet ? 100 : 85)
                        .padding(.leading, Dimen.margin.mediumExtra)
                }
                .padding(.bottom, SystemEnvironment.isTablet
                            ? 0
                            : self.isAutoPairing == nil ? -400 : 0)
            }
            if self.isHitching && self.isAutoPairing == nil {
                ActivityIndicator(isAnimating: .constant(true), style: .medium)
                    .padding(.bottom, self.sceneObserver.safeAreaBottom + Dimen.margin.regular)
            }
        }
        .opacity( !self.isHitching  || self.hasPopup ? 0 : 1)
       
        .onReceive(self.networkObserver.$status){ status in
            if self.pairing.status == .pairing {return}
            switch status {
            case .wifi :
                self.isStbSearch = false
                self.initHitch()
            default : break
            }
        }
        .onReceive(self.pageObservable.$status){ status in
            if !self.isHitching {return}
            switch status {
            case .enterForeground :
                if self.isLocationRequest { self.findDevice() }
            default : break
            }
        }
        .onReceive(self.locationObserver.$event){ evt in
            if !self.isHitching {return}
            guard let evt = evt else {return}
            switch evt {
            case .updateAuthorization( _ ) : self.findDevice()
            }
            
        }
        .onReceive(self.pagePresenter.$hasPopup){ hasPop in
            withAnimation(){
                self.hasPopup = hasPop
            }
        }
        .onReceive(self.appSceneObserver.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .pairingHitch(let isOn) :
                if isOn {
                    self.initHitch()
                } else {
                    self.closeHitch()
                }
            default : break
            }
        }
        .onReceive(self.pairing.$status){ status in
            self.isPairing = status == .pairing
            if self.isPairing {
                self.closeHitch()
            }
            if !self.isPairing && self.isHitching{
                self.initHitch()
            }
           
        }
        .onReceive(self.pairing.$event){ evt in
            if !self.isHitching {return}
            guard let evt = evt else {return}
            switch evt {
            case .notFoundDevice, .findMdnsDevice, .findStbInfoDevice :
                self.findDeviceCompleted(evt: evt)
           
            case .connectError(let header) :
                if header?.result == NpsNetwork.resultCode.pairingLimited.code {
                    self.pairing.requestPairing(.hostInfo(auth: nil, device:self.selectedDevice?.stbid, prevResult: header))
                } else {
                    self.appSceneObserver.alert = .pairingError(header)
                    self.closeHitch()
                }
            case .connectErrorReason(let info) :
                if self.isFullConnected {
                    self.appSceneObserver.alert = .limitedDevice(info)
                    return
                }
                self.fullConnectInfo = info
                withAnimation{ self.isFullConnected = true }
            default : break
            }
        }
        .onDisappear(){
            
        }
    }//body
    @State var hasPopup:Bool = false
    @State var isHitching:Bool = false
    @State var isPairing:Bool = false
    @State var isLocationRequest:Bool = false
    @State var selectedDevice:StbData? = nil
    @State var isAutoPairing:Bool? = nil
    @State var isFullConnected:Bool = false
    @State var stbs:[StbData]? = nil
    @State var fullConnectInfo:PairingInfo? = nil
    @State var isAgreeOption:Bool = false
    @State var isStbSearch:Bool = false
    
    func initHitch() {
        if self.pairing.status == .pairing { return }
        if self.isHitching { return }
        
        self.isFullConnected = false
        
        if self.networkObserver.status == .wifi {
            if !self.isStbSearch {
                withAnimation{
                    self.isHitching = true
                    self.isAutoPairing = nil
                }
                self.stbs = nil
                self.findSSID()
            } else {
                if self.stbs?.isEmpty == false {
                    withAnimation{
                        self.isHitching = true
                        self.isAutoPairing = true
                    }
                } else {
                    withAnimation{
                        self.isHitching = true
                        self.isAutoPairing = false
                    }
                }
            }
            
        } else {
            self.stbs = nil
            withAnimation{
                self.isHitching = true
                self.isAutoPairing = false
            }
        }
    }
    
    func closeHitch() {
        withAnimation{
            self.isAutoPairing = nil
            self.isHitching = false
        }
        self.pairing.requestPairing(.cancel)
    }
    
    func findSSID() {
        let status = self.locationObserver.status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.findDevice()
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
    
    func findDevice() {
        self.isLocationRequest = false
        self.pairing.requestPairing(.wifi)
    }
    
    
    private func findDeviceCompleted(evt:PairingEvent){
        
        switch evt {
        case .findMdnsDevice(let findData) :
            self.isStbSearch = true
            if findData.isEmpty {
                withAnimation{ self.isAutoPairing = false }
            } else {
                self.stbs = findData.map{StbData().setData(data: $0)}
                withAnimation{ self.isAutoPairing = true }
            }
        
        case .notFoundDevice :
            self.isStbSearch = true
            withAnimation{ self.isAutoPairing = false }
        
        default : break
        }
    }
    
    private func selectePairingDevice(stb:StbData){
        self.pairing.user = User(
            nickName: "0000", characterIdx:0, gender: .mail, birth: "2000",
            isAgree1: true, isAgree2: true, isAgree3: self.isAgreeOption
        )
        self.selectedDevice = stb
        self.pairing.requestPairing(.device(stb))
    }
}


#if DEBUG
struct PairingHitch_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            PairingHitch()
        }
        .environmentObject(PagePresenter())
        .environmentObject(PageSceneObserver())
        .environmentObject(AppSceneObserver())
        .environmentObject(NetworkObserver())
        .environmentObject(LocationObserver())
        .environmentObject(Pairing())
        .frame(width: 320)
        .background(Color.brand.bg)
    }
}
#endif
