//
//  RectButton.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct KidsRectButton: View, SelecterbleProtocol{
    let text:String
    var index: Int = 0
    var isSelected: Bool = false
    var textModifier:KidsTextModifier = KidsTextModifier(
        family:Font.familyKids.bold,
        size:SystemEnvironment.isTablet ? Font.sizeKids.mediumExtra : Font.sizeKids.lightExtra,
        color: Color.app.brownDeep,
        activeColor: Color.app.white
    )
    var bgColor = Color.app.white
    var bgActiveColor = Color.kids.primary
    var size:CGSize = DimenKids.button.mediumRect
    var cornerRadius:CGFloat = DimenKids.radius.light
    
    let action: (_ idx:Int) -> Void
    
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            ZStack{
                Text(self.text)
                    .font(.custom(textModifier.family, size: textModifier.size))
                    .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
            }
            .frame(width:self.size.width, height:self.size.height)
            .background(self.isSelected ? self.bgActiveColor : self.bgColor)
            .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
            
        }
    }
}
#if DEBUG
struct KidsRectButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            KidsRectButton(
            text: "test",
                isSelected: true
                ){_ in
                
            }
            
        }
    }
}
#endif
