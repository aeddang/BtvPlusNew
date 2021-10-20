//
//  VoiceRecorder.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
import SwiftUI
struct PlayControlBox: PageView {
    enum Event{
        case togglePlay, next, prev
    }
    let defaultImage:String = Asset.remote.centerSkip
    var action: ((_ evt:PlayControlBox.Event) -> Void)
    @State var event:Event? = nil
   
    var body: some View {
        ZStack{
            Image( self.event == nil
                ? self.defaultImage
                : self.getCenterImage()
            )
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .modifier(MatchParent())
            HStack(spacing: 0){
                VStack(spacing: 0){
                    Spacer()
                    BlankButton(
                        action: { _ in
                            self.action(.prev)
                            withAnimation {  self.event = .prev}
                        }, effectCompleted: { _ in
                            withAnimation { self.event = nil}
                        }
                    )
                    Spacer()
                }
                Spacer()
                VStack(spacing: 0){
                    Spacer()
                    BlankButton(
                        action: { _ in
                            self.action(.next)
                            withAnimation {  self.event = .next}
                        }, effectCompleted: { _ in
                            withAnimation { self.event = nil}
                        }
                    )
                    Spacer()
                }
            }
            
            EffectButton(defaultImage: Asset.remote.centerPlayStop, effectImage: Asset.remote.centerPlayStopDown)
            { _ in
                self.action(.togglePlay)
            }
            .frame(width: RemoteStyle.button.heavyExtra, height: RemoteStyle.button.heavyExtra)
        }
        .frame(width: RemoteStyle.ui.center.width, height: RemoteStyle.ui.center.height)
    }//body
    
    private func getCenterImage() -> String{
        switch self.event {
        case .prev:
            return Asset.remote.centerSkipPrev
        case .next:
            return Asset.remote.centerSkipNext
       
        default:
            return self.defaultImage
        }
        
    }
}


#if DEBUG
struct PlayControlBox_Previews: PreviewProvider {
    
    static var previews: some View {
        PlayControlBox(
            
        ){ evt in
            
            
        }
    }
}
#endif
