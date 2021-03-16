//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI

struct PageCategory: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PageDataProviderModel = PageDataProviderModel()
    
    let listWidth:CGFloat = (ListItem.cate.size.width * CGFloat(CateList.cellCount)) + CateList.magin
    @State var headerHeight:CGFloat = 0
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel
        ){
            VStack(alignment: .center, spacing: 0){
                if self.datas.isEmpty {
                    Spacer().modifier(MatchParent())
                } else {
                    CateList( datas: self.datas)
                        .padding(.top, self.headerHeight)
                        .modifier(MatchVertical(width: self.listWidth))
                }
                
                HStack(spacing:Dimen.margin.thinExtra){
                    if let data = self.eventData  {
                        FillButton(
                            text: self.eventData?.title ?? "",
                            image: Asset.icon.cateEvent,
                            bgColor: Color.app.blueLightExtra
                        ){_ in
                            if data.blocks != nil && data.blocks?.isEmpty == false {
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.multiBlock)
                                        .addParam(key: .data, value: data)
                                )
                            }else{
                                
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.categoryList)
                                        .addParam(key: .title, value: data.title)
                                        .addParam(key: .id, value: data.menuId)
                                        .addParam(key: .type, value: CateBlock.ListType.poster)
                                )
                            }
                        }
                    }
                    if let data = self.tipData {
                        FillButton(
                            text: self.tipData?.title ?? "",
                            image: Asset.icon.cateTip,
                            bgColor: Color.app.blueLightExtra
                        ){_ in
                            if data.blocks != nil && data.blocks?.isEmpty == false {
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.multiBlock)
                                        .addParam(key: .data, value: data)
                                )
                            }else{
                                
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.categoryList)
                                        .addParam(key: .title, value: data.title)
                                        .addParam(key: .id, value: data.menuId)
                                        .addParam(key: .type, value: CateBlock.ListType.poster)
                                )
                            }
                        }
                    }
                }
                .frame(width: self.listWidth)
                .padding(.vertical, Dimen.margin.thin)
            }
            .padding(.bottom, Dimen.app.bottom + self.sceneObserver.safeAreaBottom)
        }
        .modifier(PageFull())
        .onReceive(self.pageSceneObserver.$headerHeight){ hei in
            self.headerHeight = hei
        }
        .onReceive(self.viewModel.$event ){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .onResult(_, _, _) : do{}
            default : break
            }
        }
        .onAppear{
            guard let obj = self.pageObject  else { return }
            let menuId = (obj.getParamValue(key: .id) as? String) ?? ""
            self.setupDatas(menuId:menuId)
            self.pageSceneObserver.useTopFix = true
        }
        .onDisappear{
            self.pageSceneObserver.useTopFix = nil
        }
    }//body
    
    @State var datas:[CateDataSet] = []
    @State var eventData:CateData? = nil
    @State var tipData:CateData? = nil
    private func setupDatas(menuId:String){
        guard let blocksData = self.dataProvider.bands.getData(menuId: menuId)?.blocks else { return }
        let cateDatas = blocksData.map{ block in
            CateData().setData(data: block)
        }
        let count = CateList.cellCount
        var rows:[CateDataSet] = []
        var cells:[CateData] = []
        var total = cateDatas.count
        cateDatas.forEach{ d in
            switch d.subType{
            case .tip : tipData = d
            case .event : eventData = d
            default :
                if cells.count < count {
                    cells.append(d)
                }else{
                    rows.append(
                        CateDataSet( count: count, datas: cells, isFull: true, index: total)
                    )
                    cells = [d]
                    total += 1
                }
            }
        }
        if !cells.isEmpty {
            rows.append(
                CateDataSet( count: count, datas: cells,isFull: cells.count == count, index: total)
            )
        }
        self.datas.append(contentsOf: rows)
    }
    
}


#if DEBUG
struct PageCategory_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageCategory().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(SceneObserver())
                .environmentObject(DataProvider())
                .environmentObject(Repository())
                .environmentObject(PageSceneObserver())
                .frame(width: 320, height: 640, alignment: .center)
        }
    }
}
#endif

