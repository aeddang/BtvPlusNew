//
//  VoiceRecorder.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
import SwiftUI
struct VerticalButtonBox: PageView {
    enum Event{
        case up, down
    }
    let defaultImage:String
    let upImage:String
    let downImage:String
    var action: ((_ evt:VerticalButtonBox.Event) -> Void)
    @State var event:Event? = nil
   
    var body: some View {
        ZStack{
            Image( self.event == nil
                ? self.defaultImage
                : (self.event == .up ? self.upImage : self.downImage)
            )
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .modifier(MatchParent())
            VStack(spacing:0){
                BlankButton(
                    action: { _ in
                        withAnimation {  self.event = .up}
                        self.action(.up)
                    }, effectCompleted: { _ in
                        withAnimation { self.event = nil}
                    }
                )

                BlankButton(
                    action: { _ in
                        withAnimation {  self.event = .down}
                        self.action(.down)
                    }, effectCompleted: { _ in
                        withAnimation { self.event = nil}
                    }
                )
            }
        }
    }//body
}


#if DEBUG
struct VerticalButtonBox_Previews: PreviewProvider {
    
    static var previews: some View {
        VerticalButtonBox(
            defaultImage:Asset.remote.volume,
            upImage:Asset.remote.volumeUp,
            downImage:Asset.remote.volumeDown
        ){ evt in
            
            
        }
    }
}
#endif
