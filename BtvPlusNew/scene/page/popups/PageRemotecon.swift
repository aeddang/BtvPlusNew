//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
extension PageRemotecon {
    static let delayLock:Double = 0.1
    static let delayUpdate:Double = 0.2
}

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
                            type: .text,
                            placeHolder:String.remote.inputTextHolder,
                            inputSize: 8,
                            inputSizeMin: 1
                        ){ input, type in
                            withAnimation{
                                self.isInputText = false
                            }
                            self.remoconInput(type: type, string: input)
                        }
                    }
                    if self.isInputChannel {
                        InputRemoteBox(
                            isInit: true,
                            title: String.remote.inputChannel,
                            type: .number,
                            placeHolder:String.remote.inputChannelHolder,
                            inputSize: 3,
                            inputSizeMin: 1,
                            keyboardType: .numberPad
                        ){ input, type in
                            withAnimation{
                                self.isInputChannel = false
                            }
                            self.remoconInput(type: type, string: input)
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
                case .sendMessage(let message):
                    self.actionResult(npsMessage: message, res:res)
                default: break
                }
            }
            .onReceive(dataProvider.$error) { err in
                guard let err = err else { return }
                if err.id != self.tag { return }
                switch err.type {
                case .sendMessage(let message) :
                    self.actionError(npsMessage: message, err: err)
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
    
    @State var isActionLock:Bool = false
    private func action(evt:RemoteConEvent) {
        if isActionLock {
            self.appSceneObserver.event = .toast(String.remote.searchLock)
            return
        }
        guard let host = self.pairing.hostDevice else {
            self.appSceneObserver.alert =
                .alert(String.alert.notPairing, String.alert.notPairingText)
            return
        }
        self.isActionLock = true
        var needUpdate:Bool = false
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
        case .toggleOn:
            self.sendAction(npsMessage: NpsMessage().setMessage(type: .PowerCtrl))
            needUpdate = true
        case .multiview:
            if host.isEnablePIPKey() {
                self.sendAction(npsMessage: NpsMessage().setMessage(type: .PIP))
            }else {
                self.appSceneObserver.event = .toast(String.alert.guideNotSupported)
            }
        case .chlist:
            if host.isEnableGuideKey() {
                self.sendAction(npsMessage: NpsMessage().setMessage(type: .Guide))
            }else {
                self.appSceneObserver.event = .toast(String.alert.guideNotSupported)
            }
        case .fastForward:
            self.sendAction(npsMessage: NpsMessage().setMessage(type: .PlayCtrl, value: .FF))
        case .rewind:
            self.sendAction(npsMessage: NpsMessage().setMessage(type: .PlayCtrl, value: .REW))
        case .playControl(let playEvt) :
            switch playEvt {
            case .togglePlay:
                self.sendAction(npsMessage: NpsMessage().setMessage(type: .PlayCtrl, value: .Play))
            case .next:
                self.sendAction(npsMessage: NpsMessage().setMessage(type: .PlayCtrl, value: .Next))
            case .prev:
                self.sendAction(npsMessage: NpsMessage().setMessage(type: .PlayCtrl, value: .Prev))
            }
        case .control(let conEvt):
            switch conEvt {
            case .ok:
                self.sendAction(npsMessage: NpsMessage().setMessage(type: .Ok))
                needUpdate = true
            case .left:
                self.sendAction(npsMessage: NpsMessage().setMessage(type: .Left))
            case .right:
                self.sendAction(npsMessage: NpsMessage().setMessage(type: .Right))
            case .up:
                self.sendAction(npsMessage: NpsMessage().setMessage(type: .Up))
            case .down:
                self.sendAction(npsMessage: NpsMessage().setMessage(type: .Down))
            }
        case .volumeMove(let v) :
            self.sendAction(npsMessage: NpsMessage().setMessage(type: v>0 ? .VOLUp : .VOLDown))
        case .channelMove(let c) :
            self.sendAction(npsMessage: NpsMessage().setMessage(type: c>0 ? .CHUp : .CHDown))
            needUpdate = true
        case .exit :
            if host.isEnableExitKey() {
                self.sendAction(npsMessage: NpsMessage().setMessage(type: .ButtonExit))
                needUpdate = true
            }else {
                self.appSceneObserver.event = .toast(String.alert.guideNotSupported)
            }
        case .previous :
            self.sendAction(npsMessage: NpsMessage().setMessage(type: .ButtonCancel))
            needUpdate = true
        case .home :
            self.sendAction(npsMessage: NpsMessage().setMessage(type: .ButtonHome))
            needUpdate = true
        case .mute(let isMute) :
            if isMute {
                self.sendAction(npsMessage: NpsMessage().setMessage(type: .Mute))
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.delayLock) {
            self.isActionLock = false
        }
        if needUpdate {
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.delayUpdate) {
                self.checkHostDeviceStatus()
            }
        }
    }
    
    private func remoconInput(type: RemoteInputType, string: String?) {
        guard let string = string else { return }
        if string.isEmpty { return }
        guard let host = self.pairing.hostDevice else {
            self.appSceneObserver.alert =
                .alert(String.alert.notPairing, String.alert.notPairingText)
            return
        }
        var ctrl:NpsCtrlType = .NumInput
        var value = string
        
        switch type {
        case .number:
            value = String(Int(string) ?? 0)
            if host.isEnableStringInput() {
                ctrl = .CHNumInput
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.delayUpdate) {
                self.checkHostDeviceStatus()
            }
        case .text:
            if host.isEnableStringInput() {
                ctrl = .StrInput
            }
        }
        self.sendAction(npsMessage: NpsMessage().setMessage(type: ctrl, value: value))
        
    }
    
    private func sendAction(npsMessage:NpsMessage) {
        self.dataProvider.requestData(
            q: .init(id: self.tag, type: .sendMessage(npsMessage))
        )
    }
    private func actionResult(npsMessage:NpsMessage?, res:ApiResultResponds) {
        guard let npsMessage = npsMessage else { return }
        switch npsMessage.ctrlType {
        case .Refresh:
            self.checkBroadcast(res: res)
         default:
            break
        }
    }
    
    private func actionError(npsMessage:NpsMessage?, err:ApiResultError) {
        guard let npsMessage = npsMessage else { return }
        switch npsMessage.ctrlType {
        case .Refresh:
            self.remotePlayData =  RemotePlayData(isError: true)
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
