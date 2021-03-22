//
//  Toast.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

extension View {
    func toast(isShowing: Binding<Bool>, text: String) -> some View {
        Toast(isShowing: isShowing,
              presenting: { self },
              text: text)
    }
    
}

struct Toast<Presenting>: View where Presenting: View {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @Binding var isShowing: Bool
    let presenting: () -> Presenting
    var text: String
    var duration:Double = 1.5
    @State var safeAreaBottom:CGFloat = 0
    var body: some View {
        ZStack(alignment: .bottom) {
            self.presenting()
            VStack{
                Text(self.text)
                    .modifier(MediumTextStyle(size: Font.size.light, color: Color.app.white))
                    .padding(.all, Dimen.margin.thin)
                    .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/,  maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center)
            }
            .background(Color.app.greyDeep.opacity(0.7))
            .padding(.bottom, self.safeAreaBottom)
            .offset(y:self.isShowing ? 0 : 100)
            .opacity(self.isShowing ? 1 : 0)
        }
        .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
            withAnimation{
                self.safeAreaBottom = pos
            }
        }
        .onReceive( [self.isShowing].publisher ) { show in
            if !show  { return }
            DispatchQueue.global().asyncAfter(deadline: .now() + self.duration) {
                withAnimation {
                   self.isShowing = false
                }
            }
            
        }
    }
    
    @State var autoHidden:AnyCancellable?
    func delayAutoHidden(){
        self.autoHidden?.cancel()
        self.autoHidden = Timer.publish(
            every: self.duration, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.autoHidden?.cancel()
                withAnimation {
                   self.isShowing = false
                }
            }
    }
}
