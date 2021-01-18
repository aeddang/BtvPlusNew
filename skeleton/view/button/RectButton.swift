//
//  RectButton.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct RectButton: View, SelecterbleProtocol{
    let text:String
    var index: Int = 0
    var isSelected: Bool = true
    var textModifier:TextModifier = TextModifier(
        family:Font.family.regular,
        size:Font.size.light,
        color: Color.app.black,
        activeColor: Color.app.white
    )
    var bgColor = Color.app.whiteDeep
    var bgActiveColor = Color.brand.primary
    var cornerRadius = Dimen.radius.light
    var padding = Dimen.margin.thin
    let action: (_ idx:Int) -> Void
    
    
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            ZStack{
                Text(self.text)
                    .font(.custom(textModifier.family, size: textModifier.size))
                    .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                    .padding(.horizontal, self.padding)
            }
            .frame(height:Dimen.button.regular)
            .background(self.isSelected ? self.bgActiveColor : self.bgColor)
            .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
        }
    }
}
#if DEBUG
struct RectButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            RectButton(
            text: "test"){_ in
                
            }
            .frame( alignment: .center)
        }
    }
}
#endif
