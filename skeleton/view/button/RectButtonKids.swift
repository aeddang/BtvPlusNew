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
    var text:String
    var icon:String? = nil
    var trailText:String? = nil
    var strikeText:String? = nil
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
    var isMore: Bool = false
    let action: (_ idx:Int) -> Void
    
    
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            HStack(spacing:0){
                if self.isFixSize {
                    HStack(spacing:0){
                        RectButtonKidsBody(
                            text: self.text,
                            icon: self.icon,
                            trailText: self.trailText,
                            strikeText: self.strikeText,
                            isSelected: self.isSelected,
                            textModifier: self.textModifier,
                            isMore: self.isMore)
                        }
                    .frame(width:self.size.width)
                } else {
                    
                    RectButtonKidsBody(
                        text: self.text,
                        icon: self.icon,
                        trailText: self.trailText,
                        strikeText: self.strikeText,
                        isSelected: self.isSelected,
                        textModifier: self.textModifier,
                        isMore: self.isMore)
                }
            }
            .padding(.horizontal, self.isFixSize ? 0 : DimenKids.margin.regular)
            .frame(height:self.size.height)
            .background(self.isSelected ? self.bgActiveColor : self.bgColor)
            .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
            
        }
    }
    struct RectButtonKidsBody:View {
        var text:String
        var icon:String? = nil
        var trailText:String? = nil
        var strikeText:String? = nil
        var isSelected: Bool = false
        var textModifier:TextModifierKids
        var isMore: Bool = false
        
        var body :some View {
            if let icon = self.icon {
                Image(icon)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(width: SystemEnvironment.isTablet ? DimenKids.icon.tinyExtra :  DimenKids.icon.tiny)
                    .padding(.trailing, DimenKids.margin.tiny)
            }
            Text(self.text)
                .font(.custom(textModifier.family, size: textModifier.size))
                .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
            if let strikeText = self.strikeText {
                Text(strikeText)
                    .font(.custom(textModifier.family, size: Font.sizeKids.thinExtra))
                    .strikethrough()
                    .foregroundColor(self.isSelected ? self.textModifier.activeColor : textModifier.color)
                    .opacity(0.7)
                    .padding(.leading, DimenKids.margin.tiny)
            
            }
            if let trailText = self.trailText {
                Text(trailText )
                    .font(.custom(textModifier.family, size:  self.textModifier.size))
                    .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                    .padding(.leading, DimenKids.margin.micro)
            }
            
            if self.isMore {
                Image(AssetKids.icon.more)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(height: DimenKids.icon.microUltra)
                    .padding(.leading, DimenKids.margin.thin)
            }
        }
    }
    
}
#if DEBUG
struct RectButtonKids_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            RectButtonKids(
            text: "testㄴㅊㄴㅇㄴ",
                isSelected: true,
                isFixSize: false
                ){_ in
                
            }
            
        }
    }
}
#endif
