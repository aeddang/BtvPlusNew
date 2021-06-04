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
    let maxTextCount:Int = 200
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
            if SystemEnvironment.currentPageType == .btv {
                AlertBox(
                    isShowing: self.$isShowing,
                    title: self.title,
                    image: self.image,
                    text: self.text,
                    subText: self.subText,
                    tipText: self.tipText,
                    referenceText: self.referenceText,
                    imgButtons: self.imgButtons,
                    buttons: self.buttons,
                    action: self.action)
            } else {
                AlertBoxKids(
                    isShowing: self.$isShowing,
                    title: self.title,
                    image: self.image,
                    text: self.text,
                    subText: self.subText,
                    tipText: self.tipText,
                    referenceText: self.referenceText,
                    imgButtons: self.imgButtons,
                    buttons: self.buttons,
                    action: self.action)
            }
        }
        .modifier(MatchParent())
        .background(SystemEnvironment.currentPageType == .btv
                        ? Color.transparent.black70
                        : Color.transparent.black50 )
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
