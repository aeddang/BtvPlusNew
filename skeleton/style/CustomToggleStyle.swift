//
//  CustomToggleStyle.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/27.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import SwiftUI

struct ColoredToggleStyle: ToggleStyle {
    var label = ""
    var font:Font? = nil
    var fontColor = Color.black
    var padding:CGFloat = 0
    var onColor = Color.green
    var offColor = Color.gray
    var thumbColor = Color.white

    func makeBody(configuration: Self.Configuration) -> some View {
        HStack() {
            Spacer()
            Text(label)
                .font(font)
                .foregroundColor(fontColor)
            Button(action: { configuration.isOn.toggle() } )
            {
                RoundedRectangle(cornerRadius: 16, style: .circular)
                    .fill(configuration.isOn ? onColor : offColor)
                    .frame(width: 50, height: 29)
                    .overlay(
                        Circle()
                            .fill(thumbColor)
                            .shadow(radius: 1, x: 0, y: 1)
                            .padding(1.5)
                            .offset(x: configuration.isOn ? 10 : -10))
                    .animation(Animation.easeInOut(duration: 0.1))
            }
        }
        .font(.title)
        .padding(.horizontal)
    }
}


