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
    let text:String
    var isSelected: Bool = true
    var index: Int = 0
    var textModifier:TextModifier = TextModifier(
        family: Font.family.bold,
        size: Font.size.light,
        color: Color.app.grey,
        activeColor: Color.brand.primary
    )
    
    var strokeColor = Color.app.grey
    var strokeActiveColor = Color.brand.primary
    var cornerRadius = Dimen.radius.light
    var size:CGFloat = Dimen.button.light
    var padding:CGFloat = Dimen.margin.thin
    var icon:String? = nil
    var iconTail:String? = nil
    let action: (_ idx:Int) -> Void
    
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            ZStack{
                HStack(spacing:Dimen.margin.tiny){
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
