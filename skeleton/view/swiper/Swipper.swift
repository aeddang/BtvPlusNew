//
//  Swipper.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/10/06.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

protocol Swipper {
    var index: Int {get set}
    var isUserSwiping: Bool {get set}
    var autoResetSubscription:AnyCancellable? {get set}
    var sensitivity:CGFloat {get set}
    func creatResetTimer() -> AnyCancellable
    func reset(idx:Int)
    func getDragOffset(value:DragGesture.Value, geometry:GeometryProxy, offset:CGFloat)->CGFloat
    func getWillIndex(value:DragGesture.Value, minIdx:Int, maxIdx:Int)->Int
}

extension Swipper{
    var sensitivity:CGFloat { get{100} set{sensitivity = 100.0}}
    
    func getDragOffset(value:DragGesture.Value, geometry:GeometryProxy, offset:CGFloat = 0)->CGFloat {
        return value.translation.width + -geometry.size.width * CGFloat(self.index) - offset
    }
    
    func getWillIndex(value:DragGesture.Value, minIdx:Int = 0, maxIdx:Int)->Int {
        let predictedAmount = value.predictedEndTranslation.width
        var willIdx = self.index
        if predictedAmount < -self.sensitivity, self.index < maxIdx - 1 {
            willIdx += 1
        }
        else if predictedAmount > self.sensitivity, self.index > minIdx {
            willIdx -= 1
        }
        return willIdx
    }
    
    func creatResetTimer() -> AnyCancellable {
        self.autoResetSubscription?.cancel()
        return Timer.publish(
            every: 0.2, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.reset(idx:self.index)
            }
    }
}


