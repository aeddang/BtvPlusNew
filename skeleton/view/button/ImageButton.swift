//
//  ImageButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/06.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

struct ImageButton: View, SelecterbleProtocol{
    @Binding var isSelected: Bool
    let index: Int
    let defaultImage:String
    let activeImage:String
    let size:CGSize
    let text:String?
    let textSize:CGFloat
    let defaultTextColor:Color
    let activeTextColor:Color
    
    let action: (_ idx:Int) -> Void
    init(
        defaultImage:String,
        activeImage:String? = nil,
        text:String? = nil,
        isSelected:Binding<Bool>? = nil,
        index: Int = 0,
        size:CGSize = CGSize(width: Dimen.icon.light, height: Dimen.icon.light),
        textSize:CGFloat = Font.size.thin,
        defaultTextColor:Color = Color.app.whiteDeep,
        activeTextColor:Color = Color.app.white,
        action:@escaping (_ idx:Int) -> Void
    )
    {
        self.defaultImage = defaultImage
        self.activeImage = activeImage ?? defaultImage
        self.text = text
        self.index = index
        self._isSelected = isSelected ?? Binding.constant(false)
        self.size = size
        self.textSize = textSize
        self.defaultTextColor = defaultTextColor
        self.activeTextColor = activeTextColor
        self.action = action
    }
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            VStack(spacing:Dimen.margin.thinExtra){
                Image(self.isSelected ?
                        self.activeImage : self.defaultImage)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(width: size.width, height: size.height)
                if self.text != nil {
                    Text(self.text!)
                        .modifier(BoldTextStyle(
                            size: self.textSize,
                            color: self.isSelected ?
                                self.activeTextColor : self.defaultTextColor
                        ))
                }
            }
        }
    }
}

#if DEBUG
struct ImageButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            ImageButton(defaultImage:Asset.test ){_ in
                
            }
            .frame( alignment: .center)
        }
    }
}
#endif
