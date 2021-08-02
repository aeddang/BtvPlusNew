//
//  ImageButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/06.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

struct BlankButton: View, SelecterbleProtocol{
    @EnvironmentObject var setup:Setup
    let action: (_ idx:Int) -> Void
    let effectCompleted: (_ idx:Int) -> Void
    var body: some View {
        Button(action: {
            self.action(self.index)
            if self.setup.remoconVibration {
                UIDevice.vibrate()
            }
            
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + RemoteStyle.effectTime) {
                DispatchQueue.main.async {
                    self.effectCompleted(self.index)
                }
            }
            
        }) {
            Spacer()
                .modifier(MatchParent())
                .background(Color.transparent.clearUi)
        }
    }
}

