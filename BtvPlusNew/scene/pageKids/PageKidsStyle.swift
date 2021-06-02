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
            .modifier(KidsBlackTextStyle(size: SystemEnvironment.isTablet ? Font.sizeKids.medium : Font.sizeKids.regular))
    }
}


struct KidsBlockTitle: ViewModifier {
    var color:Color = Color.app.white
    func body(content: Content) -> some View {
        return content
            .modifier(KidsBoldTextStyle(
                size: SystemEnvironment.isTablet ? Font.sizeKids.medium : Font.sizeKids.light,
                color:color
            ))
    }
}

struct KidsContentTitle: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .modifier(KidsMediumTextStyle(
                size: SystemEnvironment.isTablet ? Font.sizeKids.light : Font.sizeKids.thin
            ))
    }
}




