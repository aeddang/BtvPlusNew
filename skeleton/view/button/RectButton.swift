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
    var textTailing:String = ""
    var index: Int = 0
    var isSelected: Bool = false
    var textModifier:TextModifier = TextModifier(
        family:Font.family.bold,
        size:Font.size.thin,
        color: Color.app.white,
        activeColor: Color.brand.primary
    )
    var bgColor = Color.transparent.black50
    var bgActiveColor = Color.brand.primary
    var fixSize:CGFloat? = nil
    var progress:Float = 0
    var cornerRadius:CGFloat = 0
    var padding:CGFloat = Dimen.margin.thin
    var icon:String? = nil
    let action: (_ idx:Int) -> Void
    
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            ZStack{
                if self.fixSize != nil {
                    ZStack(alignment: .leading){
                        Spacer().frame( width: self.fixSize! )
                        Spacer()
                            .modifier(MatchVertical(width:self.fixSize! * CGFloat(self.progress)))
                            .background(self.bgActiveColor)
                    }
                }
                HStack{
                    Text(self.text)
                        .font(.custom(textModifier.family, size: textModifier.size))
                        .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                    + Text(self.textTailing)
                        .font(.custom(textModifier.family, size: textModifier.size))
                        .foregroundColor( textModifier.activeColor )
                    
                    if self.icon != nil {
                        Image(self.icon!)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.tinyExtra, height: Dimen.icon.tinyExtra)
                    }
                }
                    
            }
            .padding(.horizontal, self.padding)
            .frame(height:Dimen.button.light)
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
            text: "test",
                textTailing: "1/6",
                fixSize: 100,
                progress: 0.5,
                padding: 0
                ){_ in
                
            }
            .frame( alignment: .center)
        }
    }
}
#endif
