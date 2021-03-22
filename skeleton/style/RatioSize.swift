//
//  RatioStyle.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct Ratio16_9: ViewModifier {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var geometry:GeometryProxy? = nil
    var width:CGFloat = 0
    var horizontalEdges:CGFloat = 0
    var isFullScreen:Bool = false
    func body(content: Content) -> some View {
        let w =  isFullScreen ?  geometry?.size.width ?? sceneObserver.screenSize.width
            : (geometry?.size.width ?? width) - (horizontalEdges * 2.0)
        let h = isFullScreen ? ( geometry?.size.height ?? sceneObserver.screenSize.height ) : ( w * 9.0 / 16.0 )
        return content
            .frame(
                width:w,
                height:h )
    }
}


struct Ratio9_16: ViewModifier {
    var geometry:GeometryProxy? = nil
    var width:CGFloat = 0
    var horizontalEdges:CGFloat = 0
   
    func body(content: Content) -> some View {
        let w = (geometry?.size.width ?? width) - (horizontalEdges * 2.0)
        let h = w * 16.0 / 9.0
        return content
            .frame(
                width:w,
                height:h )
    }
}

struct Ratio4_3: ViewModifier {
    var geometry:GeometryProxy? = nil
    var width:CGFloat = 0
    var horizontalEdges:CGFloat = 0
    func body(content: Content) -> some View {
        let w =  (geometry?.size.width ?? width) - (horizontalEdges * 2.0)
        return content
            .frame(
                width:w,
                height:w * 3.0 / 4.0 )
    }
}

struct Ratio1_1: ViewModifier {
    var geometry:GeometryProxy? = nil
    var width:CGFloat = 0
    var horizontalEdges:CGFloat = 0
    func body(content: Content) -> some View {
        let w =  (geometry?.size.width ?? width) - (horizontalEdges * 2.0)
        return content
            .frame(width:w, height:w)
    }
}

