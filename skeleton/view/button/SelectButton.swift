//
//  FillButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/11.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct SelectButton: View, SelecterbleProtocol{
    let text:String
    var tipA:String? = nil
    var tipB:String? = nil
    var index: Int = 0
    var isSelected: Bool
    var textModifier:TextModifier = TextModifier(
        family: Font.family.bold,
        size: Font.size.regular,
        color: Color.app.white,
        activeColor: Color.app.white
    )
    var size:CGFloat = Dimen.button.medium
    let action: (_ idx:Int) -> Void

    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            ZStack{
                HStack(spacing:0){
                    Text(self.text)
                        .font(.custom(textModifier.family, size: textModifier.size))
                        .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                    Spacer().modifier(MatchParent())
                    if self.tipA != nil {
                        Text(self.tipA!)
                            .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.white))
                            .padding(.horizontal, Dimen.margin.thin)
                            .frame(height:Dimen.button.thin)
                            .background(Color.brand.primary)
                            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.regularExtra))
                    }
                    if self.tipB != nil {
                        Text(self.tipB!)
                            .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.brand.primary))
                            .padding(.horizontal, Dimen.margin.thin)
                            .frame(height:Dimen.button.thin)
                            .overlay(
                                RoundedRectangle(cornerRadius: Dimen.radius.regularExtra)
                                    .stroke(Color.brand.primary, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, Dimen.margin.mediumExtra)
            }
            .modifier( MatchHorizontal(height: self.size) )
            .background(self.isSelected ? Color.app.blueLight : Color.app.blue )
        }
        
        
    }
}
#if DEBUG
struct SelectButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            SelectButton(
                text: "test",
                tipA: "A",
                tipB: "B",
                index: 0,
                isSelected: false
            ){_ in
                
            }
            .frame( alignment: .center)
        }
    }
}
#endif

