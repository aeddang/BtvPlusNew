//
//  TextStyle.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/07.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct TextModifierKids {
    var family:String = Font.familyKids.regular
    var size:CGFloat = Font.sizeKids.regular
    var color: Color = Color.app.brownDeep
    var activeColor: Color = Color.app.ivory
    var sizeScale: CGFloat = 1.1
    
    func getTextWidth(_ text:String) -> CGFloat{
        return text.textSizeFrom(fontSize: size * sizeScale).width
    }
}


struct BlackTextStyleKids: ViewModifier {
    var textModifier = TextModifierKids(family:Font.familyKids.black, size:Font.sizeKids.black)
    init(textModifier:TextModifierKids) {self.textModifier = textModifier}
    init(size:CGFloat? = nil, color: Color? = nil) {
        if let size = size {
            self.textModifier.size = size
        }
        if let color = color {
            self.textModifier.color = color
            self.textModifier.activeColor = color
        }
        
    }
    func body(content: Content) -> some View {
        return content
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            
    }
}

struct BoldTextStyleKids: ViewModifier {
    var textModifier = TextModifierKids(family:Font.familyKids.bold,size:Font.sizeKids.bold)
    init(textModifier:TextModifierKids) {self.textModifier = textModifier}
    init(size:CGFloat? = nil, color: Color? = nil) {
        if let size = size {
            self.textModifier.size = size
        }
        if let color = color {
            self.textModifier.color = color
            self.textModifier.activeColor = color
        }
        
    }
    func body(content: Content) -> some View {
        return content
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            .lineSpacing(2)
            
    }
}
struct MediumTextStyleKids: ViewModifier {
    var textModifier = TextModifierKids(family:Font.familyKids.medium,size:Font.sizeKids.medium)
    init(textModifier:TextModifierKids) {self.textModifier = textModifier}
    init(size:CGFloat? = nil, color: Color? = nil) {
        if let size = size {
            self.textModifier.size = size
        }
        if let color = color {
            self.textModifier.color = color
            self.textModifier.activeColor = color
        }
        
    }
    func body(content: Content) -> some View {
        return content
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            .lineSpacing(2)
    }
}

struct RegularTextStyleKids: ViewModifier {
    var textModifier = TextModifierKids(family:Font.familyKids.regular,size:Font.sizeKids.regular)
    init(textModifier:TextModifierKids) {self.textModifier = textModifier}
    init(size:CGFloat? = nil, color: Color? = nil) {
        if let size = size {
            self.textModifier.size = size
        }
        if let color = color {
            self.textModifier.color = color
            self.textModifier.activeColor = color
        }
        
    }
    func body(content: Content) -> some View {
        return content
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            .lineSpacing(2)
    }
}

struct LightTextStyleKids: ViewModifier {
    var textModifier = TextModifierKids(family:Font.familyKids.light,size:Font.sizeKids.light)
    init(textModifier:TextModifierKids) {self.textModifier = textModifier}
    init(size:CGFloat? = nil, color: Color? = nil) {
        if let size = size {
            self.textModifier.size = size
        }
        if let color = color {
            self.textModifier.color = color
            self.textModifier.activeColor = color
        }
        
    }
    func body(content: Content) -> some View {
        return content
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            .lineSpacing(2)
    }
}




