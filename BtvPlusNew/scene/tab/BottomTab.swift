//
//  BottomTab.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/06.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
struct PageSelecterble : SelecterbleProtocol{
    let key = UUID().uuidString
    var id:PageID = ""
    var on:String = ""
    var off:String = ""
    var text:String = ""
    
}

struct BottomTab: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @State var selectedPage:PageObject? = nil
    @State var pages:[PageSelecterble] = [
        PageSelecterble(id: .home, on: Asset.gnbBottom.homeOn , off: Asset.gnbBottom.homeOff, text:String.pageTitle.home),
        PageSelecterble(id: .home, on: Asset.gnbBottom.oceanOn , off: Asset.gnbBottom.oceanOff, text:String.pageTitle.ocean),
        PageSelecterble(id: .home, on: Asset.gnbBottom.paymentOn , off: Asset.gnbBottom.paymentOff, text:String.pageTitle.payment),
        PageSelecterble(id: .home, on: Asset.gnbBottom.categoryOn , off: Asset.gnbBottom.categoryOff, text:String.pageTitle.category),
        PageSelecterble(id: .home, on: Asset.gnbBottom.freeOn , off: Asset.gnbBottom.freeOff, text:String.pageTitle.free)
    ]
    
    var body: some View {
        ZStack(alignment: .bottom){
            HStack( spacing:0){
                ForEach(self.pages, id: \.key) {selecter in
                    ImageButton(
                        defaultImage: selecter.off,
                        activeImage:selecter.on,
                        text: selecter.text,
                        isSelected: Binding<Bool>(get: { self.checkCategory(pageID: selecter.id) }, set: { _ in }) )
                    {_ in
                        self.pagePresenter.changePage(PageProvider.getPageObject(selecter.id))
                    }.frame(width:SceneObserver.screenSize.width/CGFloat(self.pages.count))
                }
            }
        }
        .offset(y: PageSceneObserver.safeAreaBottom )
        .onReceive (self.pagePresenter.$currentPage) { page in
            self.selectedPage = page
        }
        .onAppear(){
        
        }
        
    }
    
    func checkCategory(pageID:PageID) -> Bool {
        guard let page = self.selectedPage else { return false }
        let idx = floor( Double(PageProvider.getPageIdx(pageID)) / 100.0 )
        let cidx = floor( Double(page.pageIDX) / 100.0 )
        return idx == cidx
    }
    
}


#if DEBUG
struct ComponentBottomTab_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            BottomTab().environmentObject(PagePresenter()).frame(width:370,height:200)
        }
    }
}
#endif
