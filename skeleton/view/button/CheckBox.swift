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
    @Binding var isChecked: Bool
    var text:String? = nil
    var subText:String? = nil
    var more: (() -> Void)? = nil
    var action: ((_ check:Bool) -> Void)? = nil
    
    
    var body: some View {
        HStack(alignment: .top, spacing: Dimen.margin.thinExtra){
           ImageButton(
                defaultImage: Asset.shape.checkBoxOff,
                activeImage: Asset.shape.checkBoxOn,
                isSelected: self.$isChecked
                ){_ in
                    self.isChecked.toggle()
                    if self.action != nil {
                        self.action!(self.isChecked)
                    }
            }
            VStack(alignment: .leading, spacing: Dimen.margin.thinExtra){
                if self.text != nil {
                    Text(self.text!)
                        .modifier(MediumTextStyle(
                            size: Font.size.light,
                            color: Color.app.greyDeep))
                }
                if self.subText != nil {
                    Text(self.subText!)
                        .modifier(MediumTextStyle(
                            size: Font.size.light,
                            color: Color.app.greyLight))
                }
            }.offset(y:3)
            Spacer()
            if more != nil {
                ImageButton(
                    defaultImage: Asset.icon.more,
                    size: CGSize(width:Dimen.icon.light,height:Dimen.icon.light)
                    ){_ in
                       self.more!()
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
                isChecked: .constant(true),
                text:"asdafafsd",
                more:{
                    
                },
                action:{ ck in
                
                }
            )
            .frame( alignment: .center)
        }
    }
}
#endif

