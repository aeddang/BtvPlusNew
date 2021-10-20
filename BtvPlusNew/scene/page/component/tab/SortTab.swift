//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI


extension SortTab{
    static fileprivate(set) var finalSortType:EuxpNetwork.SortType = .popularity
}

struct SortTab: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    
    var count:Int = 0
    var isSortAble:Bool = false
    var info:String? = nil
    
    var menuTitle:String? = nil
    var selectedTitle:String? = nil
    var selectedMenuIdx:Int = -1
    var menus:[String]? = nil
    var menuAction: ((_ menuIdx:Int) -> Void)? = nil
    
    var sortOption:[EuxpNetwork.SortType] = [
        .popularity,.latest,.title,.price
    ]
    
    let action: (_ type:EuxpNetwork.SortType) -> Void
    
    @State var sortType:EuxpNetwork.SortType = Self.finalSortType
    
    
    
    var body: some View {
        HStack(alignment:.center, spacing: Dimen.margin.thin){
            VStack(alignment:.leading, spacing:0){
                Spacer().modifier(MatchHorizontal(height: 0))
                HStack(alignment:.center, spacing: Dimen.margin.thin){
                    if let menus = self.menus, let title = self.selectedTitle {
                        DropDownButton(
                            title: title,
                            openTitle: self.menuTitle,
                            selectedIndex: self.selectedMenuIdx,
                            menus: menus
                        ){ idx in
                                self.menuAction?(idx)
                        }
                    }
                    Text(String.app.total + " " + self.count.description + String.app.count)
                        .modifier(MediumTextStyle(
                            size: Font.size.lightExtra,
                            color: Color.app.greyMedium)
                        )
                }
            }
            if let info = self.info {
                InfoAlert(text: info)
                    .fixedSize(horizontal: true, vertical: true)
            }
            if self.isSortAble {
                TextButton(
                    defaultText: self.sortType.name,
                    textModifier: TextModifier(
                        family: Font.family.medium,
                        size: Font.size.lightExtra,
                        color: Color.app.white),
                    image: Asset.icon.sortList,
                    imageSize: Dimen.icon.thinExtra,
                    spacing: Dimen.margin.micro
                    ){_ in
                    let idx = sortOption.firstIndex(where: {$0 == self.sortType})
                    self.appSceneObserver.select =
                        .select((self.tag , self.sortOption.map{$0.name}), idx ?? -1)
                    
                }
            }
        }
        .onReceive(self.appSceneObserver.$selectResult){ result in
            guard let result = result else { return }
            switch result {
                case .complete(let type, let idx) : do {
                    if type.check(key: self.tag){
                        self.sortType = self.sortOption[idx]
                        Self.finalSortType = sortType
                        self.action(self.sortType)
                    }
                }
            }
        }
        .onAppear{
            self.sortType = sortOption.first(where: {$0 == Self.finalSortType}) == nil
                ?  sortOption.first ?? .popularity
                : Self.finalSortType
        }
    }//body
}



#if DEBUG
struct SortTab_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            SortTab(
               
            ){ _ in
                
            }
            .environmentObject(PagePresenter())
        }.background(Color.blue)
    }
}
#endif

