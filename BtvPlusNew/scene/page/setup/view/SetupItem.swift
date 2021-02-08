
//
//  Banner.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI



struct SetupItem: PageView {
    @Binding var isOn:Bool
    var title:String? = nil
    var subTitle:String? = nil
    var tips:[String]? = nil
    var radios:[String]? = nil
    var selectedRadio:String? = nil
    var selected: ((String) -> Void)? = nil
    
    var statusText:String? = nil
    var more: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: Dimen.margin.thinExtra) {
            HStack(spacing:0){
                VStack(alignment: .leading, spacing: Dimen.margin.tinyExtra) {
                    if self.title != nil {
                        Text(self.title!)
                        .modifier(MediumTextStyle(
                            size: Font.size.lightExtra,
                            color: Color.app.white
                        ))
                    }
                    if self.subTitle != nil {
                        Text(self.subTitle!)
                        .modifier(MediumTextStyle(
                            size: Font.size.thinExtra,
                            color: Color.app.greyLight
                        ))
                    }
                }
                Spacer()
                if self.statusText != nil {
                    Text(self.statusText!)
                    .modifier(MediumTextStyle(
                        size: Font.size.thinExtra,
                        color: Color.app.greyLight
                    ))
                } else if self.more == nil {
                    Toggle("", isOn: self.$isOn)
                       .toggleStyle( ColoredToggleStyle() )
                       .frame(width: 52)
                } else{
                    Button(action: {
                        self.more?()
                    }) {
                        Image(Asset.icon.more)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                    }
                }
            }
            if self.tips != nil {
                VStack(alignment: .leading, spacing: Dimen.margin.tinyExtra){
                    ForEach(self.tips!, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 0){
                            Text("・ ")
                            .modifier(MediumTextStyle(
                                size: Font.size.thinExtra,
                                color: Color.app.greyLight
                            ))
                            Text(tip)
                            .modifier(MediumTextStyle(
                                size: Font.size.thinExtra,
                                color: Color.app.greyLight
                            ))
                        }
                    }
                }
            }
            if self.radios != nil {
                Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                HStack(spacing:Dimen.margin.regular){
                    ForEach(self.radios!, id: \.self) { radio in
                        RadioButton(
                            isChecked: self.selectedRadio == radio,
                            text: radio
                        ){ isSelected in
                           if let selected = self.selected {
                              selected( radio )
                           }
                        }
                    }
                }
                
            }
        }
        .padding(.horizontal, Dimen.margin.lightExtra)
        .padding(.vertical, Dimen.margin.regular)
        
        
    }//body
}

#if DEBUG
struct SwitchBox_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            SetupItem (
                isOn: .constant(true),
                title: "test", subTitle: "test",
                tips: [
                    "tip",
                    "tip",
                    "tip"
                ],
                radios: [
                    "radio",
                    "radio",
                    "radio"
                ]
                
            )
        }
    }
}
#endif

