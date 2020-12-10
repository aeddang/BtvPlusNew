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
               checks: [String]? = nil,
               buttons:[String]? = nil,
               action: @escaping (_ idx:Int, _ userChecks:[Bool]) -> Void) -> some View {
        
        let btns = buttons ?? [
            String.cancel,
            String.corfirm
        ]
        let chks:[String] = checks ?? []
       
        let range = 0 ..< btns.count
        return Alert(
            isShowing: isShowing,
            presenting: { self },
            title:Binding.constant(title),
            image:Binding.constant(image),
            text: Binding.constant(text),
            subText: Binding.constant(subText),
            checks:.constant(
                chks.map{text in
                    CheckBoxData(text: text)
            }),
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
               checks: Binding<[CheckBoxData]>,
               buttons:Binding<[AlertBtnData]>,
               action: @escaping (_ idx:Int, _ userChecks:[Bool]) -> Void) -> some View {
        
       return Alert(
            isShowing: isShowing,
            presenting: { self },
            title:title,
            image:image,
            text:text,
            subText:subText,
            checks:checks ,
            buttons:buttons,
            action:action)
    }
}
struct AlertBtnData:Identifiable, Equatable{
    let id = UUID.init()
    let title:String
    let index:Int
}

class CheckBoxData:Identifiable{
    let id = UUID.init()
    var text:String? = nil
    var isCheck:Bool = false
    init(text:String? = nil){
        self.text = text
    }
}

struct Alert<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    let presenting: () -> Presenting
    @Binding var title: String?
    @Binding var image: UIImage?
    @Binding var text: String
    @Binding var subText: String?
    @Binding var checks: [CheckBoxData]
    @Binding var buttons: [AlertBtnData]
    let action: (_ idx:Int, _ userChecks:[Bool]) -> Void
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack{
                VStack (alignment: .leading, spacing:Dimen.margin.light){
                    if self.title != nil{
                        Text(self.title!)
                            .modifier(BoldTextStyle(size: Font.size.medium))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if self.image != nil{
                        Image(uiImage: self.image!)
                           .renderingMode(.original)
                           .resizable()
                           .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
                            
                    }
                    Text(self.text)
                        .modifier(BoldTextStyle(size: Font.size.light, color: Color.app.greyDeep))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    if self.subText != nil{
                        Text(self.subText!)
                            .modifier(MediumTextStyle(size: Font.size.light, color: Color.app.grey))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if !self.checks.isEmpty {
                        Spacer().frame(height:Dimen.margin.thinExtra)
                        VStack(alignment: .leading){
                            ForEach(self.checks, id:\.id) { check in
                                CheckBox(
                                    isChecked: .constant(true),
                                    text:check.text, action: { isck in
                                        check.isCheck = isck
                                    })
                            }
                        }
                    }
                    Spacer().frame(height:Dimen.margin.thinExtra)
                    HStack{
                        ForEach(self.buttons) { btn in
                            FillButton(
                                text: btn.title,
                                index: btn.index,
                                isSelected:.constant( btn == self.buttons.last ),
                                size: Dimen.button.medium
                            ){idx in
                                self.action(idx, self.checks.map{c in c.isCheck})
                                withAnimation{
                                    self.isShowing = false
                                }
                                
                            }
                        }
                    }
                }
                .padding(.all, Dimen.margin.heavy)
                .background(Color.app.white)
                .cornerRadius(Dimen.radius.light)
                
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
        ){ _, _ in
        
        }

    }
}
#endif
