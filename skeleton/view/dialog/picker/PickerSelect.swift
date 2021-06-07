//
//  Picker.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/31.
//

import Foundation
import SwiftUI
extension View {
    func picker(isShowing: Binding<Bool>,
               title: String?,
               buttons:[SelectBtnData],
               selected: Binding<Int>,
               action: @escaping (_ idx:Int) -> Void) -> some View {
        
       return PickerSelect(
            isShowing: isShowing,
            presenting: { self },
            title:title,
            selected: selected,
            buttons:buttons,
            action:action)
    }
}
struct PickerSelect<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    let presenting: () -> Presenting
    var title: String?
    @Binding var selected:Int
    var buttons: [SelectBtnData]
    let action: (_ idx:Int) -> Void
    var body: some View {
        ZStack(alignment: .bottom) {
            Button(action: {
                withAnimation{
                    self.isShowing = false
                }
                self.action(self.selected)
            
            }) {
               Spacer().modifier(MatchParent())
                   .background(Color.transparent.black70)
            }
            Picker(selection: self.$selected.onChange(self.onSelected),label: Text(self.title ?? "")) {
                ForEach(self.buttons) { btn in
                    Text(btn.title).modifier(MediumTextStyle(
                        size: Font.size.light)
                    ).tag(btn.index)
                }
            }
            .background(Color.app.blue)
        }
        .opacity(self.isShowing ? 1 : 0)
    }
    
    func onSelected(_ tag: Int) {
        self.action(tag)
        withAnimation{
            self.isShowing = false
        }
    }
}

#if DEBUG
struct PickerSelect_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            Spacer()
        }
        .picker(
            isShowing: .constant(true),
            title:"TEST",
            buttons: [
                SelectBtnData(title:"test" , index:0) ,
                SelectBtnData(title:"test1" , index:1)
            ], selected: .constant(0)
        ){ idx in
        
        }

    }
}
#endif
