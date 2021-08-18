//
//  PosterBox.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI
import Combine
extension TvBlock{
    static let skeletonNum:Int = SystemEnvironment.isTablet ? 6 : 3
}

struct TvBlock:PageComponent, BlockProtocol {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var naviLogManager:NaviLogManager
    var pageObservable:PageObservable
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var data: BlockData
    var useTracking:Bool = false
    @State var datas:[TvData] = []
    @State var isUiActive:Bool = true
    @State var hasMore:Bool = true
    @State var skeletonSize:CGSize = CGSize()
    
    @State var list: TvList?
    private func getList() -> some View {
        if let list = self.list {return list}
        let newList = TvList(
            viewModel:self.viewModel,
            datas: self.datas,
            useTracking:true)
        DispatchQueue.main.async {
            self.list = newList
        }
        return newList
    }
    
    var body :some View {
        VStack(alignment: .leading , spacing: Dimen.margin.thinExtra) {
            if self.isUiActive {
                HStack(alignment: .bottom, spacing:Dimen.margin.thin){
                    VStack(alignment: .leading , spacing:Dimen.margin.tiny){
                        Spacer().modifier(MatchHorizontal(height: 0))
                        HStack( spacing:Dimen.margin.tiny){
                            Text(data.name).modifier(BlockTitle())
                                .lineLimit(1)
                            Text(data.subName).modifier(BlockTitle(color:Color.app.grey))
                                .lineLimit(1)
                            Image(Asset.icon.searchOnlyBtv)
                                .renderingMode(.original).resizable()
                                .scaledToFit()
                                .frame(height: Dimen.icon.thin)
                                .padding(.top, -Dimen.margin.micro)
                        }
                    }
                    if self.hasMore {
                        TextButton(
                            defaultText: String.button.all,
                            textModifier: MediumTextStyle(size: Font.size.thin, color: Color.app.white).textModifier
                        ){_ in
                            self.sendLog(self.naviLogManager)
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.categoryList)
                                    .addParam(key: .data, value: data)
                                    .addParam(key: .type, value: CateBlock.ListType.tv)
                            )
                        }
                    }
                }
                .modifier(MatchHorizontal(height: Dimen.tab.thin))
                .modifier(ContentHorizontalEdges())
                if !self.datas.isEmpty {
                    self.getList()
                } else {
                    SkeletonBlock(
                        len:Self.skeletonNum,
                        spacing:Dimen.margin.tiny,
                        size:self.skeletonSize
                    )
                    .modifier(MatchParent())
                }
            }
        }
        .modifier(MatchParent())
        .modifier(
            ContentScrollPull(
                infinityScrollModel: self.viewModel,
                pageDragingModel: self.pageDragingModel)
        )
        .onAppear{
            if !self.datas.isEmpty {
                ComponentLog.d("RecycleData " + data.name, tag: "BlockProtocol")
                return
            }
            if let datas = data.tvs {
                if data.allTvs?.isEmpty == true {
                    self.hasMore = false
                }
                if let size = datas.first?.type.size {
                    self.skeletonSize = size
                }
                ComponentLog.d("ExistData " + data.name, tag: "BlockProtocol")
                self.creatDataBinding()
                return
            }
        }
        .onDisappear{
            self.clearDataBinding()
        }
        .onReceive(self.pageObservable.$layer ){ layer  in
            switch layer {
            case .bottom : self.isUiActive = false
            case .top, .below : self.isUiActive = true
            }
        }
        
    }
    
    func updateListSize(){
        if !self.datas.isEmpty {
            onDataBinding()
        }
        else { onBlank() }
    }
    
    @State var dataBindingSubscription:AnyCancellable?
    func creatDataBinding() {
    
        self.dataBindingSubscription?.cancel()
        self.dataBindingSubscription = Timer.publish(
            every: SkeletonBlock.dataBindingDelay , on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.clearDataBinding()
                if let datas = data.tvs {
                    DispatchQueue.global(qos: .background).async {
                        withAnimation{ self.datas = datas }
                    }
                }
            }
    }
    func clearDataBinding() {
        self.dataBindingSubscription?.cancel()
        self.dataBindingSubscription = nil
    }
    
}
