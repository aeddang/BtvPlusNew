//
//  ImageButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/06.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

struct EffectButton: View, SelecterbleProtocol{
    @EnvironmentObject var setup:Setup
    var isSelected: Bool
    let index: Int
    let defaultImage:String
    let effectImage:String
    let activeImage:String
    let useVibrate:Bool
    let action: (_ idx:Int) -> Void
    
    @State var isEffect:Bool = false
    init(
        defaultImage:String,
        effectImage:String,
        activeImage:String? = nil,
        isSelected:Bool? = nil,
        index: Int = 0,
        useVibrate : Bool = true,
        action:@escaping (_ idx:Int) -> Void
    )
    {
        self.defaultImage = defaultImage
        self.activeImage = activeImage ?? effectImage
        self.effectImage = effectImage
        self.index = index
        self.isSelected = isSelected ?? false
        self.useVibrate = useVibrate
        self.action = action
    }
    var body: some View {
        Button(action: {
            withAnimation {self.isEffect = true}
            if self.setup.remoconVibration &&  self.useVibrate{
                UIDevice.vibrate()
            }
            
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + RemoteStyle.effectTime) {
                DispatchQueue.main.async {
                    withAnimation {self.isEffect = false}
                }
            }
            self.action(self.index)
            
        }) {
            ZStack(){
                Image(self.isSelected ?
                        self.activeImage : self.defaultImage)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .modifier(MatchParent())
                    
                if self.isEffect {
                    Image(self.effectImage)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .modifier(MatchParent())
                }
            }
            .modifier(MatchParent())
        }
    }
}

#if DEBUG
struct EffectButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            EffectButton(
                defaultImage:Asset.noImg1_1,
                effectImage:Asset.noImg4_3
            ){_ in
                
            }
            .frame( alignment: .center)
        }
    }
}
#endif
