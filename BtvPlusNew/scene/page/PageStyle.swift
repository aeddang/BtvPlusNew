//
//  PageStyle.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/07.
//

import Foundation
import SwiftUI
struct PageFull: ViewModifier {
    var bgColor:Color = Color.brand.bg
    func body(content: Content) -> some View {
        return content
            .padding(.top, PageSceneObserver.safeAreaTop)
            .background(bgColor)
    }
}
struct PageEdges: ViewModifier {
    var bgColor:Color = Color.brand.bg
    func body(content: Content) -> some View {
        return content
            .padding(.bottom, PageSceneObserver.safeAreaBottom)
            .padding(.top, Dimen.app.top + PageSceneObserver.safeAreaTop)
            .background(bgColor)
    }
}
struct PageEdgeTop: ViewModifier {
    var bgColor:Color = Color.brand.bg
    func body(content: Content) -> some View {
        return content
            .padding(.top, Dimen.app.top + PageSceneObserver.safeAreaTop)
            .padding(.bottom, PageSceneObserver.safeAreaBottom)
            .background(bgColor)
    }
}

struct PageEdgeBottom: ViewModifier {
    var bgColor:Color = Color.brand.bg
    func body(content: Content) -> some View {
        return content
            .padding(.top, PageSceneObserver.safeAreaTop)
            .padding(.bottom, PageSceneObserver.safeAreaBottom)
            .background(bgColor)
    }
}
struct ContentEdges: ViewModifier {
    var margin:CGFloat = Dimen.margin.thin
    func body(content: Content) -> some View {
        return content
            .padding(.all, margin)
    }
}
struct ContentHorizontalEdges: ViewModifier {
    var margin:CGFloat = Dimen.margin.thin
    func body(content: Content) -> some View {
        return content
            .padding(.horizontal, margin)
    }
}

struct ContentVerticalEdges: ViewModifier {
    var margin:CGFloat = Dimen.margin.thin
    func body(content: Content) -> some View {
        return content
            .padding(.vertical, margin)
    }
}

struct PageTitle: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .modifier(BlackTextStyle(size: Font.size.bold))
    }
}

struct BlockTitle: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .modifier(BoldTextStyle())
            .modifier(ContentHorizontalEdges())
    }
}

struct ContentTitle: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .modifier(BoldTextStyle())
    }
}

struct PartTitle: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .modifier(BlackTextStyle(size: Font.size.regular))
    }
}


