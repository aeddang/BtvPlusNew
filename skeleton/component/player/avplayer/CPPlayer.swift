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
            PlayerUI(viewModel : self.viewModel, pageObservable:self.pageObservable)
           
        }
        .background(Color.black)
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
