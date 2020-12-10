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
    @Binding var isSelected: Bool
    let text:String
    let index: Int 
    let textModifier:TextModifier
    let action: (_ idx:Int) -> Void
    
    var bgColor = Color.app.whiteDeep
    var bgActiveColor = Color.brand.primary
    var cornerRadius = Dimen.radius.light
    var padding = Dimen.margin.thin
    init(
        text:String,
        index: Int = 0,
        isSelected:Binding<Bool>? = nil,
        textModifier:TextModifier? = nil,
        bgColor:Color? = nil,
        bgActiveColor:Color? = nil,
        cornerRadius:CGFloat? = nil,
        padding:CGFloat? = nil,
        action:@escaping (_ idx:Int) -> Void
        
    ){
        self.text = text
        self.index = index
        self.textModifier = textModifier ??
            TextModifier(
                family:Font.family.regular,
                size:Font.size.light,
                color: Color.app.black,
                activeColor: Color.app.white
        )
        self._isSelected = isSelected ?? Binding.constant(false)
        self.action = action
        if let bgColor = bgColor { self.bgColor = bgColor }
        if let bgActiveColor = bgActiveColor { self.bgActiveColor = bgActiveColor }
        if let cornerRadius = cornerRadius { self.cornerRadius = cornerRadius }
        if let padding = padding { self.padding = padding }
        
    }
    
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
