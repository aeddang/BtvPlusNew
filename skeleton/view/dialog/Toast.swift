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
    func toast(isShowing: Binding<Bool>, text: Text) -> some View {
        Toast(isShowing: isShowing,
              presenting: { self },
              text: text)
    }
    
    func toast(isShowing: Binding<Bool>, text: String) -> some View {
        let text = Text(text)
        _ = text.modifier(
            MediumTextStyle(
                size: Font.size.thinExtra, color: Color.app.white
            ))
        _ = text.multilineTextAlignment(.center)
        
        return Toast(isShowing: isShowing,
              presenting: { self },
              text: text
        )
    }
}

struct Toast<Presenting>: View where Presenting: View {

    @Binding var isShowing: Bool
    let presenting: () -> Presenting
    var text: Text
    var duration:Double = 2
    var body: some View {
        ZStack(alignment: .center) {
            self.presenting()
            ZStack(alignment: .center) {
                VStack {
                    self.text
                }
                .padding(.all, Dimen.margin.thin)
                .background(Color.black.opacity(0.7))
                .foregroundColor(Color.white)
                .cornerRadius(Dimen.radius.light)
                .transition(.slide)
            }
            .padding(.all, Dimen.margin.medium)
            .opacity(self.isShowing ? 1 : 0)
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
