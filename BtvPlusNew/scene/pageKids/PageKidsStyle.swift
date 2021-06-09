//
//  PageStyle.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/01.
//

import Foundation
import SwiftUI

struct KidsContentEdges: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .padding(.vertical, DimenKids.margin.thin)
            .padding(.horizontal, DimenKids.margin.regular)
    }
}
struct KidsContentHorizontalEdges: ViewModifier {
    
    func body(content: Content) -> some View {
        return content
            .padding(.horizontal, DimenKids.margin.regular)
    }
}

struct KidsContentHorizontalEdgesTablet: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .padding(.horizontal, SystemEnvironment.isTablet ? DimenKids.margin.heavy : DimenKids.margin.regular)
    }
}

struct KidsContentVerticalEdges: ViewModifier {
    var margin:CGFloat = DimenKids.margin.thin
    func body(content: Content) -> some View {
        return content
            .padding(.vertical, DimenKids.margin.thin)
    }
}

struct PageKidsTitle: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .modifier(BlackTextStyleKids(
                size: SystemEnvironment.isTablet ? Font.sizeKids.light : Font.sizeKids.regular))
    }
}


struct KidsBlockTitle: ViewModifier {
    var color:Color = Color.app.white
    func body(content: Content) -> some View {
        return content
            .modifier(BoldTextStyleKids(
                size: Font.sizeKids.light,
                color:color
            ))
    }
}

struct KidsContentTitle: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .modifier(MediumTextStyleKids(
                size: Font.sizeKids.thin
            ))
    }
}




struct Shadow: ViewModifier {
    var color:Color = Color.app.blackRegular
    var opacity:Double = 0.25
    func body(content: Content) -> some View {
        return content
            .shadow(color: color.opacity(opacity), radius: Dimen.radius.thin, x: 0, y: 7)
    }
}

struct ShadowTop: ViewModifier {
    var color:Color = Color.app.grey
    var opacity:Double = 0.12
    func body(content: Content) -> some View {
        return content
            .shadow(color: color.opacity(opacity), radius: Dimen.radius.thin, x: 0, y: -7)
    }
}


struct ContentBox: ViewModifier {
    var margin:CGFloat = DimenKids.margin.medium
    func body(content: Content) -> some View {
        return content
            .padding(.all, margin)
            .background(Color.kids.bg)
            .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.heavy))
            .modifier(Shadow())
    }
}
