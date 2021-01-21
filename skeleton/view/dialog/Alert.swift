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
               text: String? = nil,
               subText: String? = nil,
               tipText: String? = nil,
               referenceText: String? = nil,
               imgButtons:[AlertBtnData]? = nil,
               buttons:[AlertBtnData]? = nil,
               action: @escaping (_ idx:Int) -> Void ) -> some View {
        
        var alertBtns:[AlertBtnData] = buttons ?? []
        if buttons == nil {
            let btns = [
                String.app.cancel,
                String.app.corfirm
            ]
            let range = 0 ..< btns.count
            alertBtns = zip(range,btns).map {index, text in AlertBtnData(title: text, index: index)}
        }
        
        return Alert(
            isShowing: isShowing,
            presenting: { self },
            title:title,
            image:image,
            text:text,
            subText:subText,
            tipText:tipText,
            referenceText: referenceText,
            imgButtons : imgButtons,
            buttons: alertBtns,
            action:action)
    }
    
}
struct AlertBtnData:Identifiable, Equatable{
    let id = UUID.init()
    let title:String
    var img:String = ""
    let index:Int
}


struct Alert<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    let presenting: () -> Presenting
    var title: String?
    var image: UIImage?
    var text: String?
    var subText: String?
    var tipText: String?
    var referenceText: String?
    var imgButtons: [AlertBtnData]?
    var buttons: [AlertBtnData]
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
                                
                        }
                        if self.image != nil{
                            Image(uiImage: self.image!)
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
                                .padding(.top, Dimen.margin.medium)
                                
                        }
                        if self.text != nil{
                            Text(self.text!)
                                .multilineTextAlignment(.center)
                                .modifier(MediumTextStyle(size: Font.size.lightExtra))
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, Dimen.margin.medium)
                        }
                        if self.subText != nil{
                            Text(self.subText!)
                                .multilineTextAlignment(.center)
                                .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.greyDeep))
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, Dimen.margin.tiny)
                        }
                        if self.tipText != nil{
                            Text(self.tipText!)
                                .multilineTextAlignment(.center)
                                .modifier(MediumTextStyle(size: Font.size.tiny, color: Color.brand.primary))
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, Dimen.margin.regular)
                        }
                        if self.referenceText != nil{
                            Text(self.referenceText!)
                                .multilineTextAlignment(.center)
                                .modifier(MediumTextStyle(size: Font.size.tiny, color: Color.app.greyLight))
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, Dimen.margin.tiny)
                        }
                    }
                    .padding(.top, Dimen.margin.regular)
                    .padding(.bottom, Dimen.margin.medium)
                    .padding(.horizontal, Dimen.margin.regular)
                    if self.imgButtons != nil {
                        HStack(spacing:Dimen.margin.regular){
                            ForEach(self.imgButtons!) { btn in
                                ImageButton(
                                    defaultImage: btn.img,
                                    text: btn.title,
                                    isSelected: true ,
                                    index: btn.index,
                                    size: CGSize(width: Dimen.icon.heavyExtra, height: Dimen.icon.heavyExtra)
                                    
                                ){idx in
                                    self.action(idx)
                                    withAnimation{
                                        self.isShowing = false
                                    }
                                }
                            }
                        }
                        .padding(.bottom, Dimen.margin.medium)
                    }
                    HStack(spacing:0){
                        ForEach(self.buttons) { btn in
                            FillButton(
                                text: btn.title,
                                index: btn.index,
                                isSelected: true ,
                                textModifier: TextModifier(
                                    family: Font.family.bold,
                                    size: Font.size.lightExtra,
                                    color: Color.app.white,
                                    activeColor: Color.app.white
                                ),
                                size: Dimen.button.regular,
                                bgColor: self.buttons.count == 1
                                    ? Color.brand.primary
                                    :(btn.index % 2 == 1) ? Color.brand.primary  : Color.brand.secondary
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
            buttons: nil
        ){ _ in
        
        }

    }
}
#endif
