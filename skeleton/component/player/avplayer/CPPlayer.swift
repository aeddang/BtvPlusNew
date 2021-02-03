import Foundation
import SwiftUI
import Combine

let testPath = "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"
let testPath2 = "http://techslides.com/demos/sample-videos/small.mp4"


struct CPPlayer: PageComponent {
    @ObservedObject var viewModel:PlayerModel = PlayerModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    private let TAG = "ComponentPlayer"
    var body: some View {
        ZStack{
            CustomAVPlayer( viewModel : self.viewModel)
            HStack(spacing:0){
                Spacer().modifier(MatchParent())
                    .background(Color.transparent.black1)
                    .onTapGesture(count: 2, perform: {
                        self.viewModel.event = .seekBackword(10, false)
                    })
                    .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                        self.uiViewChange()
                    })
                    
                Spacer().modifier(MatchParent())
                    .background(Color.transparent.black1)
                    .onTapGesture(count: 2, perform: {
                        self.viewModel.event = .seekForward(10, false)
                    })
                    .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                        self.uiViewChange()
                    })
                    
            }
            PlayerUI(viewModel : self.viewModel, pageObservable:self.pageObservable)
            
        }
        .onReceive(self.viewModel.$isPlay) { _ in
            self.autoUiHidden?.cancel()
        }
        .onReceive(self.viewModel.$event) { evt in
            guard let evt = evt else { return }
            switch evt {
            case .seeking(_): self.autoUiHidden?.cancel()
            default : do{}
            }
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
            .frame(width: 320, height: 640, alignment: .center)
        }
    }
}
#endif
