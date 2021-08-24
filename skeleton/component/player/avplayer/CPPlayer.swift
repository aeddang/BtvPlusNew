import Foundation
import SwiftUI
import Combine

let testPath = "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"
let testPath2 = "http://techslides.com/demos/sample-videos/small.mp4"

struct CPPlayer: PageComponent {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var viewModel:PlayerModel = PlayerModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    var isSimple:Bool = false
    var type:PageType = .btv
    @State var screenRatio = CGSize(width:1, height:1)
    @State var bindUpdate:Bool = false //for ios13
   
    var body: some View {
        ZStack(alignment: .center){
            CustomAVPlayerController(
                viewModel : self.viewModel,
                pageObservable : self.pageObservable,
                bindUpdate: self.$bindUpdate
                )
            if !self.viewModel.useAvPlayerController{
                HStack(spacing:0){
                    Spacer().modifier(MatchParent())
                        .background(Color.transparent.clearUi)
                        .onTapGesture(count: 2, perform: {
                            if self.viewModel.isLock { return }
                            self.viewModel.event = .seekBackword(self.viewModel.getSeekBackwordAmount(), false)
                        })
                        .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                            self.uiViewChange()
                        })
                        
                    Spacer().modifier(MatchParent())
                        .background(Color.transparent.clearUi)
                        .onTapGesture(count: 2, perform: {
                            if self.viewModel.isLock { return }
                            self.viewModel.event = .seekForward(self.viewModel.getSeekForwardAmount(), false)
                        })
                        .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                            self.uiViewChange()
                        })
                        
                }
                if self.isSimple {
                    SimplePlayerUI(viewModel : self.viewModel, pageObservable:self.pageObservable)
                }else{
                    if self.type == .btv {
                        PlayerUI(viewModel : self.viewModel, pageObservable:self.pageObservable)
                    } else {
                        KidsPlayerUI(viewModel : self.viewModel, pageObservable:self.pageObservable)
                    }
                }
            }
        }
        .clipped()
        .onReceive(self.viewModel.$isPlay) { _ in
            self.autoUiHidden?.cancel()
        }
        .onReceive(self.viewModel.$duration) { d in
            ComponentLog.d("on duration " + d.description, tag:self.tag)
            self.clearWaitDuration()
        }
        
        .onReceive(self.viewModel.$event) { evt in
            guard let evt = evt else { return }
            switch evt {
    
            case .stop, .pause :  self.creatWaitDuration()
            case .seeking(_): self.autoUiHidden?.cancel()
            case .fixUiStatus(let isFix): if isFix { self.autoUiHidden?.cancel()}
            default : break
            }
        }
        
        .onReceive(self.viewModel.$status) { stat in
            if #available(iOS 14.0, *) { return }
            self.bindUpdate.toggle()
        }
        .onReceive(self.viewModel.$streamEvent) { evt in
            guard let evt = evt else { return }
            switch evt {
            case .loaded(_) :
                if self.viewModel.duration <= 0 {
                    self.creatWaitDuration()
                }
            case .seeked: self.delayAutoUiHidden()
            default : break
            }
        }
        .onReceive(self.viewModel.$error) { err in
            guard let err = err else { return }
            var msg = ""
            var code = ""
            switch err {
            case .connect(let s):
                msg = s
                code = "#connect error"
            case .stream(let err):
                msg = err.getDescription()
                code = "#stream error"
            case .illegalState(_):
                return
            case .drm(let err):
                msg = err.getDescription()
                code = "#drm error"
            case .asset(let err):
                msg = err.getDescription()
                code = "#asset error"
            }
            ComponentLog.e(code + " : " + msg, tag:self.tag)
            self.appSceneObserver.alert = .confirm(
                String.alert.playError, String.alert.playErrorPlayback, code,
                confirmText: String.button.btnRetry){retry in
                if retry {
                    self.viewModel.updateType = .recovery(self.viewModel.initTime ?? 0)
                    self.viewModel.event = .resume
                }
            }
        }
        .background(Color.black)
        .onDisappear(){
            self.creatWaitDuration()
        }
        
    }
    
    func uiViewChange(){
        if self.viewModel.playerUiStatus == .hidden {
            self.viewModel.playerUiStatus = .view
            //ComponentLog.d("self.viewModel.playerStatus " + self.viewModel.playerStatus.debugDescription , tag: self.tag)
            if self.viewModel.playerStatus == PlayerStatus.resume {
                self.delayAutoUiHidden()
            }
        }else {
            self.viewModel.playerUiStatus = .hidden
            self.autoUiHidden?.cancel()
        }
    }

    @State var autoUiHidden:AnyCancellable?
    func delayAutoUiHidden(){
        self.autoUiHidden?.cancel()
        self.autoUiHidden = Timer.publish(
            every: 1.5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.viewModel.playerUiStatus = .hidden
                self.autoUiHidden?.cancel()
            }
    }
    
    
    @State var waitDurationSubscription:AnyCancellable?
    @State var waitDurationCount = 0
    func creatWaitDuration() {
        //ComponentLog.d("creatWaitDuration", tag:self.tag)
        self.waitDurationSubscription?.cancel()
        self.waitDurationCount = 0
        self.waitDurationSubscription = Timer.publish(
            every: 1.0, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.waitDurationCount += 1
                if self.waitDurationCount <= 4 && self.viewModel.duration > 0 {
                    self.clearWaitDuration()
                    return
                }
                if self.waitDurationCount == 5 {
                    if self.viewModel.duration == 0 {
                        self.viewModel.event = .stop
                        self.viewModel.error = .stream(.playback("wait Duration"))
                    }
                    self.clearWaitDuration()
                }
            }
    }
    func clearWaitDuration() {
        guard let waitDurationSubscription = self.waitDurationSubscription else {return}
        //ComponentLog.d("clearWaitDuration", tag:self.tag)
        waitDurationSubscription.cancel()
        self.waitDurationSubscription = nil
    }
}


#if DEBUG
struct ComponentPlayer_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            CPPlayer(viewModel:PlayerModel()).contentBody
                .environmentObject(PagePresenter())
                .frame(width: 320, height: 640, alignment: .center)
        }
    }
}
#endif
