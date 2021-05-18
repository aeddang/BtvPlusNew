//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI


struct PageRemotecon: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var networkObserver:NetworkObserver
    @EnvironmentObject var locationObserver:LocationObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()

    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                ZStack(alignment: SystemEnvironment.isTablet ?.center : .top){
                    if let isPairing = self.isPairing {
                        if isPairing  {
                            if SystemEnvironment.isTablet {
                                ZStack{
                                    Image(Asset.remote.bg)
                                        .renderingMode(.original).resizable()
                                        .modifier(MatchParent())
                                    RemoteCon(
                                        data:self.remotePlayData,
                                        isEarPhone: self.isAudioMirroring
                                    ){ evt in
                                        self.action(evt: evt)
                                    }
                                }
                                .frame(
                                    width:  RemoteStyle.ui.size.width,
                                    height:  RemoteStyle.ui.size.height)
                                
                            } else {
                                VStack( spacing: 0 ){
                                    Spacer()
                                        .modifier(MatchHorizontal(height: self.sceneObserver.safeAreaTop))
                                        .background(Color.app.blackExtra)
                                    Image(Asset.remote.bg)
                                        .renderingMode(.original).resizable()
                                        .modifier(MatchHorizontal(height: RemoteStyle.ui.size.height))
                                    Spacer()
                                        .modifier(MatchParent())
                                        .background(Color.app.blackExtra)
                                }
                                .modifier(MatchParent())
                                RemoteCon(
                                    data:self.remotePlayData,
                                    isEarPhone: self.isAudioMirroring
                                ){ evt in
                                    self.action(evt: evt)
                                }
                                .padding(.top, self.sceneObserver.safeAreaTop)
                            }
                        } else {
                            EmptyAlert(text: String.alert.pairingError){
                                self.pagePresenter.closePopup(self.pageObject?.id)
                            }
                        }
                        
                    } else {
                        Spacer().modifier(MatchParent())
                    }
                    if self.isInputText {
                        InputRemoteBox(
                            isInit: true,
                            title: String.remote.inputText,
                            placeHolder:String.remote.inputTextHolder,
                            inputSize: 8,
                            inputSizeMin: 1
                        ){ input in
                            withAnimation{
                                self.isInputText = false
                            }
                        }
                    }
                    if self.isInputChannel {
                        InputRemoteBox(
                            isInit: true,
                            title: String.remote.inputChannel,
                            placeHolder:String.remote.inputChannelHolder,
                            inputSize: 3,
                            inputSizeMin: 1,
                            keyboardType: .numberPad
                        ){ input in
                            withAnimation{
                                self.isInputChannel = false
                            }
                        }
                    }
                }
                .modifier(MatchParent())
                .background(Color.transparent.black70)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//draging
            .onReceive(self.pairing.$event){evt in
                guard let _ = evt else {return}
                switch evt {
                case .pairingCompleted :
                    self.isPairing = true
                    self.checkHostDeviceStatus()
                    
                case .disConnected : self.isPairing = false
                case .pairingCheckCompleted(let isSuccess) :
                    if isSuccess { self.isPairing = true }
                    else { self.isPairing = false }
                    self.checkHostDeviceStatus()
                default : do{}
                }
            }
            .onReceive(self.dataProvider.broadcasting.$currentProgram){program in
                guard let program = program else {
                    self.remotePlayData =  RemotePlayData(isEmpty: true)
                    return
                }
                self.updatedProgram(program)
            }
            .onReceive(self.dataProvider.broadcasting.$status){status in
                switch status {
                case .loading : break
                case .empty : self.remotePlayData =  RemotePlayData(isEmpty: true)
                case .error: self.remotePlayData =  RemotePlayData(isError: true)
                default: break
                }
            }
            .onReceive(self.repository.audioMirrorManager.$event){evt in
                guard let evt = evt  else {return}
                switch evt {
                case .dicconnected :
                    self.appSceneObserver.event = .toast(String.remote.closeMirroring)
                case .connected :
                    self.appSceneObserver.loadingInfo = nil
                    self.appSceneObserver.event = .toast(String.remote.setupMirroring)
                case .notFound :
                    self.appSceneObserver.loadingInfo = nil
                    self.appSceneObserver.alert =
                        .alert(String.remote.errorMirroring, String.remote.errorMirroringText, String.remote.errorMirroringTextSub)
                default: break
                }
            }
            .onReceive(self.repository.audioMirrorManager.$status){status in
                if self.isAudioMirroring == nil {return}
                switch status {
                case .mirroring : self.isAudioMirroring = true
                case .none : self.isAudioMirroring = false
                default: break
                }
            }
            .onReceive(dataProvider.$result) { res in
                guard let res = res else { return }
                if res.id != self.tag { return }
                switch res.type {
                case .sendMessage :
                    self.checkBroadcast(res: res)
                default: break
                }
            }
            .onReceive(dataProvider.$error) { err in
                guard let err = err else { return }
                if err.id != self.tag { return }
                switch err.type {
                case .sendMessage :
                    self.remotePlayData =  RemotePlayData(isError: true)
                default: break
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.isUIReady = ani
                self.checkHostDeviceStatus()
            }
            .onReceive(self.locationObserver.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .updateAuthorization( _ ) : self.connectEarphone()
                }
                
            }
            .onAppear{
                self.pairing.requestPairing(.check)
                self.dataProvider.broadcasting.reset()
                if self.repository.audioMirrorManager.isAudioMirrorSupported {
                    self.isAudioMirroring = self.repository.audioMirrorManager.isConnected
                } else {
                    self.isAudioMirroring = nil
                }
            }
            .onDisappear{
                self.repository.audioMirrorManager.close()
            }
            
        }//geo
    }//body
    
    @State var isPairing:Bool? = nil
    @State var isInputText:Bool = false
    @State var isInputChannel:Bool = false
    @State var isUIReady:Bool = false
    @State var isAudioMirroring:Bool? = nil
    @State var remotePlayData:RemotePlayData? = nil
    
    private func checkHostDeviceStatus(){
        if !self.isUIReady {return}
        if self.isPairing != true {return}
        self.dataProvider.requestData(
            q: .init(id: self.tag, type: .sendMessage(NpsMessage().setMessage(type: .Refresh)), isOptional: true)
        )
    }
    
    private func checkBroadcast(res:ApiResultResponds){
        guard let result = res.data as? ResultMessage else { return }
        if result.header?.result != ApiCode.success { return }
        guard let message =  result.body?.message else { return }
        guard let type = message.SvcType else { return }
        
        switch type {
        case "VOD":
            self.dataProvider.broadcasting.requestBroadcast(.updateCurrentVod(message.CurCID))
        case "IPTV":
            if message.CurChNum == "0" {
                self.remotePlayData =  RemotePlayData(isEmpty: true)
                return
            }
            self.dataProvider.broadcasting.requestBroadcast(.updateCurrentBroadcast)
            self.dataProvider.broadcasting.updateChannelNo(message.CurChNum)
        default:
            self.remotePlayData =  RemotePlayData(isEmpty: true)
        }
    }
    
    private func updatedProgram(_ pro:BroadcastProgram){
        
        let isLock = !SystemEnvironment.isImageLock ? false : pro.isAdult
        if pro.isOnAir {
            let d = pro.endTime - pro.startTime
            let c = Double(Date().timeIntervalSince1970) - pro.startTime
            self.remotePlayData =  RemotePlayData(
                progress: Float(c/d),
                title: !isLock ? pro.title : String.app.lockAdultProgram,
                subTitle: pro.channel,
                subText: (pro.startTimeStr ?? "") + "~" + (pro.endTimeStr ?? ""),
                restrictAgeIcon: pro.restrictAgeIcon,
                isOnAir: true)
        } else {
            self.remotePlayData =  RemotePlayData(
                title: !isLock ? pro.title : String.app.lockAdultProgram,
                subText: pro.duration,
                restrictAgeIcon: pro.restrictAgeIcon,
                isOnAir: false)
        }
    }
    
    private func action(evt:RemoteConEvent) {
        switch evt {
        case .close:
            self.pagePresenter.closePopup(self.pageObject?.id)
        case .reflash:
            self.checkHostDeviceStatus()
        case .inputMessage:
            withAnimation{ self.isInputText = true }
        case .inputChannel:
            withAnimation{ self.isInputChannel = true }
        case .earphone:
            self.connectEarphone()
        default:
            break
        }
    }
    
    
    private func connectEarphone(){
        if self.networkObserver.status != .wifi {
            self.appSceneObserver.alert = .connectWifi{ retry in
                if retry { self.connectEarphone() }
            }
            return
        }
        let status = self.locationObserver.status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            let manager = self.repository.audioMirrorManager
            if manager.isSkWifi && manager.isAudioMirrorSupported {
                self.appSceneObserver.loadingInfo = [
                    String.remote.searchMirroring
                ]
                manager.startSearching()
                
            } else {
                self.appSceneObserver.alert =
                    .alert(String.remote.errorMirroringWifi, String.remote.errorMirroringWifiText)
            }
        } else if status == .denied {
            self.appSceneObserver.alert = .requestLocation{ retry in
                if retry { AppUtil.goLocationSettings() }
            }
        } else {
            self.locationObserver.requestWhenInUseAuthorization()
        }
        
    }
   
}

#if DEBUG
struct PageRemotecon_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            PageRemotecon().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(KeyboardObserver())
                .environmentObject(Pairing())
                .frame(width: 360, height: 680, alignment: .center)
        }
    }
}
#endif
