//
//  VoiceRecorder.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
import SwiftUI
struct ControlBox: PageView {
    enum Event{
        case left, right, up, down, ok
    }
    let defaultImage:String = Asset.remote.center
    var action: ((_ evt:ControlBox.Event) -> Void)
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
                            self.action(.left)
                            withAnimation {  self.event = .left}
                        }, effectCompleted: { _ in
                            withAnimation { self.event = nil}
                        }
                    )
                    Spacer()
                }
                VStack(spacing: 0){
                    BlankButton(
                        action: { _ in
                            self.action(.up)
                            withAnimation {  self.event = .up}
                        }, effectCompleted: { _ in
                            withAnimation { self.event = nil}
                        }
                    )
                    Spacer()
                    BlankButton(
                        action: { _ in
                            self.action(.down)
                            withAnimation {  self.event = .down}
                        }, effectCompleted: { _ in
                            withAnimation { self.event = nil}
                        }
                    )
                }
                VStack(spacing: 0){
                    Spacer()
                    BlankButton(
                        action: { _ in
                            self.action(.right)
                            withAnimation {  self.event = .right}
                        }, effectCompleted: { _ in
                            withAnimation { self.event = nil}
                        }
                    )
                    Spacer()
                }
            }
            
            EffectButton(defaultImage: Asset.remote.centerOk, effectImage: Asset.remote.centerOkDown)
            { _ in
                self.action(.ok)
            }
            .frame(width: RemoteStyle.button.heavyExtra, height: RemoteStyle.button.heavyExtra)
        }
        .frame(width: RemoteStyle.ui.center.width, height: RemoteStyle.ui.center.height)
    }//body
    
    private func getCenterImage() -> String{
        switch self.event {
        case .up:
            return Asset.remote.centerUp
        case .down:
            return Asset.remote.centerDown
        case .left:
            return Asset.remote.centerLeft
        case .right:
            return Asset.remote.centerRight
        default:
            return self.defaultImage
        }
        
    }
}


#if DEBUG
struct ControlBox_Previews: PreviewProvider {
    
    static var previews: some View {
        ControlBox(
            
        ){ evt in
            
            
        }
    }
}
#endif
