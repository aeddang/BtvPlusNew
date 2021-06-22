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
    var isSelected: Bool
    let index: Int
    let defaultImage:String
    let activeImage:String
    let size:CGSize
    let padding:CGFloat
    let text:String?
    let textSize:CGFloat
    let defaultTextColor:Color
    let activeTextColor:Color
    
    let action: (_ idx:Int) -> Void
    init(
        defaultImage:String,
        activeImage:String? = nil,
        text:String? = nil,
        isSelected:Bool? = nil,
        index: Int = 0,
        size:CGSize = CGSize(width: Dimen.icon.light, height: Dimen.icon.light),
        textSize:CGFloat = Font.size.thin,
        padding:CGFloat = 0,
        defaultTextColor:Color = Color.app.whiteDeep,
        activeTextColor:Color = Color.app.white,
        action:@escaping (_ idx:Int) -> Void
    )
    {
        self.defaultImage = defaultImage
        self.activeImage = activeImage ?? defaultImage
        self.text = text
        self.index = index
        self.isSelected = isSelected ?? false
        self.size = size
        self.textSize = textSize
        self.padding = padding
        self.defaultTextColor = defaultTextColor
        self.activeTextColor = activeTextColor
        self.action = action
    }
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            VStack(spacing:Dimen.margin.thin){
                Image(self.isSelected ?
                        self.activeImage : self.defaultImage)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .padding(.all, floor(self.padding/2))
                    .frame(width: size.width + self.padding, height: size.height + self.padding)
                if self.text != nil {
                    Text(self.text!)
                        .modifier(BoldTextStyle(
                            size: self.textSize,
                            color: self.isSelected ?
                                self.activeTextColor : self.defaultTextColor
                        ))
                }
            }
            .background(Color.transparent.clearUi)
        }
    }
}

#if DEBUG
struct ImageButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            ImageButton(defaultImage:Asset.noImg1_1 ){_ in
                
            }
            .frame( alignment: .center)
        }
    }
}
#endif
