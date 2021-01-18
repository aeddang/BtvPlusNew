//
//  FillButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/11.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct FillButton: View, SelecterbleProtocol{
    let text:String
    var index: Int = 0
    var isSelected: Bool = true
    var image:String? = nil
    var imageOn:String? = nil
    var textModifier:TextModifier = TextModifier(
        family: Font.family.bold,
        size: Font.size.regular,
        color: Color.app.white,
        activeColor: Color.app.white
    )
    var size:CGFloat = Dimen.button.medium
    var imageSize:CGFloat = Dimen.icon.light
    var bgColor:Color = Color.brand.primary
    let action: (_ idx:Int) -> Void
   
    
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            ZStack{
                HStack(spacing:Dimen.margin.tiny){
                    if self.image != nil {
                        Image(self.isSelected ? self.imageOn! : self.image!)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: self.imageSize, height: self.imageSize)
                    }
                    Text(self.text)
                        .font(.custom(textModifier.family, size: textModifier.size))
                        .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                }
                if !self.isSelected {
                    Spacer().modifier(MatchParent()).background(Color.transparent.black45)
                }
            }
            .modifier( MatchHorizontal(height: self.size) )
            .background(self.bgColor )
        }
        
        
    }
}
#if DEBUG
struct FillButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            FillButton(
                text: "test",
                isSelected: true,
                image: Asset.test
            ){_ in
                
            }
            .frame( alignment: .center)
        }
    }
}
#endif

