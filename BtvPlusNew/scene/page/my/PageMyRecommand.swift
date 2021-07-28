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
    
    static let strongStyle = TextModifier(
        family: Font.family.bold,
        size: Font.size.thinExtra,
        color: Color.brand.primary
    )
    
    
    static let leftSize:CGFloat = SystemEnvironment.isTablet ? 150 : 100
    static let rightSize:CGFloat = SystemEnvironment.isTablet ? 150 : 100
}

struct PageMyRecommand: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
     
    
    @State var marginBottom:CGFloat = 0
    @State var sceneOrientation: SceneOrientation = .portrait
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: String.pageTitle.recommandFriend,
                        isClose : true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    ZStack(alignment: .topLeading){
                        DragDownArrow(
                            infinityScrollModel: self.infinityScrollModel)
                        InfinityScrollView(
                            viewModel: self.infinityScrollModel,
                            marginBottom: self.sceneObserver.safeAreaBottom + Dimen.margin.thin,
                            isRecycle:false,
                            useTracking: true
                            ){
                            
                            VStack(alignment: .leading, spacing: 0){
                                if SystemEnvironment.isTablet {
                                    HStack(spacing: 0){
                                        VStack(alignment: .center, spacing: 0){
                                            Spacer().modifier(MatchHorizontal(height: 0))
                                            Text(String.pageText.recommandFriendText1)
                                                .modifier(BoldTextStyle( size: Font.size.medium ))
                                            Text(String.pageText.recommandFriendText2)
                                                .modifier(BoldTextStyle( size: Font.size.medium, color: Color.brand.primary))
                                                .padding(.top, Dimen.margin.tinyExtra)
                                            HStack( spacing: Dimen.margin.tiny) {
                                                Text(String.pageText.recommandFriendText3)
                                                    .modifier(MediumTextStyle( size: Font.size.thin, color: Color.app.greyLight))
                                                Image(Asset.icon.recommendPoint)
                                                    .renderingMode(.original)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 91, height: 24)
                                                Text(String.pageText.recommandFriendText4)
                                                    .modifier(MediumTextStyle( size: Font.size.thin, color: Color.app.greyLight))
                                            }
                                            .padding(.top, Dimen.margin.regularExtra)
                                            Text(String.pageText.recommandFriendText5)
                                                .modifier(MediumTextStyle( size: Font.size.thin, color: Color.app.greyLight))
                                                .padding(.top, Dimen.margin.micro)
                                            Text(String.pageText.recommandFriendTip)
                                                .modifier(MediumTextStyle( size: Font.size.tinyExtra, color: Color.app.grey))
                                                .padding(.top, Dimen.margin.thin)
                                        }
                                        Image(Asset.image.recommendDetail)
                                            .renderingMode(.original)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 244, height: 197)
                                
                                    }
                                    .padding(.top, Dimen.margin.medium)
                                } else {
                                    VStack(alignment: .center, spacing: 0){
                                        Spacer().modifier(MatchHorizontal(height: 0))
                                        Text(String.pageText.recommandFriendText1)
                                            .modifier(BoldTextStyle( size: Font.size.medium ))
                                        Text(String.pageText.recommandFriendText2)
                                            .modifier(BoldTextStyle( size: Font.size.medium, color: Color.brand.primary))
                                            .padding(.top, Dimen.margin.tiny)
                                        Image(Asset.image.recommendDetail)
                                            .renderingMode(.original)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 203, height: 164)
                                            .padding(.top, Dimen.margin.medium)
                                        HStack( spacing: Dimen.margin.tiny) {
                                            Text(String.pageText.recommandFriendText3)
                                                .modifier(MediumTextStyle( size: Font.size.regular, color: Color.app.greyLight))
                                            Image(Asset.icon.recommendPoint)
                                                .renderingMode(.original)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 83, height: 22)
                                            Text(String.pageText.recommandFriendText4)
                                                .modifier(MediumTextStyle( size: Font.size.regular, color: Color.app.greyLight))
                                        }
                                        .padding(.top, Dimen.margin.medium)
                                        Text(String.pageText.recommandFriendText5)
                                            .modifier(MediumTextStyle( size: Font.size.regular, color: Color.app.greyLight))
                                            .padding(.top, Dimen.margin.tinyExtra)
                                        Text(String.pageText.recommandFriendTip)
                                            .modifier(MediumTextStyle( size: Font.size.thinExtra, color: Color.app.grey))
                                            .padding(.top, Dimen.margin.light)
                                    }
                                    .padding(.top, Dimen.margin.medium)
                                }
                                if let board = self.board {
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
                                        datas: board
                                    )
                                    .padding(.top, SystemEnvironment.isTablet ? Dimen.margin.mediumExtra : Dimen.margin.mediumUltra)
                                }
                                
                                if let historys = self.historys {
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
                                        datas: historys
                                    )
                                    .padding(.top, Dimen.margin.medium)
                                }
                            }
                            .modifier(ListRowInset(
                                        marginHorizontal:self.sceneOrientation == .landscape ? Dimen.margin.heavy : Dimen.margin.regular,
                                        spacing: 0))
                        }
                    }
                    .background(Color.app.blueDeep)
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                .onReceive(self.infinityScrollModel.$event){evt in
                    guard let evt = evt else {return}
                    switch evt {
                    case .pullCompleted:
                        self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                    case .pullCancel :
                        self.pageDragingModel.uiEvent = .pullCancel(geometry)
                    default : break
                    }
                }
                .onReceive(dataProvider.$result) { res in
                    guard let res = res else { return }
                    switch res.type {
                    case .getRecommendHistory :
                        guard let historys = res.data as? RecommandHistory else { return }
                        self.setupHistory(historys) 
                    default: break
                    }
                }
                .onReceive(dataProvider.$error) { err in
                    guard let err = err else { return }
                    switch err.type {
                    case .getRecommendHistory : break
                    default: break
                    }
                }
                .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                    self.pageDragingModel.uiEvent = .pull(geometry, pos)
                }
            }//PageDragingBody
            
            .onReceive(self.sceneObserver.$isUpdated){ _ in
                self.sceneOrientation = self.sceneObserver.sceneOrientation
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.dataProvider.requestData(q: .init(type: .getRecommendHistory))
                }
            }
            .onAppear{
                self.sceneOrientation = self.sceneObserver.sceneOrientation
            }
        }//geo
    }//body
    
    @State var board:[TableCellSet]? = nil
    @State var historys:[TableCellSet]? = nil
    
    private func setupHistory(_ data:RecommandHistory){
        withAnimation{
            self.board = [.init(
                idx:0,
                cells: [
                    .init( text: data.rec_total_cnt ?? "-",idx:0),
                    .init( text: data.rec_succ_cnt ?? "-", idx:1),
                    .init( text: (data.bpoint_total ?? "-") + String.app.point , idx:2, textModifier: Self.strongStyle)
                ]
            )]
            if let datas = data.rec_succ_list {
                self.historys = zip(0..<datas.count, datas).map{idx,  data in
                    TableCellSet(
                        idx:idx,
                        cells: [
                            .init( text: data.rec_date ?? "-",idx:0, size: Self.leftSize),
                            .init( text: data.title ?? "-", idx:1),
                            .init( text: data.bpoint ?? "-", idx:2, size: Self.rightSize)
                        ]
                    )
                }
            }
        }
    }
    

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
