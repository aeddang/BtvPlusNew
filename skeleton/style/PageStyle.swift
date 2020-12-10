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

struct ContentPartDivision: ViewModifier {
    var bgColor = Color.app.whiteDeep
    func body(content: Content) -> some View {
        return content
            .modifier(MatchHorizontal(height: Dimen.line.heavy))
            .background(bgColor)
    }
}


struct ContentShadowTop: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .shadow(color:Color(.sRGBLinear, white: 0, opacity: 0.1),
                radius: Dimen.radius.thin, y:-Dimen.radius.thin)
            
    }
}

struct ContentShadow: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .shadow(color:Color(.sRGBLinear, white: 0, opacity: 0.1),
                    radius: Dimen.radius.thin)
    }
}

struct ContentTitle: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .modifier(BlackTextStyle(size: Font.size.regularExtra))
            .modifier(ContentHorizontalEdges())
    }
}

struct PartTitle: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .modifier(BlackTextStyle(size: Font.size.regularExtra))
    }
}

struct PageTitle: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .modifier(BlackTextStyle(size: Font.size.boldExtra))
    }
}

struct ScrollRowInset: ViewModifier {
    var firstIndex = 1
    var index:Int = -1
    var margin:CGFloat = Dimen.margin.thinExtra
    var marginTop:CGFloat = Dimen.margin.medium
    func body(content: Content) -> some View {
        return content
                .padding(.top , (index == firstIndex) ? marginTop : 0)
                .padding(.leading, Dimen.margin.medium)
                .padding(.bottom, margin)
                .padding(.trailing, Dimen.margin.medium)
    }
}
struct ListRowInset: ViewModifier {
    var firstIndex = 1
    var index:Int = -1
    var margin:CGFloat = Dimen.margin.thinExtra
    var marginTop:CGFloat = Dimen.margin.medium
    func body(content: Content) -> some View {
        return content
            .listRowInsets(
                .init(
                    top: (index == firstIndex) ? marginTop : 0,
                    leading:  Dimen.margin.medium,
                    bottom: margin,
                    trailing: Dimen.margin.medium)
        )
    }
}

struct BottomFunctionTab: ViewModifier {
    var margin = Dimen.margin.medium
    func body(content: Content) -> some View {
        return content
            .padding(.all, margin)
            .background(Color.app.white)
            //.clipShape(RoundedRectangle(cornerRadius: Dimen.radius.regular))
            .mask(
                ZStack(alignment: .bottom){
                    RoundedRectangle(cornerRadius: Dimen.radius.regular)
                    Rectangle().modifier(MatchHorizontal(height: Dimen.radius.regular))
                }
            )
            //.cornerRadius(Dimen.radius.regular, corners: .topLeft)
            //.cornerRadius(Dimen.radius.regular, corners: .topRight)
            .modifier(ContentShadowTop())
            .edgesIgnoringSafeArea(.all)
            
    }
}

struct GradientHolizentalMask: ViewModifier {
    var margin = Dimen.margin.medium
    func body(content: Content) -> some View {
        return content
            .modifier(MatchVertical(width: margin))
            .background(LinearGradient(gradient:
                Gradient( colors: [
                    Color.app.white, Color.app.white.opacity(0)]),
                    startPoint: .leading, endPoint: .trailing)
            )
    }
}
struct GradientVerticalMask: ViewModifier {
    var margin = Dimen.margin.medium
    func body(content: Content) -> some View {
        return content
            .modifier(MatchHorizontal(height: margin))
            .background(LinearGradient(gradient:
                Gradient( colors: [
                    Color.app.white, Color.app.white.opacity(0)]),
                    startPoint: .top, endPoint: .bottom)
            )
    }
}
