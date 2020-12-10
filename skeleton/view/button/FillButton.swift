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
    @Binding var isSelected: Bool
    let text:String
    let index: Int 
    let image:String?
    let imageOn:String?
    let textModifier:TextModifier
    let size:CGFloat
    let imageSize:CGFloat
    let bgColor:Color
    let action: (_ idx:Int) -> Void
   
    init(
        text:String,
        index: Int = 0,
        image:String? = nil,
        imageOn:String? = nil,
        isSelected:Binding<Bool>? = nil,
        textModifier:TextModifier? = nil,
        size:CGFloat = Dimen.button.heavy,
        imageSize:CGFloat =  Dimen.icon.light,
        bgColor:Color = Color.app.whiteDeep,
        action:@escaping (_ idx:Int) -> Void
    )
    {
        self.text = text
        self.index = index
        self.image = image
        self.imageOn = imageOn ?? image
        self.size = size
        self.imageSize = imageSize
        self.bgColor = bgColor
        self._isSelected = isSelected ?? Binding.constant(false)
        self.textModifier = textModifier ??
            TextModifier(
                family: Font.family.bold,
                size: Font.size.light,
                color: Color.app.greyDeep,
                activeColor: Color.app.white
            )
        self.action = action
        
    }
    
    
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            HStack(spacing:Dimen.margin.thinExtra){
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
            .modifier( MatchHorizontal(height: self.size) )
            .background(self.isSelected ? Color.brand.primary : self.bgColor)
            .clipShape(RoundRectMask(radius: Dimen.radius.light))
        }
        
        
    }
}
#if DEBUG
struct FillButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            FillButton(
                text: "test",
                image: Asset.test,
                isSelected: .constant(true)
            ){_ in
                
            }
            .frame( alignment: .center)
        }
    }
}
#endif

