//
//  ImageViewButton.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/14.
//

import Foundation
import SwiftUI
struct ImageViewButton: View{
    @Binding var isSelected: Bool
    var defaultImage:String? = Asset.noImg1_1
    var activeImage:String? = Asset.noImg1_1
    var size:CGSize = CGSize(width: Dimen.icon.light, height: Dimen.icon.light)
    var text:String? = nil
    var textSize:CGFloat = Font.size.tinyExtra
    var defaultTextColor:Color = Color.app.whiteDeep
    var activeTextColor:Color = Color.app.white
    
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            VStack(spacing:Dimen.margin.tiny){
                if !self.isSelected {
                    ImageView(url: self.activeImage)
                        .frame(width: size.width, height: size.height)
                }else{
                    ImageView(url: self.defaultImage)
                        .frame(width: size.width, height: size.height)
                }
                
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
struct ImageViewButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            ImageViewButton(isSelected: .constant(true)){
                
            }
            .frame( alignment: .center)
        }
    }
}
#endif
