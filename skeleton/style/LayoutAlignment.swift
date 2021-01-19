//
//  LayoutAli.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI



struct LayoutTop: ViewModifier {
    var geometry:GeometryProxy
    var height:CGFloat = 0
    var margin:CGFloat = 0
    func body(content: Content) -> some View {
        let pos = ((geometry.size.height - height)/2.0)
        return content
            .frame(height:height)
            .offset(y:-pos + margin)
    }
}

struct LayoutBotttom: ViewModifier {
    var geometry:GeometryProxy
    var height:CGFloat = 0
    var margin:CGFloat = 0
    func body(content: Content) -> some View {
        let pos = ((geometry.size.height - height)/2.0)
        return content
            .frame(height:height)
            .offset(y:pos - margin)
    }
}

struct LayoutLeft: ViewModifier {
    var geometry:GeometryProxy
    var width:CGFloat = 0
    var margin:CGFloat = 0
    func body(content: Content) -> some View {
        let pos = ((geometry.size.width - width)/2.0) - margin
        return content
            .frame(width:width)
            .offset(x:-pos)
    }
}

struct LayoutRight: ViewModifier {
    var geometry:GeometryProxy
    var width:CGFloat = 0
    var margin:CGFloat = 0
    func body(content: Content) -> some View {
        let pos = ((geometry.size.width - width)/2.0) + margin
        return content
            .frame(width:width)
            .offset(x:pos)
    }
}

struct MatchParent: ViewModifier {
    var marginX:CGFloat = 0
    var marginY:CGFloat = 0
    var margin:CGFloat? = nil
    func body(content: Content) -> some View {
        let mx = margin == nil ? marginX : margin!
        let my = margin == nil ? marginY : margin!
        return content
            .frame(minWidth: 0, maxWidth: .infinity - (mx * 2.0), minHeight:0, maxHeight: .infinity - (my * 2.0))
            .offset(x:mx, y:my)
    }
}

struct MatchHorizontal: ViewModifier {
    var height:CGFloat = 0
    var margin:CGFloat = 0
    func body(content: Content) -> some View {
        return content
            .frame(minWidth: 0, maxWidth: .infinity - (margin * 2.0) , minHeight: height, maxHeight: height)
            .offset(x:margin)
    }
}

struct MatchVertical: ViewModifier {
    var width:CGFloat = 0
    var margin:CGFloat = 0
    func body(content: Content) -> some View {
        return content
            .frame(minWidth: width, maxWidth: width , minHeight:0, maxHeight: .infinity - (margin * 2.0))
            .offset(x:margin)
    }
}

struct LineHorizontal: ViewModifier {
    var height:CGFloat = Dimen.line.light
    var margin:CGFloat = 0
    func body(content: Content) -> some View {
        return content
            .frame(minWidth: 0, maxWidth: .infinity - (margin * 2.0) , minHeight: height, maxHeight: height)
            .offset(x:margin)
            .background(Color.app.white).opacity(0.1)
            
            
    }
}
struct LineVertical: ViewModifier {
    var width:CGFloat = Dimen.line.light
    var margin:CGFloat = 0
    func body(content: Content) -> some View {
        return content
            .frame(minWidth: width, maxWidth: width , minHeight:0, maxHeight: .infinity - (margin * 2.0))
            .offset(y:margin)
            .background(Color.app.white).opacity(0.1)
            
            
    }
}


