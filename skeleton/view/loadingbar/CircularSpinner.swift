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
   
    var resorce:String
    var body: some View {
        Group{
            Image(resorce).renderingMode(.original)
                .rotationEffect(.degrees(self.degree))
                
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
        let d:Double = 0.03
        self.degree = 0
        
        self.ani = Timer.publish(
            every: d, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.degree += 5
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
