//
//  VideoList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import struct Kingfisher.KFImage


struct AlramList: PageComponent{
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[AlramData]
    var useTracking:Bool = false
    var marginBottom:CGFloat = Dimen.margin.tinyExtra
    
    @State var isPush:Bool = false
    @State var horizontalMargin:CGFloat = Dimen.margin.thin
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .vertical,
            scrollType : .reload(isDragEnd:false),
            marginTop: Dimen.margin.regular,
            marginBottom: self.marginBottom,
            spacing: 0,
            useTracking: self.useTracking
        ){
            InfoAlert(text: String.pageText.myAlramInfo)
                .modifier(ListRowInset(marginHorizontal:self.horizontalMargin ,spacing: Dimen.margin.thin))
            if !self.datas.isEmpty {
                ForEach(self.datas) { data in
                    AlramItem( data:data )
                        .modifier(ListRowInset(marginHorizontal:self.horizontalMargin ,spacing: Dimen.margin.tinyExtra))
                }
            } else {
                VStack{
                    EmptyMyData(
                        text: String.pageText.myAlramEmpty,
                        tip : String.pageText.myAlramEmptyTip)
                    if !self.isPush {
                        FillButton(
                            text: String.button.alramOn,
                            size: Dimen.button.regular
                        ){ _ in
                            if self.pairing.status != .pairing {
                                self.appSceneObserver.alert = .needPairing()
                                return
                            }
                            self.dataProvider.requestData(q: .init(type: .updateAgreement(true)))
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .modifier(ListRowInset(marginHorizontal:Dimen.margin.heavy ,spacing: 0))
                .modifier(PageBody())
            }
        }
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            switch res.type {
            case .updateAgreement(let isAgree) : self.onUpdatedPush(res, isAgree: isAgree)
            default: do{}
            }
        }
        .onReceive(self.sceneObserver.$isUpdated){ update in
            if !update {return}
            self.horizontalMargin
                = self.sceneObserver.sceneOrientation == .portrait ? Dimen.margin.thin : Dimen.margin.heavy
        }
        .onAppear(){
            self.isPush = self.pairing.user?.isAgree3 ?? false
            self.horizontalMargin
                = self.sceneObserver.sceneOrientation == .portrait ? Dimen.margin.thin : Dimen.margin.heavy
        }
       
    }//body
    private func onUpdatedPush(_ res:ApiResultResponds, isAgree:Bool){
        guard let data = res.data as? NpsResult  else { return onUpdatePushError() }
        guard let resultCode = data.header?.result else { return onUpdatePushError() }
        if resultCode == NpsNetwork.resultCode.success.code {
            self.repository.updatePush(isAgree)
            self.isPush = isAgree
            self.appSceneObserver.event = .toast(
                isAgree ? String.alert.pushOn : String.alert.pushOff
            )
        } else {
            onUpdatePushError()
        }
    }
    private func onUpdatePushError(){
        self.appSceneObserver.event = .toast( String.alert.pushError )
    }
}

extension AlramItem{
    static let titleSize:CGFloat = Font.size.light
    static let textSize:CGFloat = Font.size.thin
    
    static let titleLineNum:Int = 3
    static let textLineNum:Int = 1
}


struct AlramItem: PageView {
    
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    var data:AlramData
    @State var needExpand = false
    @State var isExpand = false
    @State var isRead = false
    var body: some View {
        HStack(spacing:0){
            Circle()
                .fill(self.isRead ? Color.app.blueLight : Color.brand.primary )
                .frame(width: Dimen.icon.microExtra, height:Dimen.icon.microExtra)
                .padding(.horizontal, Dimen.margin.tiny)
            
            if let icon = self.data.landingType.getIcon() {
                Image(icon)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: Dimen.icon.tiny)
                    .padding(.trailing, Dimen.margin.mediumExtra)
                    .opacity(self.isRead ? 0.5 : 1.0)
            }
            VStack(alignment: .leading ,spacing:Dimen.margin.thin){
                VStack(alignment: .leading ,spacing:Dimen.margin.micro){
                    if let title = self.data.title {
                        Text(title)
                            .modifier(BoldTextStyle(
                                        size: Self.titleSize,
                                        color: self.isRead ? Color.app.grey : Color.app.white))
                            .lineLimit(self.isExpand ? 999 : Self.titleLineNum)
                    }
                    if let text = self.data.text {
                        Text(text)
                            .modifier(MediumTextStyle(
                                        size: Self.textSize,
                                        color: self.isRead ? Color.app.grey : Color.app.white))
                            .lineLimit(self.isExpand ? 999 : Self.textLineNum)
                    }
                }
                if self.isExpand , let image = self.data.image  {
                    KFImage(URL(string: image))
                        .resizable()
                        .placeholder {
                            Image(Asset.noImg9_16).resizable()
                        }
                        .cancelOnDisappear(true)
                        .loadImmediately()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: ListItem.alram.height, alignment:.topLeading)
                }
                if let date = self.data.date {
                    Text(date)
                        .modifier(MediumTextStyle(size: Font.size.thin, color: Color.app.grey))
                }
                
            }
            Spacer()
            if self.needExpand {
                Button(action: {
                    withAnimation{ self.isExpand.toggle() }
                    self.data.isExpand = self.isExpand
                    if !self.isRead { self.read() }
                }) {
                    Image(Asset.icon.down)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
                        .rotationEffect(.degrees(self.isExpand ? 180 : 0))
                        .padding(.horizontal, Dimen.margin.light)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .padding(.vertical, Dimen.margin.thin)
        .background(Color.app.blueLight)
        .onTapGesture {
            if !self.isRead { self.read() }
            
            if let move = data.move {
                switch move {
                case .home, .category:
                    var findBand:Band? = nil
                    if let gnbTypCd = data.moveData?[PageParam.id] as? String {
                        findBand = dataProvider.bands.getData(gnbTypCd: gnbTypCd)
                    }else if let menuId = data.moveData?[PageParam.data] as? String {
                        findBand = dataProvider.bands.getData(menuId: menuId)
                    }
                    guard let band = findBand else { return }
                    self.pagePresenter.changePage(
                        PageProvider
                            .getPageObject(move)
                            .addParam(params: data.moveData)
                            .addParam(key: .id, value: band.menuId)
                            .addParam(key: UUID().uuidString , value: "")
                    )
                    
                default :
                    let pageObj = PageProvider.getPageObject(move)
                    pageObj.params = data.moveData
                    self.pagePresenter.openPopup(pageObj)
                }
            }
            else if let link = data.outLink {
                AppUtil.openURL(link)
            }
            
            if let link = data.inLink {
                self.pagePresenter.openPopup(
                    PageProvider
                        .getPageObject(.webview)
                        .addParam(key: .data, value: link)
                        .addParam(key: .title , value: data.title)
                )
            }
        }
        .onReceive(self.sceneObserver.$isUpdated){ update in
            if !update {return}
            self.checkExpand()
            
        }
        .onAppear{
            self.isRead = self.data.isRead
            self.isExpand = self.data.isExpand
            self.checkExpand()
        }
    }
    
    private func read(){
        self.isRead = true
        self.data.isRead = true
        if !self.data.isCoreData { return }
        NotificationCoreData().readNotice(title: data.title ?? "", body: data.text ?? "")
    }
    
    private func checkExpand() {
        if self.data.image != nil {
            self.needExpand = true
            return
        }
        let horizontalMargin = self.sceneObserver.sceneOrientation == .portrait ? Dimen.margin.thin : Dimen.margin.heavy
        if let title = self.data.title{
            let lineHeight = title.textHeightFrom(
                width: self.sceneObserver.screenSize.width - (horizontalMargin * 2),
                fontSize: Self.titleSize )
            
            let lineNum:Int = Int(round(lineHeight / Self.titleSize))
            if lineNum > Self.titleLineNum {
                self.needExpand = true
                return
            }
        }
        if let text = self.data.text {
            let lineHeight = text.textHeightFrom(
                width: self.sceneObserver.screenSize.width - (horizontalMargin * 2),
                fontSize: Self.textSize )
            let lineNum:Int = Int(round(lineHeight / Self.titleSize))
            if lineNum > Self.textLineNum {
                self.needExpand = true
                return
            }
        }
    }
}

#if DEBUG
struct AlramList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            AlramList( datas: [
                AlramData().setDummy(),
                AlramData().setDummy(),
                AlramData().setDummy(),
                AlramData().setDummy()
            ])
            .environmentObject(Repository())
            .environmentObject(PagePresenter())
            .environmentObject(PageSceneObserver())
            .environmentObject(AppSceneObserver())
            .environmentObject(DataProvider())
            .environmentObject(Pairing())
            .frame(width:320,height:600)
            .background(Color.brand.bg)
        }
    }
}
#endif

