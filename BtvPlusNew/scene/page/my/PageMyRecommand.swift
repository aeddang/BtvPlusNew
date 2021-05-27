//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

extension PageMyRecommand{
    static let headerStyle = TextModifier(
        family: Font.family.medium,
        size: Font.size.thinExtra,
        color: Color.app.greyLight
    )
    
    static let leftSize:CGFloat = SystemEnvironment.isTablet ? 150 : 100
    static let rightSize:CGFloat = SystemEnvironment.isTablet ? 150 : 100
}

struct PageMyRecommand: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
     
    
    @State var marginBottom:CGFloat = 0
    @State var sceneOrientation: SceneOrientation = .portrait
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: String.pageTitle.recommandFriend,
                        isBack : true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    InfinityScrollView(
                        viewModel: self.infinityScrollModel,
                        isRecycle:false,
                        useTracking: false
                        ){
                        
                        VStack(alignment: .leading, spacing: 0){
                            Text(String.pageText.recommandFriendText1)
                                .modifier(MediumTextStyle( size: Font.size.regular ))
                                .padding(.top, Dimen.margin.medium)
                            Text(String.pageText.recommandFriendText2)
                                .modifier(MediumTextStyle( size: Font.size.bold, color: Color.brand.primary))
                                .padding(.top, Dimen.margin.thin)
                            Text(String.pageText.recommandFriendText3)
                                .modifier(MediumTextStyle( size: Font.size.lightExtra, color: Color.app.greyLight))
                                .padding(.top, Dimen.margin.regular)
                            Text(String.pageText.recommandFriendText4)
                                .modifier(MediumTextStyle( size: Font.size.thinExtra, color: Color.app.grey))
                                .padding(.top, Dimen.margin.tiny)
                               
                            DivisionTable(
                                title: String.pageText.recommandFriendTable1,
                                header: .init( cells: [
                                    .init( text: String.pageText.recommandFriendTable1Sub1,
                                           textModifier: Self.headerStyle),
                                    .init( text: String.pageText.recommandFriendTable1Sub2,
                                           textModifier: Self.headerStyle),
                                    .init( text: String.pageText.recommandFriendTable1Sub3,
                                           textModifier: Self.headerStyle)
                                ]),
                                datas: [
                                    .init(
                                        idx:0,
                                        cells: [
                                            .init( text: "value",idx:0),
                                            .init( text: "value", idx:1),
                                            .init( text: "value", idx:2)
                                        ]
                                    ),
                                    .init(
                                        idx:1,
                                        cells: [
                                            .init( text: "value", idx:0),
                                            .init( text: "value", idx:1),
                                            .init( text: "value", idx:2)
                                        ]
                                    ),
                                    .init(
                                        idx:2,
                                        cells: [
                                            .init( text: "value", idx:0),
                                            .init( text: "value", idx:1),
                                            .init( text: "value", idx:2)
                                        ]
                                    )
                                ]
                            )
                            .padding(.top, Dimen.margin.medium)
                            
                            DivisionTable(
                                title: String.pageText.recommandFriendTable2,
                                header: .init( cells: [
                                    .init( text: String.pageText.recommandFriendTable2Sub1,
                                           size: Self.leftSize,
                                           textModifier: Self.headerStyle),
                                    .init( text: String.pageText.recommandFriendTable2Sub2,
                                           textModifier: Self.headerStyle),
                                    .init( text: String.pageText.recommandFriendTable2Sub3,
                                           size: Self.rightSize,
                                           textModifier: Self.headerStyle)
                                ]),
                                datas: [
                                    .init(
                                        idx:0,
                                        cells: [
                                            .init( text: "value",idx:0, size: Self.leftSize),
                                            .init( text: "value", idx:1),
                                            .init( text: "value", idx:2, size: Self.rightSize)
                                        ]
                                    ),
                                    .init(
                                        idx:1,
                                        cells: [
                                            .init( text: "value", idx:0, size: Self.leftSize),
                                            .init( text: "value", idx:1),
                                            .init( text: "value", idx:2, size: Self.rightSize)
                                        ]
                                    ),
                                    .init(
                                        idx:2,
                                        cells: [
                                            .init( text: "value", idx:0, size: Self.leftSize),
                                            .init( text: "value", idx:1),
                                            .init( text: "value", idx:2, size: Self.rightSize)
                                        ]
                                    )
                                ]
                            )
                            .padding(.top, Dimen.margin.medium)
                        }
                        .modifier(ListRowInset(
                                    marginHorizontal:self.sceneOrientation == .landscape ? Dimen.margin.heavy : Dimen.margin.regular,
                                    spacing: 0))
                    }
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//PageDragingBody
            .onReceive(self.sceneObserver.$isUpdated){ _ in
                self.sceneOrientation = self.sceneObserver.sceneOrientation
            }
            .onAppear{
                self.sceneOrientation = self.sceneObserver.sceneOrientation
            }
        }//geo
    }//body
    
    

}

#if DEBUG
struct PageMyRecommand_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMyRecommand().contentBody
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
