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
        size: Font.size.tinyExtra,
        color: Color.app.greyLight,
        activeColor: Color.app.white
    )
    
    var strokeColor = Color.app.greyLight
    var strokeActiveColor = Color.app.white
    var cornerRadius:CGFloat = 0
    var size:CGSize = CGSize(width: Dimen.button.heavy, height: Dimen.button.thin)
    var icon:String? = nil
    var iconTrail:String? = nil
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
                    if self.iconTrail != nil {
                        Image(self.iconTrail!)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
                        
                    }
                }
            }
            .frame(width:self.size.width, height:self.size.height)
            .background(Color.transparent.clearUi)
            .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: self.cornerRadius)
                    .stroke(self.isSelected ? self.strokeActiveColor : self.strokeColor,
                            lineWidth: self.isSelected ? 2 : 1)
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
            .background(Color.brand.bg)
        }
    }
}
#endif
