//
//  CircularProgressIndicator.swift
//  ironright
//
//  Created by JeongCheol Kim on 2019/11/20.
//  Copyright © 2019 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct CircularSpinner: View {
    static private let animation = Animation
        .linear(duration: 2)
        .repeatForever(autoreverses: false)

    var resorce:String
    
    var body: some View {
        Group{
            Image(resorce).renderingMode(.original)
                .rotationEffect(.degrees(self.isReverse ? 0 : -360))
                .animation(CircularSpinner.animation)
        }
        .onAppear(){
            self.isReverse.toggle()
            self.aniStart()
        }
        .onDisappear(){
            self.ani?.cancel()
            self.ani = nil
        }
    }
    
    @State private var isReverse: Bool = false
    @State private var ani:AnyCancellable?
    private func aniStart(){
        self.ani?.cancel()
        self.ani = Timer.publish(
            every: 2, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.isReverse.toggle()
            }
    }
}
#if DEBUG
struct CircularSpinner_Previews: PreviewProvider {
    static var previews: some View {
        CircularSpinner(resorce: Asset.test)
    }
}
#endif
