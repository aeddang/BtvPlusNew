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
    var defaultText:String
    var isSelected: Bool = false
    var index: Int = 0
    var activeText:String? = nil
    var textModifier:TextModifier = RegularTextStyle().textModifier
    var isUnderLine:Bool = false
    var image:String? = nil
    var imageSize:CGFloat = Dimen.icon.tinyExtra
    let action: (_ idx:Int) -> Void
    
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            HStack(spacing: Dimen.margin.tinyExtra){
                if self.isUnderLine {
                    Text(self.isSelected ? ( self.activeText ?? self.defaultText ) : self.defaultText)
                    .font(.custom(textModifier.family, size: textModifier.size))
                    .underline()
                    .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                } else {
                    
                    Text(self.isSelected ? ( self.activeText ?? self.defaultText ) : self.defaultText)
                    .font(.custom(textModifier.family, size: textModifier.size))
                    .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                }
                if self.image != nil {
                    Image(self.image!)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(width: self.imageSize, height: self.imageSize)
                }
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
                isUnderLine: true,
                image: Asset.icon.more
                ){_ in
                
            }
            .frame( alignment: .center)
        }
    }
}
#endif
