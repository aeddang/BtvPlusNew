//
//  RectButton.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct RectButtonKids: View, SelecterbleProtocol{
    let text:String
    var index: Int = 0
    var isSelected: Bool = false
    var textModifier:TextModifierKids = TextModifierKids(
        family:Font.familyKids.bold,
        size: Font.sizeKids.lightExtra,
        color: Color.app.brownDeep,
        activeColor: Color.app.white
    )
    var bgColor = Color.app.white
    var bgActiveColor = Color.kids.primary
    var size:CGSize = DimenKids.button.mediumRect
    var isFixSize:Bool = true
    var cornerRadius:CGFloat = DimenKids.radius.light
    
    let action: (_ idx:Int) -> Void
    
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            ZStack{
                if self.isFixSize {
                    Text(self.text)
                        .font(.custom(textModifier.family, size: textModifier.size))
                        .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                        .frame(width:self.size.width)
                } else {
                    Text(self.text)
                        .font(.custom(textModifier.family, size: textModifier.size))
                        .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                }
            }
            .padding(.horizontal, DimenKids.margin.regular)
            .frame(height:self.size.height)
            .background(self.isSelected ? self.bgActiveColor : self.bgColor)
            .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
            
        }
    }
}
#if DEBUG
struct RectButtonKids_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            RectButtonKids(
            text: "test",
                isSelected: true,
                isFixSize: false
                ){_ in
                
            }
            
        }
    }
}
#endif
