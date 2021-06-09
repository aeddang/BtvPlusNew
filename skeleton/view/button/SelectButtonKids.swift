//
//  FillButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/11.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct SelectButtonKids: View, SelecterbleProtocol{
    let text:String
    var tipA:String? = nil
    var tipB:String? = nil
    var index: Int = 0
    var isSelected: Bool
    var textModifier:TextModifierKids = TextModifierKids(
        family: Font.familyKids.bold,
        size: Font.sizeKids.lightExtra,
        color: Color.app.brownLight,
        activeColor: Color.kids.primary
    )
    var size:CGFloat = DimenKids.button.regular
    var radius:CGFloat = SystemEnvironment.isTablet
        ? DimenKids.radius.lightExtra
        : DimenKids.radius.medium
    
    let action: (_ idx:Int) -> Void

    var body: some View {
        Button(action: {
            self.action(self.index)
        }){
            ZStack{
                Text(self.text)
                    .font(.custom(textModifier.family, size: textModifier.size))
                    .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
            }
            .modifier( MatchHorizontal(height: self.size) )
            .background(Color.transparent.clearUi)
            .clipShape(RoundedRectangle(cornerRadius: self.radius))
            .overlay(
                RoundedRectangle(cornerRadius: self.radius)
                    .stroke(
                        self.isSelected ? Color.kids.primary
                        :  Color.transparent.clearUi,
                        lineWidth: DimenKids.stroke.mediumExtra)
                
            )
        }
    }
}
#if DEBUG
struct SelectButtonKids_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            SelectButtonKids(
                text: "test",
                tipA: "A",
                tipB: "B",
                index: 0,
                isSelected: true
            ){_ in
                
            }
            .frame( alignment: .center)
        }
    }
}
#endif

