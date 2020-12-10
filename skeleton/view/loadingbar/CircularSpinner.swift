//
//  CircularProgressIndicator.swift
//  ironright
//
//  Created by JeongCheol Kim on 2019/11/20.
//  Copyright © 2019 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct CircularSpinner: View {
    static private let animation = Animation
        .linear(duration: 2)
        .repeatForever(autoreverses: false)

    @Binding var resorce:String
    @State var isReverse: Bool = false
    
    var body: some View {
        Group{
            Image(resorce).renderingMode(.original)
            .rotationEffect(.degrees(isReverse ? 0 : -360))
            .animation(CircularSpinner.animation)
        }.onAppear(){
            self.isReverse.toggle()
        }
    }
    
}
#if DEBUG
struct CircularSpinner_Previews: PreviewProvider {
    static var previews: some View {
        CircularSpinner(resorce: .constant(Asset.test))
    }
}
#endif
