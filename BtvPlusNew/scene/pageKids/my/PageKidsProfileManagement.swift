//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
extension PageKidsProfileManagement{
    static let maxUser:Int = 3
}

struct PageKidsProfileManagement: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    
    @State var currentKid:Kid? = nil
    @State var kids:[Kid] = []
    @State var useEmpty:Bool = false
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(alignment: .center, spacing: 0) {
                    PageKidsTab(
                        title:String.kidsTitle.registKidManagement,
                        isBack: true,
                        isSetting: true)
                    HStack(alignment: .center, spacing: DimenKids.margin.mediumUltra){
                        ForEach(self.kids) { kid in
                            KidProfileListItem(data: kid, isSelected : self.currentKid?.id == kid.id)
                                .onTapGesture {
                                    if self.currentKid?.id == kid.id {
                                        return
                                    }
                                    
                                    self.appSceneObserver.alert = .confirm(
                                        nil ,
                                        String.alert.kidsChange.replace(kid.nickName),
                                        String.alert.kidsChangeTip
                                        ){ isOk in
                                        if isOk {
                                            self.pairing.requestPairing(.selectKid(kid))
                                        }
                                    }
                                }
                        }
                        if self.useEmpty {
                            KidProfileListEmpty()
                        }
                    }
                    .modifier(MatchParent())
                }
                .background(
                    Image(AssetKids.image.homeBg)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFill()
                        .modifier(MatchParent())
                        
                )
                .modifier(PageFullScreen(style:.kids))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }
           
            .onReceive(self.pairing.$event) { evt in
                guard let evt = evt else { return }
                switch evt {
                case .updatedKids, .notFoundKid :
                    self.kids = self.pairing.kids
                    self.useEmpty = self.kids.count < Self.maxUser
                default : break
                }
            }
            .onReceive(self.pairing.$kid) { kid in
                self.currentKid = kid
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    withAnimation{
                        self.kids = self.pairing.kids
                        self.useEmpty = self.kids.count < Self.maxUser
                    }
                }
            }
            .onAppear{
                
                
            }
        }
    }//body
}

#if DEBUG
struct PageKidsProfileManagement_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageKidsProfileManagement().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(NetworkObserver())
                .environmentObject(DataProvider())
                .environmentObject(Pairing())
                .frame(width: 420, height: 640, alignment: .center)
        }
    }
}
#endif
