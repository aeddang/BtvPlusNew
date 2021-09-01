//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI




struct DropDownButton: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var title:String = ""
    var openTitle:String? = nil
    var selectedIndex:Int = -1
    var count:Int? = nil
    var menus:[String] = []
    let action: (_ idx:Int) -> Void
    
    @State var pickerId:String = ""
    var body: some View {
        HStack(alignment:.center, spacing: Dimen.margin.thin){
            TextButton(
                defaultText:self.title,
                textModifier: TextModifier(
                    family: Font.family.medium,
                    size: Font.size.regular,
                    color: Color.app.white),
                image: Asset.icon.dropDown,
                imageSize: Dimen.icon.tinyExtra){_ in
                
                self.pickerId = UUID().uuidString
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.picker)
                        .addParam(key: .datas, value: self.menus)
                        .addParam(key: .index, value: self.selectedIndex)
                        .addParam(key: .id, value: self.pickerId)
                        .addParam(key: .title, value: self.openTitle)
                )
                /*
                self.appSceneObserver.select =
                    .select((self.tag + SelectType.season.rawValue ,
                             self.data.seasons.map{$0.title ?? ""}),
                    self.data.currentSeasonIdx)*/
                
            }
            .buttonStyle(BorderlessButtonStyle())
            if let count = self.count {
                Text(count.description)
                    .modifier(BoldTextStyle(
                        size: Font.size.lightExtra,
                        color: Color.app.white)
                    )
                    .opacity(0.5)
            }
        }
        .onReceive(self.pagePresenter.$event){ evt in
            guard let evt = evt else {return}
            if evt.id != self.pickerId {return}
            switch evt.type {
            case .selected :
                guard let pic = evt.data as? PickerData else {return}
                self.action(pic.index)
            default : break
            }
        }
        .onAppear{
            
        }
    }//body
}



#if DEBUG
struct DropDownButton_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            DropDownButton(
                title: "dropdown", selectedIndex: 0, count: 20, menus: ["test", "test2"]
            ){ idx in
                
            }
            .environmentObject(PagePresenter())
        }.background(Color.blue)
    }
}
#endif

