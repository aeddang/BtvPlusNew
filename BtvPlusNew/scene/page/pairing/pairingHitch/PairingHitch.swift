//
//  PairingHitch.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/27.
//

import Foundation
import SwiftUI
import Combine

struct PairingHitch: PageComponent {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var networkObserver:NetworkObserver
    @EnvironmentObject var locationObserver:LocationObserver
    @EnvironmentObject var naviLogManager:NaviLogManager
    @EnvironmentObject var pairing:Pairing
   
    var body: some View {
        ZStack(alignment: SystemEnvironment.isTablet ?.center : .bottom){
            
            Spacer().modifier(MatchParent()).background(Color.transparent.black45)
                .onTapGesture {
                    self.closeHitch(sendLog: true)
                    self.appSceneObserver.event = .pairingHitchClose
                }
                .opacity(self.isAutoPairing == nil ? 0 : 1)
                
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
                                    selected: self.selectedDevice,
                                    select: {select in
                                        self.selectedDevice = select
                                    },
                                    action:{select in
                                        self.selectePairingDevice(stb: select)
                                    },
                                    close:{
                                        self.closeHitch(sendLog: true)
                                    }
                                )
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
                                .padding(.all, Dimen.margin.tinyUltra)
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
                                    self.closeHitch(sendLog: true)
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
                    .padding(.bottom, self.sceneObserver.safeAreaIgnoreKeyboardBottom + Dimen.margin.regular)
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
                } else if self.isHitching{
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
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            switch res.type {
            case .getHostNickname :
                guard let data = res.data as? HostNickName else { return }
                self.syncFindDeviceNickName(host: data)
            default: break
            }
           
        }
        .onReceive(self.pairing.$event){ evt in
            if !self.isHitching || self.hasPopup {return}
            guard let evt = evt else {return}
            switch evt {
            case .notFoundDevice, .findMdnsDevice, .findStbInfoDevice :
                DispatchQueue.main.async {
                    self.findDeviceCompleted(evt: evt)
                }
            
            case .connectError(let header, let failStbId) :
                if header?.result == NpsNetwork.resultCode.pairingLimited.code {
                    self.pairing.requestPairing(.hostInfo(auth: nil, device:failStbId ?? self.selectedDevice?.stbid, prevResult: header))
                } else {
                    let msg = NpsNetwork.getConnectErrorMeassage(data: header)
                    self.appSceneObserver.event =
                        .toast(String.alert.limitedDeviceSimple.replace(msg))
                    self.closeHitch()
                }
            case .connectErrorReason(let info) :
                if self.isFullConnected {
                    self.sendLog(action: .clickConfirmButton, category: "확인")
                    self.appSceneObserver.event =
                        .toast(String.alert.limitedDeviceSimple.replace(info?.count?.description ?? ""))
                    return
                }
                if self.stbs?.count ?? 0  <= 1 {
                    self.appSceneObserver.event =
                        .toast(String.alert.limitedDeviceSimple.replace(info?.count?.description ?? ""))
                    self.closeHitch()
                    
                } else {
                    self.fullConnectInfo = info
                    withAnimation{ self.isFullConnected = true }
                    self.sendLog(action: .pageShow)
                }
               
            default : break
            }
        }
        .onAppear(){
            
        }
        .onDisappear(){
            self.pairing.requestPairing(.cancel)
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
    
    func closeHitch(sendLog:Bool = false) {
        withAnimation{
            self.isAutoPairing = nil
            self.isHitching = false
        }
        self.pairing.requestPairing(.cancel)
        if sendLog {
            self.sendLog(action: .clickCloseButton)
        }
    }
    
    func findSSID() {
        self.findDevice()
        /*
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
        }*/
    }
    
    func findDevice() {
        self.isLocationRequest = false
        self.pairing.requestPairing(.wifi(retryCount:0))
    }
    
    private func syncFindDeviceNickName(host:HostNickName) {
        guard let stbs = self.stbs else { return }
        stbs.forEach{ stb in
            if let find = host.stbList?.first(where: {$0.joined_stb_id == stb.stbid}) {
                stb.stbNickName = find.joined_stb_id
            }
        }
    }
    
    private func findDeviceCompleted(evt:PairingEvent){
        switch evt {
        case .findMdnsDevice(let findData) :
            self.isStbSearch = true
            if findData.isEmpty {
                withAnimation{ self.isAutoPairing = false }
                self.sendLog(action: .pageShow)
            } else {
                let stbs = findData.map{StbData().setData(data: $0)}
                self.stbs = stbs
                withAnimation{ self.isAutoPairing = true }
                self.sendLog(action: .pageShow)
                stbs.forEach { stb in
                    self.dataProvider.requestData(
                        q: .init(type: .getHostNickname(isAll:false, anotherStbId: stb.stbid), isOptional: true))
                }
                
            }
        
        case .notFoundDevice :
            self.isStbSearch = true
            withAnimation{ self.isAutoPairing = false }
            self.sendLog(action: .pageShow)
        default : break
        }
    }
    
    private func selectePairingDevice(stb:StbData){
        self.pairing.user = User().setDefault(isAgree: self.isAgreeOption)
        self.selectedDevice = stb
        self.pairing.requestPairing(.device(stb))
    }
    
    private func sendLog(action:NaviLog.Action,  category:String? = nil) {
        var actionBody = MenuNaviActionBodyItem()
        let config = self.isFullConnected
                    ? "case3"
                    : self.isAutoPairing == true
                        ?  self.stbs?.count == 1 ? "case1" : "case2"
                        : "case4"
        actionBody.config = config
        if config == "case2" {
            actionBody.target = (self.stbs?.count ?? 0).description
        }
        
        actionBody.category = category
        actionBody.target = (self.stbs?.count ?? 0).description
        self.naviLogManager.actionLog(action, pageId: .autoPairing, actionBody: actionBody)
        
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
