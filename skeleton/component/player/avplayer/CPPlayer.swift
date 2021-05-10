import Foundation
import SwiftUI
import Combine

let testPath = "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"
let testPath2 = "http://techslides.com/demos/sample-videos/small.mp4"

struct CPPlayer: PageComponent {
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel:PlayerModel = PlayerModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    var isSimple:Bool = false
    @State var screenRatio = CGSize(width:1, height:1)
    @State var bindUpdate:Bool = false //for ios13
    var body: some View {
        ZStack(alignment: .center){
            CustomAVPlayer(
                viewModel : self.viewModel,
                pageObservable : self.pageObservable,
                bindUpdate: self.$bindUpdate
                )
            if !self.viewModel.useAvPlayerController {
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
                    PlayerUI(viewModel : self.viewModel, pageObservable:self.pageObservable)
                }
            }
        }
        .clipped()
        .onReceive(self.viewModel.$isPlay) { _ in
            self.autoUiHidden?.cancel()
        }
        .onReceive(self.viewModel.$event) { evt in
            guard let evt = evt else { return }
            switch evt {
            case .seeking(_): self.autoUiHidden?.cancel()
            case .fixUiStatus: self.autoUiHidden?.cancel()
            default : do{}
            }
        }
        .onReceive(self.viewModel.$status) { stat in
            if #available(iOS 14.0, *) { return }
            self.bindUpdate.toggle()
        }
        .onReceive(self.viewModel.$streamEvent) { evt in
            guard let evt = evt else { return }
            switch evt {
            case .seeked: self.delayAutoUiHidden()
            default : do{}
            }
        }
        .background(Color.black)
        
        
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
