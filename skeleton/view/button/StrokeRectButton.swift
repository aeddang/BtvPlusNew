//
//  RectButton.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct StrokeRectButton: View, SelecterbleProtocol{
    @Binding var isSelected: Bool
    let text:String
    let index: Int
    let textModifier:TextModifier
    let action: (_ idx:Int) -> Void
    var strokeColor = Color.app.grey
    var strokeActiveColor = Color.brand.primary
    var cornerRadius = Dimen.radius.light
    var size:CGFloat = Dimen.button.light
    var padding:CGFloat = Dimen.margin.thin
    var icon:String? = nil
    var iconTail:String? = nil
    init(
        text:String,
        index: Int = 0,
        isSelected:Binding<Bool>? = nil,
        textModifier:TextModifier? = nil,
        strokeColor:Color? = nil,
        strokeActiveColor:Color? = nil,
        cornerRadius:CGFloat? = nil,
        size:CGFloat? = nil,
        padding:CGFloat? = nil,
        icon:String? = nil,
        iconTail:String? = nil,
        action:@escaping (_ idx:Int) -> Void
        
    ){
        self.text = text
        self.index = index
        self.textModifier = textModifier ??
            TextModifier(
                family: Font.family.bold,
                size: Font.size.light,
                color: Color.app.grey,
                activeColor: Color.brand.primary
            )
        self._isSelected = isSelected ?? Binding.constant(true)
        self.action = action
        if let cornerRadius = cornerRadius { self.cornerRadius = cornerRadius }
        if let size = size { self.size = size }
        if let padding = padding { self.padding = padding }
        if let strokeColor = strokeColor { self.strokeColor = strokeColor }
        if let strokeActiveColor = strokeActiveColor { self.strokeActiveColor = strokeActiveColor }
        if let icon = icon { self.icon = icon }
        if let iconTail = iconTail { self.iconTail = iconTail }
    }
    
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            ZStack{
                HStack(spacing:Dimen.margin.thinExtra){
                    if self.icon != nil {
                        Image(self.icon!)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.light, height: Dimen.icon.light)
                        
                    }
                    Text(self.text)
                    .font(.custom(textModifier.family, size: textModifier.size))
                    .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                    if self.iconTail != nil {
                        Image(self.iconTail!)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
                        
                    }
                }
                .padding(.horizontal, self.padding)
            }
            .frame(height:self.size)
            .background(Color.app.white)
            .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: self.cornerRadius)
                    .stroke(self.isSelected ? self.strokeActiveColor : self.strokeColor,lineWidth: 1)
            )
        }
    }
}
#if DEBUG
struct StrokeRectButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            StrokeRectButton(
            text: "test"){_ in
                
            }
            .frame( alignment: .center)
        }
    }
}
#endif
