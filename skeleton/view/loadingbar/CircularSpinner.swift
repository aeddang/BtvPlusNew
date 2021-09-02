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
        .linear(duration: 4)
        .repeatForever(autoreverses: false)
    
    var resorce:String
    var body: some View {
        Group{
            Image(resorce).renderingMode(.original)
                .rotationEffect(.degrees(self.degree))
                .animation(CircularSpinner.animation)
        }
        .onAppear(){
            self.aniStart()
        }
        .onDisappear(){
            self.ani?.cancel()
            self.degree = 0
        }
    }
    
    @State private var degree: Double = 0
    @State private var ani:AnyCancellable?
    private func aniStart(){
        self.ani?.cancel()
        let d:Double = 1
        withAnimation(.easeInOut(duration: d)){
            self.degree = 360
        }
        self.ani = Timer.publish(
            every: d, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.degree = 0
                withAnimation(.easeInOut(duration: d)){
                    self.degree = 360
                }
                
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
