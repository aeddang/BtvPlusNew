//
//  CheckBox.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/20.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI



struct CheckBox: View, SelecterbleProtocol {
    enum CheckBoxStyle {
        case small, normal, white
        var check:String{
            get{
                switch self {
                case .white: return Asset.shape.checkBoxOffWhite
                default : return Asset.shape.checkBoxOff
                }
            }
        }
        var checkOn:String{
            get{
                switch self {
                case .white: return Asset.shape.checkBoxOn
                case .small: return Asset.shape.checkBoxOn
                default : return Asset.shape.checkBoxOn2
                }
            }
        }
        var textColor:Color {
            get{
                switch self {
                case .white: return Color.app.grey
                default : return Color.app.white
                }
            }
        }
        var textSize:CGFloat {
            get{
                switch self {
                case .white: return  Font.size.thinExtra
                case .small: return  Font.size.tiny
                default : return  Font.size.lightExtra
                }
            }
        }
    }
    
    var style:CheckBoxStyle = .normal
    var isChecked: Bool
    var text:String? = nil
    var subText:String? = nil
    var isStrong:Bool = false
    var isSimple:Bool = false
    var isFill:Bool = true
    var textColor:String? = nil
    var textSize:String? = nil
   
    var more: (() -> Void)? = nil
    var action: ((_ check:Bool) -> Void)? = nil
    
    
    var body: some View {
        HStack(alignment: .top, spacing: Dimen.margin.thin){
           ImageButton(
            defaultImage: self.style.check,
            activeImage: self.isStrong
                ? Asset.shape.checkBoxOn :self.style.checkOn,
                isSelected: self.isChecked,
                size: CGSize(width: Dimen.icon.thinExtra, height: Dimen.icon.thinExtra)
                ){_ in
                    if self.action != nil {
                        self.action!(!self.isChecked)
                    }
            }
            if !self.isSimple {
                VStack(alignment: .leading, spacing: Dimen.margin.tiny){
                    if self.text != nil {
                        if self.isStrong {
                            Text(self.text!)
                                .modifier( BoldTextStyle(
                                            size: self.style.textSize,
                                            color: self.style.textColor)
                                )
                        }else{
                            Text(self.text!)
                                .modifier( MediumTextStyle(
                                        size: self.style.textSize,
                                        color: self.style.textColor)
                                )
                        }

                    }
                    if self.subText != nil {
                        Text(self.subText!)
                            .modifier(MediumTextStyle(
                                size: self.style.textSize,
                                color: Color.app.greyLight))
                    }
                }.offset(y:3)
                if isFill {
                    Spacer()
                }
                if more != nil {
                    TextButton(
                        defaultText: String.button.view,
                        textModifier:TextModifier(
                            family:Font.family.medium,
                            size:Font.size.thinExtra,
                            color: self.style.textColor),
                        isUnderLine: true)
                    {_ in
                        self.more!()
                    }
                }
            }
        }
    }
}

#if DEBUG
struct CheckBox_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            CheckBox(
                isChecked: true,
                text:"asdafafsd",
                more:{
                    
                },
                action:{ ck in
                
                }
            )
            .frame( alignment: .center)
            .background(Color.brand.bg)
        }
        
    }
}
#endif

