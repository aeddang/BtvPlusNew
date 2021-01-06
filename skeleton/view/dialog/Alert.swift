//
//  Toast.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI


extension View {
    func alert(isShowing: Binding<Bool>,
               title: String? = nil,
               image: UIImage? = nil,
               text: String,
               subText: String? = nil,
               buttons:[String]? = nil,
               action: @escaping (_ idx:Int) -> Void ) -> some View {
        
        let btns = buttons ?? [
            String.app.cancel,
            String.app.corfirm
        ]
        
        let range = 0 ..< btns.count
        return Alert(
            isShowing: isShowing,
            presenting: { self },
            title:Binding.constant(title),
            image:Binding.constant(image),
            text: Binding.constant(text),
            subText: Binding.constant(subText),
            buttons:.constant(
                zip(range,btns).map {index, text in
                    AlertBtnData(title: text, index: index)
            }),
            action:action)
    }
    func alert(isShowing: Binding<Bool>,
               title: Binding<String?>,
               image: Binding<UIImage?>,
               text: Binding<String>,
               subText: Binding<String?>,
               buttons:Binding<[AlertBtnData]>,
               action: @escaping (_ idx:Int) -> Void ) -> some View {
        
       return Alert(
            isShowing: isShowing,
            presenting: { self },
            title:title,
            image:image,
            text:text,
            subText:subText,
            buttons:buttons,
            action:action)
    }
}
struct AlertBtnData:Identifiable, Equatable{
    let id = UUID.init()
    let title:String
    let index:Int
}


struct Alert<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    let presenting: () -> Presenting
    @Binding var title: String?
    @Binding var image: UIImage?
    @Binding var text: String
    @Binding var subText: String?
    @Binding var buttons: [AlertBtnData]
    let action: (_ idx:Int) -> Void
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack{
                VStack (alignment: .center, spacing:0){
                    VStack (alignment: .center, spacing:0){
                        if self.title != nil{
                            Text(self.title!)
                                .modifier(BoldTextStyle(size: Font.size.regular))
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, Dimen.margin.medium)
                        }
                        if self.image != nil{
                            Image(uiImage: self.image!)
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
                                .padding(.bottom, Dimen.margin.light)
                                
                        }
                        Text(self.text)
                            .modifier(MediumTextStyle(size: Font.size.lightExtra))
                            .fixedSize(horizontal: false, vertical: true)
                        if self.subText != nil{
                            Text(self.subText!)
                                .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.greyDeep))
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, Dimen.margin.tiny)
                        }
                    }
                    .padding(.top, Dimen.margin.regular)
                    .padding(.bottom, Dimen.margin.medium)
                    .padding(.horizontal, Dimen.margin.regular)
                    HStack(spacing:0){
                        ForEach(self.buttons) { btn in
                            FillButton(
                                text: btn.title,
                                index: btn.index,
                                isSelected:.constant( true ),
                                textModifier: TextModifier(
                                    family: Font.family.bold,
                                    size: Font.size.lightExtra,
                                    color: Color.app.white,
                                    activeColor: Color.app.white
                                ),
                                size: Dimen.button.regular,
                                bgColor: (btn.index % 2 == 1) ? Color.brand.primary  : Color.brand.secondary
                            ){idx in
                                self.action(idx)
                                withAnimation{
                                    self.isShowing = false
                                }
                                
                            }
                        }
                    }
                }
                .background(Color.app.blue)
                
            }
            .padding(.all, Dimen.margin.heavy)
            
        }
        .modifier(MatchParent())
        .background(Color.transparent.black70)
        .opacity(self.isShowing ? 1 : 0)
        
    }
}
#if DEBUG
struct Alert_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            Spacer()
        }
        .alert(
            isShowing: .constant(true),
            title:"TEST",
            text: "text",
            subText: "subtext",
            buttons: [
                "test","test1"
            ]
        ){ _ in
        
        }

    }
}
#endif
