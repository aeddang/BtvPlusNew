//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI
import Combine

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
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var playerModel: BtvPlayerModel = BtvPlayerModel()
    
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
                            PlayItem(
                                pageObservable:self.pageObservable,
                                playerModel:self.playerModel,
                                data: data,
                                isSelected: data.index == self.focusIndex,
                                isPlay: data.index == self.playIndex
                                )
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
                                .onTapGesture {
                                    if self.focusIndex != data.index {
                                        withAnimation{ self.focusIndex = data.index }
                                        self.playIndex = -1
                                    } else {
                                        self.playIndex = data.index
                                    }
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
        .onDisappear(){
            self.delayUpdateCancel()
        }
        
    }//body
    
    @State var isError:Bool = false
    @State var datas:[PlayData] = []
    @State var reloadDegree:Double = 0
    @State var appearList:[Int] = []
    @State var appearValue:Float = 0
    @State var focusIndex:Int = 0
    @State var playIndex:Int = -1
     
    func reload(){
        self.delayUpdateCancel()
        self.datas = []
        self.appearList = []
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
    
    
    private func setDatas(datas:[PreviewContentsItem]?) {
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
    
    private func onAppear(idx:Int){
        if self.appearList.first(where: {$0 == idx}) == nil {
            self.appearList.append(idx)
        }
        self.delayUpdate()
    }
    private func onDisappear(idx:Int){
        if let find = self.appearList.firstIndex(where: {$0 == idx}) {
            self.appearList.remove(at: find)
        }
        self.delayUpdate()
    }
    
    @State var delayUpdateSubscription:AnyCancellable?
    func delayUpdate(){
        self.delayUpdateSubscription?.cancel()
        self.delayUpdateSubscription = Timer.publish(
            every: 0.1, on: .current, in: .tracking)
            .autoconnect()
            .sink() {_ in
                self.delayUpdateCancel()
                self.onUpdate()
            }
    }
    
    func delayUpdateCancel(){
        //ComponentLog.d("autoChangeCancel", tag:self.tag)
        self.delayUpdateSubscription?.cancel()
        self.delayUpdateSubscription = nil
    }
    
    private func onUpdate(){
        if self.appearList.isEmpty {
            return
        }
        self.appearList.sort()
        let value = Float(self.appearList.reduce(0, {$0 + $1}) / self.appearList.count)
        //PageLog.d("self.apearList " + self.appearList.debugDescription, tag: self.tag)
        //PageLog.d("self.appearValue " + value.debugDescription, tag: self.tag)
        let diff = self.appearValue - value
        self.appearValue = value
        let willIdx = Int(round(Double(self.appearList.count/2)))
        var willFocus = self.appearList[willIdx]
        if diff > 0 {
            //PageLog.d("self.appearValue Up " + willFocus.description, tag: self.tag)
            if self.appearList.first == 0 && willFocus == self.focusIndex {
                willFocus = self.appearList.first ?? 0
            }
        } else {
            //PageLog.d("self.appearValue Down " + willFocus.description, tag: self.tag)
            if self.appearList.last == (self.datas.count-1) && willFocus == self.focusIndex{
                willFocus = self.appearList.last ?? self.datas.count-1
            }
        }
        if self.focusIndex != willFocus  {
            self.playIndex = -1
            withAnimation{ self.focusIndex = willFocus }
        }
        
    }

}



