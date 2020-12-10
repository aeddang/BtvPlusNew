//
//  ProgressSlider.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/18.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

struct ProgressSlider: View {

    @Binding var progress: Float // or some value binded
    var onEditingChanged: (Float) -> Void = { _ in }
   
    @State var dragOpacity:Double = 0.0
    @State var drag: Float = 0.0
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.secondary)
                Rectangle()
                    .foregroundColor(.accentColor)
                    .frame(width: geometry.size.width * CGFloat(self.progress))
                Rectangle()
                    .foregroundColor(.primary)
                    .opacity(self.dragOpacity)
                .frame(width: geometry.size.width * CGFloat(self.drag))
            }
            .cornerRadius(5)
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged({ value in
                    let d = min(max(0, Float(value.location.x / geometry.size.width)), 1)
                    self.drag = d
                    self.dragOpacity = 0.3
                })
            
                .onEnded({ value in
                    self.onEditingChanged(self.drag)
                    self.dragOpacity = 0.0
                }))
        }
    }
}
