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
    var isNew: Bool = false
    var isMore: Bool = false
    let action: (_ idx:Int) -> Void
    
    init(
        text:String,
        index: Int = 0,
        isSelected: Bool = true,
        image:String? = nil,
        imageOn:String? = nil,
        textModifier:TextModifier? = nil,
        size:CGFloat? = nil,
        imageSize:CGFloat? = nil,
        bgColor:Color? = nil,
        action:@escaping (_ idx:Int) -> Void )
    {
        self.text = text
        self.index = index
        self.isSelected = isSelected
        self.image = image
        self.imageOn = imageOn
        self.action = action
        self.textModifier = textModifier ?? self.textModifier
        self.size = size ?? self.size
        self.imageSize = imageSize ?? self.imageSize
        self.bgColor = bgColor ?? self.bgColor
    }
    // type new
    init(
        text:String,
        image:String?,
        isNew: Bool,
        textModifier:TextModifier = TextModifier(
            family: Font.family.bold,
            size: Font.size.lightExtra,
            color: Color.app.white,
            activeColor: Color.app.white
        ),
        imageSize:CGFloat = Dimen.icon.thinExtra,
        bgColor:Color = Color.app.blueLight,
        action:@escaping (_ idx:Int) -> Void )
    {
        self.text = text
        self.image = image
        self.isNew = isNew
        self.imageSize = imageSize
        self.bgColor = bgColor
        self.action = action
    }
    
    // type more
    init(
        text:String,
        isMore: Bool,
        bgColor:Color = Color.transparent.black1,
        action:@escaping (_ idx:Int) -> Void )
    {
        self.text = text
        self.isMore = isMore
        self.bgColor = bgColor
        self.action = action
    }
   
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            ZStack{
                HStack(spacing:Dimen.margin.tinyExtra){
                    if self.isMore{
                        Spacer().frame(width: Dimen.margin.thin)
                    }
                    if self.image != nil {
                        Image(self.isSelected ? ( self.imageOn ?? self.image! )  : self.image!)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: self.imageSize, height: self.imageSize)
                    }
                    Text(self.text)
                        .font(.custom(textModifier.family, size: textModifier.size))
                        .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                    
                    if self.isNew {
                        Image(Asset.icon.new)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.tinyExtra, height: Dimen.icon.tinyExtra)
                    }
                    if self.isMore{
                        Spacer()
                        Image(Asset.icon.more)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                    }
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
                isMore: true
            ){_ in
                
            }
            .frame( alignment: .center)
            .background(Color.app.blue)
        }
    }
}
#endif

