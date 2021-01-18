//
//  Toast.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    func toast(isShowing: Binding<Bool>, text: String) -> some View {
        Toast(isShowing: isShowing,
              presenting: { self },
              text: text)
    }
    
}

struct Toast<Presenting>: View where Presenting: View {
    @EnvironmentObject var sceneObserver:SceneObserver
    @Binding var isShowing: Bool
    let presenting: () -> Presenting
    var text: String
    var duration:Double = 2
    @State var safeAreaBottom:CGFloat = 0
    var body: some View {
        ZStack(alignment: .bottom) {
            self.presenting()
            VStack {
                Text(self.text)
                    .modifier(MediumTextStyle(size: Font.size.light, color: Color.app.white))
                    .padding(.top, Dimen.margin.thin)
                    .padding(.horizontal, Dimen.margin.thin)
                    .padding(.bottom, Dimen.margin.thin + self.safeAreaBottom)
                    .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/,  maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            }
            .background(Color.black.opacity(0.7))
            .transition(.slide)
            .opacity(self.isShowing ? 1 : 0)
        }
        .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
            //if self.editType == .nickName {return}
            withAnimation{
                self.safeAreaBottom = pos
            }
        }
        .onReceive( [self.isShowing].publisher ) { show in
            if !show  { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + self.duration) {
              withAnimation {
                 self.isShowing = false
              }
            }
        }
    }
}
