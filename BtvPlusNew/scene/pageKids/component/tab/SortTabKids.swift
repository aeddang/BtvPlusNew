//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI


extension SortTabKids{
    static fileprivate(set) var finalSortType:EuxpNetwork.SortType = .popularity
}

struct SortTabKids: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var menuTitle:String? = nil
    var count:Int = 0
    var isSortAble:Bool = false
    
    let action: (_ type:EuxpNetwork.SortType) -> Void
    
    @State var sortType:EuxpNetwork.SortType = Self.finalSortType
    let sortOption:[EuxpNetwork.SortType] = [
        .popularity,.latest,.title,.price
    ]
    
    var body: some View {
        HStack(alignment:.center, spacing: Dimen.margin.thin){
            VStack(alignment:.leading, spacing: 0){
                Spacer().modifier(MatchHorizontal(height: 0))
                if let title = self.menuTitle {
                    HStack(alignment:.bottom, spacing: DimenKids.margin.tiny){
                        Text(title)
                            .modifier(BlockTitleKids())
                        Text("(" + self.count.description + String.app.count + ")")
                            .modifier(BoldTextStyleKids(
                                size: Font.sizeKids.thin,
                                color: Color.app.sepia)
                            )
                            .opacity(0.5)
                    }
                } else {
                    Text(String.app.total + " " + self.count.description + String.app.count)
                        .modifier(BoldTextStyleKids(
                            size: Font.sizeKids.thin,
                            color: Color.app.sepia)
                        )
                        .opacity(0.5)
                }
            }
            if self.isSortAble {
                SortButtonKids(text: self.sortType.name){
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
struct SortTabKids_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            SortTabKids(
               
            ){ _ in
                
            }
            .environmentObject(PagePresenter())
        }.background(Color.blue)
    }
}
#endif

