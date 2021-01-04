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
    func select(isShowing: Binding<Bool>,
               title: String,
               buttons:[String],
               action: @escaping (_ idx:Int) -> Void) -> some View {
        let range = 0 ..< buttons.count
        return Select(
            isShowing: isShowing,
            presenting: { self },
            title:Binding.constant(title),
            buttons:.constant(
                zip(range,buttons).map {index, text in
                    SelectBtnData(title: text, index: index)
            }),
            action:action)
    }
    func select(isShowing: Binding<Bool>,
               title: Binding<String?>,
               buttons:Binding<[SelectBtnData]>,
               action: @escaping (_ idx:Int) -> Void) -> some View {
        
       return Select(
            isShowing: isShowing,
            presenting: { self },
            title:title,
            buttons:buttons,
            action:action)
    }
}
struct SelectBtnData:Identifiable, Equatable{
    let id = UUID.init()
    let title:String
    let index:Int
}

struct Select<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    let presenting: () -> Presenting
    @Binding var title: String?
    @Binding var buttons: [SelectBtnData]
    let action: (_ idx:Int) -> Void
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack{
                Spacer()
                VStack (alignment: .leading, spacing:Dimen.margin.medium){
                    HStack{
                        if self.title != nil{
                            Text(self.title!)
                                .modifier(BoldTextStyle(size: Font.size.medium))
                        }
                        Spacer()
                        ImageButton(defaultImage: Asset.icon.close){_ in
                            withAnimation{
                                self.isShowing = false
                            }
                        }
                    }
                    .padding(.horizontal, Dimen.margin.heavy)
                    Divider()
                    VStack(alignment: .leading, spacing:Dimen.margin.medium){
                        ForEach(self.buttons) { btn in
                            TextButton(
                                defaultText: btn.title,
                                index: btn.index
                            ){idx in
                                self.action(idx)
                                withAnimation{
                                    self.isShowing = false
                                }
                                
                            }
                        }
                        FillButton(
                            text: String.app.cancel,
                            isSelected:.constant( false )
                        ){idx in
                            withAnimation{
                                self.isShowing = false
                            }
                            
                        }
                    }.padding(.horizontal, Dimen.margin.heavy)
                }
                .padding(.vertical, Dimen.margin.heavy)
                .background(Color.app.white)
                .cornerRadius(Dimen.radius.light)
                .transition(.slide)
                Spacer()
            }
            .padding(.all, Dimen.margin.heavy)
            .background(Color.transparent.black70)
            .opacity(self.isShowing ? 1 : 0)
        }
        
    }
}
#if DEBUG
struct Select_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            Spacer()
        }
        .select(
            isShowing: .constant(true),
            title:"TEST",
            buttons: [
                "test","test1"
            ]
        ){ idx in
        
        }

    }
}
#endif
