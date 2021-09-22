//
//  TextStyle.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/07.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct TextModifier {
    var family:String = Font.family.regular
    var size:CGFloat = Font.size.regular
    var color: Color = Color.app.whiteDeep
    var activeColor: Color = Color.app.white
    var sizeScale: CGFloat = 1.1
    
    func getTextWidth(_ text:String) -> CGFloat{
        return text.textSizeFrom(fontSize: size * sizeScale).width
    }
}


struct BlackTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.black, size:Font.size.black, color: Color.app.white)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
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
            .truncationMode(.tail)
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            .lineSpacing(Font.spacing.regular)
    }
}

struct BoldTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.bold,size:Font.size.bold, color: Color.app.white)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
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
            .truncationMode(.tail)
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            .lineSpacing(Font.spacing.regular)
            
    }
}
struct MediumTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.medium,size:Font.size.medium)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
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
            .truncationMode(.tail)
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            .lineSpacing(Font.spacing.regular)
            
    }
}

struct RegularTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.regular,size:Font.size.regular)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
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
            .truncationMode(.tail)
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            .lineSpacing(Font.spacing.regular)
            
    }
}

struct LightTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.light,size:Font.size.light)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
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
            .truncationMode(.tail)
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            .lineSpacing(Font.spacing.regular)
    }
}


struct NumberBoldTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.robotoBold,size:Font.size.bold)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
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
            .truncationMode(.tail)
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            .lineSpacing(Font.spacing.regular)
    }
}

struct NumberMediumTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.robotoMedium,size:Font.size.medium)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
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
            .truncationMode(.tail)
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            .lineSpacing(Font.spacing.regular)
            
    }
}

struct NumberLightTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.robotoLight,size:Font.size.light)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
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
            .truncationMode(.tail)
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            .lineSpacing(Font.spacing.regular)
           
    }
}



struct CustomTextStyle: ViewModifier {
    var textModifier:TextModifier
    init(textModifier:TextModifier) {self.textModifier = textModifier}
    func body(content: Content) -> some View {
        return content
            .truncationMode(.tail)
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            .lineSpacing(Font.spacing.regular)
    }
}


