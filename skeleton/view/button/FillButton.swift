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
    var subText:String? = nil
    var trailText:String? = nil
    var strikeText:String? = nil
    var moreText:String? = nil
    var index: Int = 0
    var isSelected: Bool = true
    var imageAni:[String]? = nil
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
    var moreSize:CGFloat = Dimen.icon.regular
    var bgColor:Color = Color.brand.primary
    var strokeWidth:CGFloat = 0
    var strokeColor:Color = Color.app.greyExtra
    var margin:CGFloat = Dimen.margin.regular
    var isNew: Bool = false
    var count: Int? = nil
    var isMore: Bool = false
    var icon:String? = nil
    var iconSize:CGFloat = Dimen.icon.thin
    let action: (_ idx:Int) -> Void
    
    init(
        text:String,
        subText:String? = nil,
        trailText:String? = nil,
        strikeText:String? = nil,
        index: Int = 0,
        isSelected: Bool = true,
        imageAni:[String]? = nil,
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
        self.subText = subText
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
    // type center + new
    init(
        text:String,
        imageAni:[String]? = nil,
        image:String?,
        isNew: Bool,
        count: Int? = nil,
        bgColor:Color = Color.app.blueLight,
        action:@escaping (_ idx:Int) -> Void )
    {
        self.text = text
        self.imageAni = imageAni
        self.image = image
        self.isNew = isNew
        self.count = count
        self.textModifier = TextModifier(
            family: Font.family.bold,
            size: Font.size.lightExtra,
            color: Color.app.white,
            activeColor: Color.app.white
        )
        self.imageSize = Dimen.icon.thinExtra
        self.bgColor = bgColor
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
    
    // type more + text
    init(
        text:String,
        isMore: Bool,
        moreText:String,
        image:String? = nil,
        bgColor:Color = Color.transparent.clearUi,
        action:@escaping (_ idx:Int) -> Void )
    {
        self.text = text
        self.moreText = moreText
        self.isMore = isMore
        self.bgColor = bgColor
        self.action = action
        self.image = image
        self.imageSize = Dimen.icon.regularExtra
        self.moreSize = Dimen.icon.tiny
        self.margin = Dimen.margin.light
        self.size = Dimen.button.heavyExtra
        self.textModifier = TextModifier(
            family: Font.family.bold,
            size: Font.size.lightExtra,
            color: Color.app.white,
            activeColor: Color.app.white
        )
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
        self.strokeColor = Color.app.white.opacity(0.3)
        self.bgColor = Color.transparent.clearUi
        self.action = action
        self.size = Dimen.button.regular
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
                    if let ani = self.imageAni  {
                        ImageAnimation(images: ani, isLoof:false, isRunning: .constant(true) )
                            .frame(width: self.imageSize*1.2, height: self.imageSize*1.2)
                    }
                    else if let image = self.image  {
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
                    if let subText = self.subText  {
                        Text(subText)
                            .font(.custom(Font.family.medium, size: textModifier.size))
                            .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                            .lineLimit(1)
                            .padding(.leading, -Dimen.margin.tinyExtra)
                    }
                    if self.trailText != nil || self.strikeText != nil {
                        Spacer()
                        if let strikeText = self.strikeText {
                            Text(strikeText)
                                .font(.custom(textModifier.family, size: Font.size.thinExtra))
                                .strikethrough()
                                .foregroundColor(self.isSelected ? self.textModifier.activeColor : textModifier.color)
                        }
                        if let trailText = self.trailText {
                            Text(trailText )
                                .font(.custom(textModifier.family, size:  self.textModifier.size))
                                .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                        }
                    }
                    if self.isNew {
                        if let count = self.count {
                            Text(count == 99 ? "99+" : count.description)
                                .kerning(Font.kern.thin)
                                .modifier(BoldTextStyle(
                                    size: Font.size.micro,
                                    color: Color.app.white
                                ))
                                
                                .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                                .background(Color.brand.primary)
                                .clipShape(Circle())
                            
                        } else {
                            Image(Asset.icon.new)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.tinyExtra, height: Dimen.icon.tinyExtra)
                        }
                        
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
                        if let moreText = self.moreText {
                            Text(moreText)
                                .modifier(MediumTextStyle(
                                    size: Font.size.thinExtra,
                                    color: Color.app.greyLight
                                ))
                        }
                        Image(Asset.icon.more)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: self.moreSize, height: self.moreSize)
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
                Rectangle().stroke( self.strokeColor ,lineWidth: self.strokeWidth )
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

