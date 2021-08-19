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
    let action: (_ type:EuxpNetwork.SortType) -> Void
    
    @State var sortType:EuxpNetwork.SortType = Self.finalSortType
    let sortOption:[EuxpNetwork.SortType] = [
        .popularity,.latest,.title,.price
    ]
    
    
    var body: some View {
        HStack(alignment:.center, spacing: Dimen.margin.thin){
            Text(String.app.total + self.count.description + String.app.count)
                .modifier(MediumTextStyle(
                    size: Font.size.lightExtra,
                    color: Color.app.white)
                )
                .opacity(0.5)
            Spacer()
            if let info = self.info {
                InfoAlert(text: info)
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

