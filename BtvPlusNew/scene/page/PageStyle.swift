//
//  PageStyle.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/07.
//

import Foundation
import SwiftUI
struct PageFull: ViewModifier {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    var bgColor:Color = Color.brand.bg
    @State var marginStart:CGFloat = 0
    @State var marginEnd:CGFloat = 0
    func body(content: Content) -> some View {
        return content
            //.padding(.top, PageSceneObserver.safeAreaTop)
            .padding(.leading, self.marginStart)
            .padding(.trailing, self.marginEnd)
            .background(bgColor)
            .onReceive(self.sceneObserver.$isUpdated){ update in
                if !update {return}
                if self.pagePresenter.isFullScreen {
                    self.marginStart = 0
                    self.marginEnd = 0
                }else{
                    self.marginStart = self.sceneObserver.safeAreaStart
                    self.marginEnd = self.sceneObserver.safeAreaEnd
                }
                
            }
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
            .modifier(BoldTextStyle(
                size: Font.size.regular
            ))
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


