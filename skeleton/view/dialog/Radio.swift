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
    func radio(isShowing: Binding<Bool>,
               buttons:[String],
               action: @escaping (_ idx:Int) -> Void) -> some View {
        
        let range = 0 ..< buttons.count
        return Radio(
            isShowing: isShowing,
            buttons:.constant(
                zip(range,buttons).map {index, text in
                    RadioBtnData(title: text, index: index)
            }),
            presenting: { self },
            action:action)
    }
    func radio(isShowing: Binding<Bool>,
               buttons:Binding<[RadioBtnData]>,
               action: @escaping (_ idx:Int) -> Void) -> some View {
        
       return Radio(
            isShowing: isShowing,
            buttons:buttons,
            presenting: { self },
            action:action)
    }
}
struct RadioBtnData:Identifiable, Equatable{
    let id = UUID.init()
    let title:String
    let index:Int
}

struct Radio<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    @Binding var buttons: [RadioBtnData]
    
    @State var selected = 0
    let presenting: () -> Presenting
    
    var action: ((_ idx:Int ) -> Void)? = nil
    let completed:((_ idx:Int ) -> Void)? = nil
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Button(action: {
                withAnimation{
                    self.isShowing = false
                }
                guard let completed = self.completed else { return }
                completed(self.selected)
            }) {
               Spacer().modifier(MatchParent())
                   .background(Color.transparent.black70)
            }
            if self.buttons.count < 10 {
                VStack (alignment: .leading, spacing:Dimen.margin.medium){
                    ForEach(self.buttons) { btn in
                        RadioButton(
                            isChecked: self.selected == btn.index,
                            text: btn.title
                        ){idx in
                             self.selected = btn.index
                             guard let action = self.action else { return }
                             action(self.selected)
                        }
                    }
                }
                //.modifier(BottomFunctionTab())
                .offset(y: self.isShowing ? 0 : 300)
            }else {
                if #available(iOS 14.0, *) {
                    ScrollView(.vertical , showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: 0){
                            ForEach(self.buttons) { btn in
                                RadioButton(
                                    isChecked: self.selected == btn.index,
                                    text: btn.title
                                ){idx in
                                     self.selected = btn.index
                                     guard let action = self.action else { return }
                                     action(self.selected)
                                }
                                .padding(.vertical , Dimen.margin.light)
                                
                            }
                        }
                    }
                    //.modifier(BottomFunctionTab())
                    .frame(height:300)
                    .offset(y: self.isShowing ? 0 : 300)
                }else{
                    List {
                        ForEach(self.buttons) { btn in
                            RadioButton(
                                isChecked: self.selected == btn.index,
                                text: btn.title
                            ){idx in
                                 self.selected = btn.index
                                 guard let action = self.action else { return }
                                 action(self.selected)
                            }
                        }
                    }
                    //.modifier(BottomFunctionTab())
                    .frame(height:300)
                    .offset(y: self.isShowing ? 0 : 300)
                }
                
            }
        }
        .opacity(self.isShowing ? 1 : 0)
    }
}
#if DEBUG
struct Radio_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            Spacer()
        }
        .radio(
            isShowing: .constant(true),
            buttons: [
                "test","test1"
            ]
        ){ idx in
        
        }

    }
}
#endif

