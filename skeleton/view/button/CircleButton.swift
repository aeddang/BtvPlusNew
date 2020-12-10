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
    @Binding var isSelected: Bool
    let index:Int
    let action: (_ idx:Int) -> Void
    init(
        isSelected:Binding<Bool>? = nil,
        index: Int = 0,
        action:@escaping (_ idx:Int) -> Void
    )
    {
        self.index = index
        self._isSelected = isSelected ?? Binding.constant(false)
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            self.action( self.index )
        }) {
            Circle()
               .frame(width: Dimen.icon.thinExtra, height: Dimen.icon.thinExtra)
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
