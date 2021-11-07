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
    var padding:CGFloat = 0
    var onColor = Color.app.white
    var offColor = Color.app.grey
    var useButton = true

    func makeBody(configuration: Self.Configuration) -> some View {
        HStack() {
            if !label.isEmpty {
                Text(label)
                    .modifier(BoldTextStyle(
                        size: Font.size.thinExtra,
                        color: Color.app.greyLight
                    ))
                    .fixedSize()
                    .onTapGesture {
                        configuration.isOn.toggle()
                    }
            }
            if useButton {
                Button(action: { configuration.isOn.toggle() } )
                {
                    RoundedRectangle(cornerRadius: Dimen.radius.regular, style: .circular)
                        .fill(configuration.isOn ? Color.transparent.black15 : Color.transparent.clearUi)
                        .frame(width: 40, height: 22)
                        .overlay(
                            ZStack(alignment:.leading){
                                RoundedRectangle(cornerRadius: Dimen.radius.regular)
                                    .stroke(configuration.isOn ? onColor : offColor, lineWidth: 1)
                                Circle()
                                    .fill(configuration.isOn ? onColor : offColor)
                                    .shadow(radius: 1, x: 0, y: 1)
                                    .padding(2)
                                    .offset(x: configuration.isOn ? 10 : -10)
                            }
                        )
                        .animation(Animation.easeInOut(duration: 0.1))
                   
                }
            }
        }
        .font(.title)
        .padding(.horizontal)
    }
}


