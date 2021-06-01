//
//  PageStyle.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/01.
//

import Foundation
import SwiftUI

struct ContentEdges: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .padding(.all, Dimen.margin.thin)
    }
}
struct ContentHorizontalEdges: ViewModifier {
    
    func body(content: Content) -> some View {
        return content
            .padding(.horizontal, Dimen.margin.thin)
    }
}

struct ContentHorizontalEdgesTablet: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .padding(.horizontal, SystemEnvironment.isTablet ? Dimen.margin.heavy : Dimen.margin.thin)
    }
}

struct ContentVerticalEdges: ViewModifier {
    var margin:CGFloat = Dimen.margin.thin
    func body(content: Content) -> some View {
        return content
            .padding(.vertical, Dimen.margin.thin)
    }
}

struct PageTitle: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .modifier(BlackTextStyle(size: Font.size.bold))
    }
}


struct BlockTitle: ViewModifier {
    var color:Color = Color.app.white
    func body(content: Content) -> some View {
        return content
            .modifier(BoldTextStyle(
                size: Font.size.regular,
                color:color
            ))
    }
}

struct ContentTitle: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .modifier(MediumTextStyle( size: Font.size.regular))
    }
}




