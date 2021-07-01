//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI




struct PageKidsMy: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var tabNavigationModel:NavigationModel = NavigationModel()
    
    @State var kid:Kid? = nil
    
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                
                VStack (alignment: .center, spacing:0){
                    PageKidsTab(
                        title:String.kidsTitle.kidsMy,
                        isBack: true)
                        
                    HStack(alignment: .center, spacing: 0) {
                        ZStack{
                            Spacer().modifier(MatchVertical(width: 0))
                            VStack(spacing:DimenKids.margin.thin){
                                if let kid = self.kid{
                                    KidProfileBox(data: kid)
                                } else {
                                    KidProfileBox(data: Kid(), isEmpty:true)
                                }
                                RectButtonKids(
                                    text: String.kidsTitle.registKidManagement,
                                    textModifier: BoldTextStyleKids(
                                        size: Font.sizeKids.tiny,
                                        color: Color.app.sepia).textModifier,
                                    bgColor: Color.app.ivoryLight,
                                    size: CGSize(
                                        width:DimenKids.item.profileBox.width ,
                                        height: DimenKids.button.lightUltra),
                                    cornerRadius:  DimenKids.radius.medium,
                                    isMore: true
                                ) { _ in
                                    
                                    self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.kidsProfileManagement))
                                }
                            }
                            .padding(.horizontal, DimenKids.margin.light)
                        }
                        .background(
                            Image(AssetKids.source.profileBg)
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFill()
                                .modifier(MatchParent())
                        )
                        .clipped()
                        VStack{
                            if !self.tabs.isEmpty {
                                MenuNavi(viewModel: self.tabNavigationModel, buttons: self.tabs, selectedIdx: self.tabIdx)
                            }
                        }
                        .modifier(MatchParent())
                        
                    }
                    .modifier(ContentHeaderEdgesKids())
                    
                }

                .modifier(PageFullScreen(style:.kids))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
              
            }//draging
            .onReceive(dataProvider.$result) { res in
                guard let res = res else { return }
                if res.id != self.tag { return }
                switch res.type {
                default: break
                }
            }
            .onReceive(dataProvider.$error) { err in
                guard let err = err else { return }
                if err.id != self.tag { return }
                switch err.type {
                default: break
                }
            }
            
            
            .onReceive(self.pairing.$kid){ kid in
                self.kid = kid
            }
            .onAppear{
                self.tabDatas = self.dataProvider.bands.kidsGnbModel
                    .getMyDatas()?
                    .filter{$0.menu_nm != nil} ?? []
                
                self.tabs = self.tabDatas.map{$0.menu_nm ?? ""}
            }
        }//geo
    }//body
    
    @State var tabIdx:Int = 0
    @State var tabDatas:[BlockItem] = []
    @State var tabs:[String] = []
}

#if DEBUG
struct PageKidsMy_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            PageKidsMy().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(DataProvider())
                .environmentObject(Pairing())
                .frame(width: 360, height: 680, alignment: .center)
        }
    }
}
#endif
