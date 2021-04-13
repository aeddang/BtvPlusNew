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
    var trailText:String? = nil
    var strikeText:String? = nil
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
    var strokeWidth:CGFloat = 0
    var margin:CGFloat = Dimen.margin.regular
    var isNew: Bool = false
    var isMore: Bool = false
    var icon:String? = nil
    var iconSize:CGFloat = Dimen.icon.thin
    let action: (_ idx:Int) -> Void
    
    init(
        text:String,
        trailText:String? = nil,
        strikeText:String? = nil,
        index: Int = 0,
        isSelected: Bool = true,
        image:String? = nil,
        imageOn:String? = nil,
        textModifier:TextModifier? = nil,
        size:CGFloat? = nil,
        imageSize:CGFloat? = nil,
        margin:CGFloat? = nil,
        bgColor:Color? = nil,
        strokeWidth:CGFloat? = nil,
        action:@escaping (_ idx:Int) -> Void )
    {
        self.text = text
        self.trailText = trailText
        self.strikeText = strikeText
        self.index = index
        self.isSelected = isSelected
        self.image = image
        self.imageOn = imageOn
        self.action = action
        self.textModifier = textModifier ?? self.textModifier
        self.size = size ?? self.size
       
        self.imageSize = imageSize ?? self.imageSize
        self.bgColor = bgColor ?? self.bgColor
        self.strokeWidth = strokeWidth ?? self.strokeWidth
        self.margin = margin ?? self.margin
    }
    // type new
    init(
        text:String,
        image:String?,
        isNew: Bool,
        action:@escaping (_ idx:Int) -> Void )
    {
        self.text = text
        self.image = image
        self.isNew = isNew
        self.textModifier = TextModifier(
            family: Font.family.bold,
            size: Font.size.lightExtra,
            color: Color.app.white,
            activeColor: Color.app.white
        )
        self.imageSize = Dimen.icon.thinExtra
        self.bgColor = Color.app.blueLight
        self.action = action
    }
    
    // type more
    init(
        text:String,
        isMore: Bool,
        icon:String? = nil,
        iconSize:CGFloat? = nil,
        bgColor:Color = Color.transparent.clearUi,
        action:@escaping (_ idx:Int) -> Void )
    {
        self.text = text
        self.isMore = isMore
        self.bgColor = bgColor
        self.action = action
        self.icon = icon
        self.iconSize = iconSize ?? self.iconSize
        self.margin = Dimen.margin.light
        self.size = Dimen.button.heavyExtra
    }
   
    // type stroke
    init(
        text:String,
        strokeWidth:CGFloat?,
        action:@escaping (_ idx:Int) -> Void )
    {
        self.text = text
        self.textModifier = TextModifier(
            family: Font.family.bold,
            size: Font.size.lightExtra,
            color: Color.app.greyLight,
            activeColor: Color.app.white
        )
        self.strokeWidth = strokeWidth ?? 1
        self.bgColor = Color.transparent.clearUi
        self.action = action
        self.size = Dimen.button.regularExtra
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
                    if let image = self.image  {
                        Image(self.isSelected ? ( self.imageOn ?? image )  : image)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: self.imageSize, height: self.imageSize)
                    }
                    Text(self.text)
                        .font(.custom(textModifier.family, size: textModifier.size))
                        .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    
                    if self.trailText != nil || self.strikeText != nil {
                        Spacer()
                        if let strikeText = self.strikeText {
                            Text(strikeText)
                                .font(.custom(textModifier.family, size: Font.size.thinExtra))
                                .strikethrough()
                                .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                        }
                        if let trailText = self.trailText {
                            Text(trailText )
                                .font(.custom(textModifier.family, size: textModifier.size))
                                .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                        }
                    }
                    if self.isNew {
                        Image(Asset.icon.new)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.tinyExtra, height: Dimen.icon.tinyExtra)
                    }
                    if let icon = self.icon {
                        Spacer()
                        Image(icon)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                            .frame(height: self.iconSize)
                    }
                    if self.isMore{
                        Spacer()
                        Image(Asset.icon.more)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                        .padding(.trailing, Dimen.margin.tinyExtra)
                    }
                }
                .padding(.horizontal, self.isMore ? 0 : self.margin)
                if !self.isSelected {
                    Spacer().modifier(MatchParent()).background(Color.transparent.black45)
                }
            }
            .modifier( MatchHorizontal(height: self.size) )
            .background(self.bgColor )
            .overlay(
                Rectangle().stroke( Color.app.greyExtra ,lineWidth: self.strokeWidth )
            )
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

