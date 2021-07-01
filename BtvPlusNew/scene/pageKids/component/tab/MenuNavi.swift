//
//  ComponentTabNavigation.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine




struct MenuNavi : PageComponent {
    @ObservedObject var viewModel:NavigationModel = NavigationModel()
    let buttons:[String]
    var selectedIdx:Int = 0
    var height:CGFloat = DimenKids.tab.lightExtra
   
    var isDivision:Bool = true
    @State var menus:[MenuBtn] = []
   
    var body: some View {
        HStack(spacing:DimenKids.margin.thinExtra){
            ForEach(self.menus) { menu in
                Button(
                    action: { self.performAction(menu)}
                ){
                    if self.isDivision {
                        self.createButton(menu)
                            .modifier(MatchParent())
                    } else {
                        self.createButton(menu)
                            .frame(height: self.height)
                    }
                }
                .background( menu.idx == self.selectedIdx
                                ? Color.kids.primaryLight
                                : Color.app.white)
                .clipShape( RoundedRectangle(cornerRadius: DimenKids.radius.medium))
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .frame(height: self.height)
        .onAppear(){
            self.menus = zip(0..<self.buttons.count, self.buttons).map{ idx, btn in
                MenuBtn(idx: idx, text: btn)
            }
        }
        
    }//body
    
    func createButton(_ menu:MenuBtn) -> some View {
        return Text(menu.text)
            .modifier(BoldTextStyle(
                        size: Font.sizeKids.lightExtra,
                color: menu.idx == self.selectedIdx ? Color.app.white : Color.app.brownDeep
            ))
            .padding(.horizontal, DimenKids.margin.thin)
            .fixedSize(horizontal: true, vertical: false)
    }
    
    
    func performAction(_ menu:MenuBtn){
        self.viewModel.selected = menu.text
        self.viewModel.index = menu.idx
        
    }
    
    struct MenuBtn : SelecterbleProtocol, Identifiable {
        let id = UUID().uuidString
        var idx:Int = 0
        var text:String = ""
    }
    
}


#if DEBUG
struct MenuNavi_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            MenuNavi(
                viewModel:NavigationModel(),
                buttons: [
                    "TEST0", "TEST11", "TEST222","TEST333" ,"TEST444"
                ]
            )
            .frame( alignment: .center)
        }
        .background(Color.app.ivory)
    }
}
#endif
