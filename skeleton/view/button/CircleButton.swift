//
//  CircleButton.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct CircleButton: View, SelecterbleProtocol {
    var isSelected: Bool = false
    var index:Int = 0
    let action: (_ idx:Int) -> Void
    
    var body: some View {
        Button(action: {
            self.action( self.index )
        }) {
            Circle()
               .frame(width: Dimen.icon.thin, height: Dimen.icon.tiny)
                .foregroundColor(self.isSelected ? Color.app.white : Color.app.white.opacity(0.4))
        }
    }
}

#if DEBUG
struct CircleButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            CircleButton(){_ in
                
            }
            .frame( alignment: .center)
        }
    }
}
#endif
