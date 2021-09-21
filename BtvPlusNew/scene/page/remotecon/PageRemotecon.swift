//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
import MediaPlayer
extension PageRemotecon {
    static let delayLock:Double = 0.2
    static let delayUpdate:Double = 0.3
}

struct PageRemotecon: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var audioMirroring:AudioMirroring
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var networkObserver:NetworkObserver
    @EnvironmentObject var locationObserver:LocationObserver
    @EnvironmentObject var naviLogManager:NaviLogManager
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()

    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                ZStack(alignment: SystemEnvironment.isTablet ?.center : .top){
                    if self.isUIReady {
                        if let isPairing = self.isPairing {
                            if isPairing  {
                                if SystemEnvironment.isTablet {
                                    ZStack{
                                        Image(Asset.remote.bg)
                                            .renderingMode(.original).resizable()
                                            .modifier(MatchParent())
                                        RemoteCon(
                                            data:self.remotePlayData,
                                            isAudioAble: self.isAudioAble,
                                            isAudioMirroring: self.isAudioMirroring
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
                                        isAudioAble: self.isAudioAble,
                                        isAudioMirroring: self.isAudioMirroring
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
                        
                        if self.isInputSearch {
                            InputRemoteBox(
                                isInit: true,
                                title: String.remote.inputSearch,
                                type: .search,
                                placeHolder:String.remote.inputSearchHolder,
                                inputSize: 99,
                                inputSizeMin: 1
                            ){ input, type in
                                withAnimation{
                                    self.isInputSearch = false
                                }
                                self.remoconInput(type: type, string: input)
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
            .onReceive(self.audioMirroring.$event){evt in
                guard let evt = evt  else {return}
                switch evt {
                case .dicconnected :
                    self.appSceneObserver.event = .toast(String.remote.closeMirroring)
                case .connected :
                    self.appSceneObserver.loadingInfo = nil
                    self.sendStatusLog(action: .pageShow, result: true, category:  String.remote.setupMirroring)
                    self.appSceneObserver.event = .toast(String.remote.setupMirroring)
                case .notFound :
                    self.appSceneObserver.loadingInfo = nil
                    self.sendStatusLog(action: .pageShow, result: false, category:  String.remote.errorMirroringText)
                    self.appSceneObserver.alert =
                        .alert(String.remote.errorMirroring, String.remote.errorMirroringText, String.remote.errorMirroringTextSub){
                            self.sendStatusLog(action: .clickStatusButton, result: false)
                        }
                default: break
                }
            }
            .onReceive(self.audioMirroring.$status){status in
                if !self.isAudioAble {return}
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
                if ani {
                    if self.isUIReady {return}
                    DispatchQueue.main.async {
                        withAnimation{
                            self.isUIReady = ani
                        }
                        self.checkHostDeviceStatus()
                    }
                }
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
               
                if self.audioMirroring.isAudioMirrorSupported {
                    self.isAudioAble = true
                    self.isAudioMirroring = self.audioMirroring.isConnected
                } else {
                    self.isAudioMirroring = false
                }
                
            }
            .onDisappear{
                
            }
            
        }//geo
    }//body
    
    @State var isPairing:Bool? = nil
    @State var isInputText:Bool = false
    @State var isInputChannel:Bool = false
    @State var isInputSearch:Bool = false
    @State var isUIReady:Bool = false
    @State var isHostReady:Bool = true
    @State var isEar:Bool? = nil
    @State var isAudioAble:Bool = false
    @State var isAudioMirroring:Bool = false
    
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
        case BroadcastingType.VOD.rawValue:
            self.dataProvider.broadcasting.requestBroadcast(.updateCurrentVod(message.CurCID))
        case BroadcastingType.IPTV.rawValue:
            if message.CurChNum == "0" {
                self.remotePlayData =  RemotePlayData(isEmpty: true)
                self.dataProvider.broadcasting.reset()
                return
            }
            self.dataProvider.broadcasting.requestBroadcast(.updateCurrentBroadcast)
            self.dataProvider.broadcasting.updateChannelNo(message.CurChNum)
        case BroadcastingType.OAP.rawValue: 
            self.remotePlayData =  RemotePlayData(isNoInfo: true)
            self.dataProvider.broadcasting.reset()
        default:
            self.remotePlayData =  RemotePlayData(isEmpty: true)
            self.dataProvider.broadcasting.reset()
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
                subText: pro.duration != nil ? (pro.duration!+String.app.min) : nil,
                restrictAgeIcon: pro.restrictAgeIcon,
                isOnAir: false)
        }
    }
    
    @State var isActionLock:Bool = false
    private func action(evt:RemoteConEvent) {
        if isActionLock || !isHostReady {
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
            self.sendLog(action: .clickRemoteconExit)
            self.pagePresenter.closePopup(self.pageObject?.id)
        case .reflash:
            self.sendLog(action: .clickWatchingInfoRefresh, actionBody: .init(category: self.remotePlayData?.title ?? ""))
            self.checkHostDeviceStatus()
        case .inputMessage:
            self.sendLog(action: .clickRemoteconFunction, actionBody: .init(category: "chacter"))
            withAnimation{ self.isInputText = true }
        case .inputChannel:
            self.sendLog(action: .clickRemoteconFunction, actionBody: .init(category: "channel_number"))
            withAnimation{ self.isInputChannel = true }
        case .inputSearch:
            self.sendLog(action: .clickRemoteconFunction, actionBody: .init(category: "search")) // 확인필요
            withAnimation{ self.isInputSearch = true }
        case .earphone:
            self.connectEarphone()
        case .toggleOn:
            self.sendLog(action: .clickRemoteconPower)
            self.sendAction(npsMessage: NpsMessage().setMessage(type: .PowerCtrl))
            needUpdate = true
        case .multiview:
            if host.isEnablePIPKey() {
                self.sendLog(action: .clickRemoteconFunction, actionBody: .init(category: "multi_view"))
                self.sendAction(npsMessage: NpsMessage().setMessage(type: .PIP))
            }else {
                self.appSceneObserver.event = .toast(String.alert.guideNotSupported)
            }
        case .chlist:
            if host.isEnableGuideKey() {
                self.sendLog(action: .clickRemoteconFunction, actionBody: .init(category: "epg"))
                self.sendAction(npsMessage: NpsMessage().setMessage(type: .Guide))
            }else {
                self.appSceneObserver.event = .toast(String.alert.guideNotSupported)
            }
        case .fastForward:
            if self.remotePlayData?.isOnAir == false {
                self.sendLog(action: .clickRemoteconColor, actionBody: .init(category: "blue"))
                self.sendAction(npsMessage: NpsMessage().setMessage(type: .PlayCtrl, value: .FF))
            }
        case .rewind:
            if self.remotePlayData?.isOnAir == false {
                self.sendLog(action: .clickRemoteconColor, actionBody: .init(category: "red"))
                self.sendAction(npsMessage: NpsMessage().setMessage(type: .PlayCtrl, value: .REW))
            }
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
            if self.isAudioMirroring {
                MPVolumeView.moveVolume(v>0 ? 0.1 : -0.1)
            } else {
                self.sendAction(npsMessage: NpsMessage().setMessage(type: v>0 ? .VOLUp : .VOLDown))
            }
            
        case .channelMove(let c) :
            self.sendAction(npsMessage: NpsMessage().setMessage(type: c>0 ? .CHUp : .CHDown))
            needUpdate = true
        case .exit :
            if host.isEnableExitKey() {
                self.sendLog(action: .clickRemoteconHomeMove, actionBody: .init(category: "exit"))
                self.sendAction(npsMessage: NpsMessage().setMessage(type: .ButtonExit))
                needUpdate = true
            }else {
                self.appSceneObserver.event = .toast(String.alert.guideNotSupported)
            }
        case .previous :
            self.sendLog(action: .clickRemoteconHomeMove, actionBody: .init(category: "back"))
            self.sendAction(npsMessage: NpsMessage().setMessage(type: .ButtonCancel))
            needUpdate = true
        case .home :
            self.sendLog(action: .clickRemoteconHomeMove, actionBody: .init(category: "home"))
            self.sendAction(npsMessage: NpsMessage().setMessage(type: .ButtonHome))
            needUpdate = true
        case .mute(let isMute) :
            if isMute {
                self.sendLog(action: .clickRemoteconFunction, actionBody: .init(category: "mute"))
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
        case .search:
            if host.isEnableStringInput() {
                ctrl = .StrInput
            }
        }
        self.sendAction(npsMessage: NpsMessage().setMessage(type: ctrl, value: value))
        
    }
    
    private func sendAction(npsMessage:NpsMessage) {
        self.isHostReady = false
        self.dataProvider.requestData(
            q: .init(id: self.tag, type: .sendMessage(npsMessage))
        )
    }
    private func actionResult(npsMessage:NpsMessage?, res:ApiResultResponds) {
        guard let npsMessage = npsMessage else { return }
        self.isHostReady = true
        switch npsMessage.ctrlType {
        case .Refresh:
            self.checkBroadcast(res: res)
         default:
            break
        }
    }
    
    private func actionError(npsMessage:NpsMessage?, err:ApiResultError) {
        guard let npsMessage = npsMessage else { return }
        self.isHostReady = true
        switch npsMessage.ctrlType {
        case .Refresh:
            self.remotePlayData =  RemotePlayData(isError: true)
         default:
            break
        }
    }
    
    
    private func connectEarphone(){
        if self.audioMirroring.isConnected {
            self.sendLog(action: .clickFamilyEarphone, actionBody: .init(config:  "off"))
            self.audioMirroring.close()
            return
        }
        
        if self.networkObserver.status != .wifi {
            self.appSceneObserver.alert = .connectWifi
            return
        }
        let status = self.locationObserver.status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            let manager = self.audioMirroring
            if manager.isSkWifi && manager.isAudioMirrorSupported {
                self.appSceneObserver.loadingInfo = [
                    String.remote.searchMirroring
                ]
                manager.startSearching()
                
            } else {
                self.sendStatusLog(action: .pageShow, result: false, category: String.remote.errorMirroringWifi)
                self.sendLog(action: .clickFamilyEarphone, actionBody: .init(config:  "on"))
                self.appSceneObserver.alert =
                    .alert(String.remote.errorMirroringWifi, String.remote.errorMirroringWifiText){
                        self.sendStatusLog(action: .clickStatusButton, result: false)
                    }
            }
        } else if status == .denied {
            self.appSceneObserver.alert = .requestLocation{ retry in
                if retry { AppUtil.goLocationSettings() }
            }
        } else {
            self.locationObserver.requestWhenInUseAuthorization()
        }
    }
    
    private func sendLog(action:NaviLog.Action, actionBody:MenuNaviActionBodyItem? = nil) {
        self.naviLogManager.actionLog(action , actionBody: actionBody)
    }
    
    private func sendStatusLog(action:NaviLog.Action, result: Bool, category:String? = nil) {
        var actionBody = MenuNaviActionBodyItem()
        actionBody.config = result ? "true" : "false"
        actionBody.category = category
        self.naviLogManager.actionLog(action, pageId: .remoteconStatus , actionBody: actionBody)
        
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
