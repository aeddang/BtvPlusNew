//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct TextButton: View, SelecterbleProtocol{
    @Binding var isSelected: Bool
    let index: Int
    let defaultText:String
    let activeText:String
    let textModifier:TextModifier
    let isUnderLine:Bool
    let action: (_ idx:Int) -> Void
    
    
    init(
        defaultText:String,
        activeText:String? = nil,
        isSelected:Binding<Bool>? = nil,
        textModifier:TextModifier? = nil,
        index: Int = 0,
        isUnderLine:Bool = false,
        action:@escaping (_ idx:Int) -> Void
    )
    {
        self.defaultText = defaultText
        self.activeText = activeText ?? defaultText
        self.index = index
        self.textModifier = textModifier ?? RegularTextStyle().textModifier
        self._isSelected = isSelected ?? Binding.constant(false)
        self.isUnderLine = isUnderLine
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            
            if self.isUnderLine {
                Text(self.isSelected ? self.activeText : self.defaultText)
                .font(.custom(textModifier.family, size: textModifier.size))
                .underline()
                .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
            } else {
                
                Text(self.isSelected ? self.activeText : self.defaultText)
                .font(.custom(textModifier.family, size: textModifier.size))
                .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
            }
        }.buttonStyle(BorderlessButtonStyle())
    }
}

#if DEBUG
struct TextButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            TextButton(
                defaultText:"test",
                isUnderLine: true){_ in
                
            }
            .frame( alignment: .center)
        }
    }
}
#endif
