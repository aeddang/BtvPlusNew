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




