
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
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().modifier(MatchHorizontal(height: 0))
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
                        .padding(.top, Dimen.margin.thin)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                if self.statusText != nil {
                    Text(self.statusText!)
                    .modifier(MediumTextStyle(
                        size: Font.size.thinExtra,
                        color: Color.app.greyLight
                    ))
                    .fixedSize(horizontal: true, vertical: false)
                } else if self.more == nil {
                    Toggle("", isOn: self.$isOn)
                       .toggleStyle( ColoredToggleStyle() )
                       .frame(width: 52)
                        .padding(.trailing, Dimen.margin.tinyExtra)
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
                                size: Font.size.tinyExtra,
                                color: Color.app.grey
                            ))
                            Text(tip)
                            .modifier(MediumTextStyle(
                                size: Font.size.tinyExtra,
                                color: Color.app.grey
                            ))
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.trailing, Dimen.margin.thin)
            }
            if self.radios != nil {
                Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                    .padding(.trailing, Dimen.margin.thin)
                HStack(spacing:Dimen.margin.regular){
                    ForEach(self.radios!, id: \.self) { radio in
                        RadioButton(
                            isChecked: self.selectedRadio == radio,
                            size: CGSize(width: Dimen.icon.lightExtra, height: Dimen.icon.lightExtra),
                            text: radio,
                            textSize: Font.size.thinExtra
                        ){ isSelected in
                           if let selected = self.selected {
                              selected( radio )
                           }
                        }
                    }
                }
                .padding(.trailing, Dimen.margin.thin)
                
            }
        }
        .padding(.leading, Dimen.margin.thin)
        .padding(.vertical, Dimen.margin.regular)
        .onTapGesture {
            self.more?()
        }
        
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

