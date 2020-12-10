//
//  RectButton.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct SortButton: View{
    @Binding var text:String
    var textModifier:TextModifier = TextModifier(
        family: Font.family.bold,
        size: Font.size.lightExtra,
        color: Color.app.grey
    )
    var size:CGFloat = Dimen.button.light
    var padding:CGFloat = Dimen.margin.thin
    var cornerRadius = Dimen.radius.regular
    let action: () -> Void
    

    var body: some View {
        Button(action: {
            self.action()
        }) {
            ZStack{
                HStack(spacing:Dimen.margin.thinExtra){
                    Text(self.text)
                    .font(.custom(textModifier.family, size: textModifier.size))
                    .foregroundColor(textModifier.color)
                   
                    Image(Asset.icon.sort)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
                }
                .padding(.horizontal, self.padding)
            }
            .frame(height:self.size)
            .background(Color.app.white)
            .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: self.cornerRadius)
                    .stroke(Color.app.greyLightExtra,lineWidth: 1)
            )
        }
    }
}
#if DEBUG
struct SortButtonButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            SortButton(
                text: .constant("test"))
            {
                
            }
            .frame( alignment: .center)
        }
    }
}
#endif
