//
//  PageStyle.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/01.
//

import Foundation
import SwiftUI

struct ContentEdgesKids: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .padding(.vertical, DimenKids.margin.thin)
            .padding(.horizontal, DimenKids.margin.regular)
    }
}
struct ContentHorizontalEdgesKids: ViewModifier {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @State var marginStart:CGFloat = 0
    @State var marginEnd:CGFloat = 0

    func body(content: Content) -> some View {
        return content
            .padding(.leading, self.marginStart + DimenKids.margin.regular)
            .padding(.trailing, self.marginEnd + DimenKids.margin.regular)
            .onAppear(){
                self.marginStart = self.sceneObserver.safeAreaStart
                self.marginEnd = self.sceneObserver.safeAreaEnd
            }
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
struct ContentHeaderEdgesKids: ViewModifier {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @State var marginStart:CGFloat = 0
   
    func body(content: Content) -> some View {
        return content
            .padding(.leading, self.marginStart + DimenKids.margin.regular)
            .onAppear(){
                self.marginStart = self.sceneObserver.safeAreaStart
            }
            .onReceive(self.sceneObserver.$isUpdated){ update in
                if !update {return}
                if self.pagePresenter.isFullScreen {
                    self.marginStart = 0
                }else{
                    self.marginStart = self.sceneObserver.safeAreaStart
                }
                
            }
    }
}

struct ContentVerticalEdgesKids: ViewModifier {
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


struct BlockTitleKids: ViewModifier {
    var color:Color = Color.app.brownDeep
    func body(content: Content) -> some View {
        return content
            .modifier(BoldTextStyleKids(
                size: Font.sizeKids.light,
                color:color
            ))
    }
}

struct ContentTitleKids: ViewModifier {
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
