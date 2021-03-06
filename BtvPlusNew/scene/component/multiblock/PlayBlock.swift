//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI


class PlayBlockModel: PageDataProviderModel {
    private(set) var dataType:BlockData.DataType = .grid
    private(set) var key:String? = nil
    private(set) var menuId:String? = nil
     
    @Published private(set) var isUpdate = false {
        didSet{ if self.isUpdate { self.isUpdate = false} }
    }
    
    func update(menuId:String?, key:String? = nil) {
        self.menuId = menuId
        self.key = key
        self.isUpdate = true
    }
}


struct PlayBlock: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    @ObservedObject var viewModel:PlayBlockModel = PlayBlockModel()
    var key:String? = nil
    var useTracking:Bool = false
    var marginTop : CGFloat = 0
    var marginBottom : CGFloat = 0
    var spacing: CGFloat = Dimen.margin.medium
   
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel
        ){
            if !self.isError {
                ZStack(alignment: .topLeading){
                    VStack{
                        ReflashSpinner(
                            progress: self.$reloadDegree
                        )
                        .padding(.top, self.marginTop)
                        Spacer()
                    }
                    InfinityScrollView(
                        viewModel: self.infinityScrollModel,
                        axes: .vertical,
                        marginTop: self.marginTop,
                        marginBottom : self.marginBottom,
                        spacing: 0,
                        isRecycle: true,
                        useTracking: self.useTracking){
                        ForEach(self.datas) { data in
                            PlayItem(data: data)
                                .modifier(
                                    ListRowInset(
                                        marginHorizontal:Dimen.margin.thin,
                                        spacing: self.spacing,
                                        marginTop: self.marginTop
                                    )
                                )
                                .onAppear{
                                    if data.index == self.datas.last?.index {
                                        self.load()
                                    }
                                    self.onAppear(idx:data.index)
                                }
                                .onDisappear{
                                    self.onDisappear(idx: data.index)
                                }
                        }
                    }
                    .modifier(MatchParent())
                    .background(Color.brand.bg)
                }
                .background(Color.brand.bg)
            } else {
                ZStack{
                    VStack(alignment: .center, spacing: 0){
                        Spacer().modifier(MatchHorizontal(height:0))
                        Image(Asset.icon.alert)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Dimen.icon.mediumUltra, height: Dimen.icon.mediumUltra)
                            .padding(.top, Dimen.margin.medium)
                        Text(String.alert.dataError)
                            .modifier(BoldTextStyle(size: Font.size.regular, color: Color.app.greyLight))
                            .multilineTextAlignment(.center)
                            .padding(.top, Dimen.margin.regularExtra)
                    }
                }
                .modifier(MatchParent())
            }
            
            
        }
        .onReceive(self.infinityScrollModel.$event){evt in
            guard let evt = evt else {return}
            switch evt {
            case .pullCancel :
                if !self.infinityScrollModel.isLoading {
                    if self.reloadDegree >= ReflashSpinner.DEGREE_MAX { self.reload() }
                }
                withAnimation{
                    self.reloadDegree = 0
                }
            default : do{}
            }
            
        }
        .onReceive(self.infinityScrollModel.$pullPosition){ pos in
            if pos < InfinityScrollModel.PULL_RANGE { return }
            withAnimation{
                self.reloadDegree = Double(pos - InfinityScrollModel.PULL_RANGE)
            }
        }
        
        .onReceive(self.viewModel.$isUpdate){ update in
            if update {
                self.reload()
            }
        }
        .onReceive(self.viewModel.$event){evt in
            guard let evt = evt else { return }
            switch evt {
            case .onResult(_, let res, _):
                self.loaded(res)
            case .onError(_,  _, _):
                self.onError()
            default : break
            }
        }
        
    }//body
    
    @State var isError:Bool = false
    @State var datas:[PlayData] = []
    @State var reloadDegree:Double = 0
    @State var apearList:[Int] = []
    
     
    func reload(){
        self.datas = []
        self.apearList = []
        self.infinityScrollModel.reload()
        self.load()
    }
    
    
    func load(){
        if  !self.infinityScrollModel.isLoadable { return }
        withAnimation{ self.isError = false }
        self.infinityScrollModel.onLoad()
        self.viewModel.request = .init(
            id: self.tag,
            type: .getGridPreview(
                self.viewModel.menuId,
                self.infinityScrollModel.page + 1),
            isOptional:true
        )
    }
    
    private func onError(){
        withAnimation{ self.isError = true }
    }
    
    private func loaded(_ res:ApiResultResponds){
        guard let data = res.data as? GridPreview else { return }
        setDatas(datas: data.contents)
       
    }
    
    
    func setDatas(datas:[PreviewContentsItem]?) {
        guard let datas = datas else {
            if self.datas.isEmpty { self.onError() }
            return
        }
        let start = self.datas.count
        let end = datas.count
        let loadedDatas:[PlayData] = zip(start...end, datas).map { idx, d in
            return PlayData().setData(data: d, idx: idx)
        }
        self.datas.append(contentsOf: loadedDatas)
        self.infinityScrollModel.onComplete(itemCount: loadedDatas.count)
    }
    
    func onAppear(idx:Int){
        if self.apearList.first(where: {$0 == idx}) == nil {
            self.apearList.append(idx)
        }
        PageLog.d("self.apearList " + self.apearList.debugDescription, tag: self.tag)
    }
    func onDisappear(idx:Int){
        if let find = self.apearList.firstIndex(where: {$0 == idx}) {
            self.apearList.remove(at: find)
        }
        PageLog.d("self.apearList " + self.apearList.debugDescription, tag: self.tag)
    }

}



