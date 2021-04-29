//
//  CharacterSelectBox.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2021/01/04.
//

import Foundation
import SwiftUI
struct PairingView: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    
    var pageObservable:PageObservable = PageObservable()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var watchedScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    @State var safeAreaBottom:CGFloat = 0
    @State var character:String = Asset.characterList[0]
    @State var nick:String = ""
    
    var body: some View {
        VStack (alignment: .center, spacing:0){
            VStack (alignment: .center, spacing: Dimen.margin.lightExtra){
                ZStack (alignment: .bottom){
                    Image(self.character)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.bottom, Dimen.margin.tiny)
                        .frame(width: Dimen.item.profile.width, height: Dimen.item.profile.height)
                    
                    Text(String.pageText.myPairing)
                        .modifier(MediumTextStyle(size: Font.size.tinyExtra, color: Color.app.white))
                        .padding(.horizontal, Dimen.margin.thin)
                        .frame(height:Dimen.button.thin)
                        .background(Color.brand.primary)
                        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.regularExtra))
                }
                TextButton(
                    defaultText: self.nick,
                    textModifier: TextModifier( family: Font.family.medium,
                        size: Font.size.mediumExtra, color:Color.app.white),
                    image: Asset.icon.profileEdit,
                    imageSize: Dimen.icon.thinExtra
                ) { _ in
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.modifyProile)
                        )
                    }
                TextButton(
                    defaultText: String.pageTitle.pairingManagement,
                    textModifier: TextModifier( family: Font.family.medium,
                        size: Font.size.thinExtra, color:Color.app.greyLight),
                    image: Asset.icon.more) { _ in
                     
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.pairingManagement)
                        )
                    }
            }
            .modifier(ContentHorizontalEdgesTablet())
            HStack(spacing: 0){
                FillButton(
                    text: String.button.alarm,
                    image: Asset.icon.alarm,
                    isNew: true
                ){_ in
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.myAlram)
                    )
                }
                Spacer().modifier(LineVertical())
                    .frame(height:Dimen.button.lightExtra)
                FillButton(
                    text: String.button.notice,
                    image: Asset.icon.notice,
                    isNew: true
                ){_ in
                    self.pagePresenter.openPopup(
                        PageProvider
                            .getPageObject(.webview)
                            .addParam(key: .data, value: BtvWebView.notice)
                            .addParam(key: .title , value: String.button.notice)
                    )
                }
            }
            .background(Color.app.blueLight)
            .modifier(ContentHorizontalEdgesTablet())
            .padding(.top, Dimen.margin.regular)
            MyPointInfo()
                .modifier(ContentHorizontalEdgesTablet())
                .padding(.top, Dimen.margin.regularExtra)
            if let data = self.watchedData {
                if SystemEnvironment.isTablet {
                    VideoSetBlock(
                        pageObservable: self.pageObservable,
                        data: data)
                        .padding(.top, Dimen.margin.medium)
                } else {
                    VideoBlock(
                        pageObservable:self.pageObservable,
                        viewModel:self.watchedScrollModel,
                        pageDragingModel:self.pageDragingModel,
                        data: data,
                        margin:SystemEnvironment.isTablet ? Dimen.margin.heavy : Dimen.margin.thin ,
                        useTracking:true)
                        .padding(.top, Dimen.margin.medium)
                }
            }
            if self.isCompleted {
                VStack (alignment: .center, spacing: 0){
                    Spacer().modifier(LineHorizontal())
                    FillButton(
                        text: String.pageTitle.bookmarkList,
                        isMore: true
                    ){_ in
                        
                        let blockData = BlockData()
                            .setData(title: String.pageTitle.bookmarkList, cardType:.bookmarkedPoster, dataType:.bookMark, uiType:.poster)
                        
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.categoryList)
                                .addParam(key: .data, value: blockData)
                        )
                    }
        
                    Spacer().modifier(LineHorizontal())
                    FillButton(
                        text: String.pageTitle.purchaseList,
                        isMore: true
                    ){_ in
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.myPurchase)
                        )
                    }
                    
                    FillButton(
                        text: String.pageText.myRegistPictureFammly,
                        isMore: false,
                        icon: Asset.icon.btvlite,
                        bgColor : Color.app.blueLight
                    ){_ in
                        
                        AppUtil.openURL(ApiPath.getRestApiPath(.WEB) + BtvWebView.happySenior)
                    }
                }
                .modifier(ContentHorizontalEdgesTablet())
                .padding(.top, Dimen.margin.medium)
            }
        }
        .padding(.top, Dimen.margin.light)
        .padding(.bottom, Dimen.margin.thin + self.safeAreaBottom)
        .background(Color.brand.bg)
    
        .onReceive(self.pairing.$user){ user in
            guard let user = user else {return}
            self.character = Asset.characterList[user.characterIdx]
            self.nick = user.nickName
        }
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else {return}
            switch res.type {
            case .getWatch : self.onWatchedData(res: res)
            default : break
            }
        }
        .onReceive(self.dataProvider.$error){ err in
            guard let err = err else {return}
            switch err.type {
            case .getWatch : withAnimation{ self.isCompleted = true }
            default : break
            }
        }
        .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
            withAnimation{
                self.safeAreaBottom = pos
            }
        }
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            if ani {
                self.dataProvider.requestData(q: .init(type: .getWatch(false), isOptional: true))
            }
        }
        
    }//body
    
    @State var isCompleted:Bool = false
    @State var watchedData:BlockData? = nil
    func onWatchedData(res:ApiResultResponds){
        guard let resData = res.data as? Watch else { return }
        let blocks:[WatchItem] = resData.watchList ?? [] 
        //if blocks.isEmpty { return }
        let videos = blocks.map{ d in VideoData().setData(data: d) }
        let blockData = BlockData()
            .setData(title: String.pageTitle.watched, cardType:.watchedVideo, dataType:.watched, uiType:.video, isCountView: true)
        blockData.videos = videos
        blockData.setDatabindingCompleted(total: resData.watch_tot?.toInt() ?? 0)
        self.watchedData = blockData
        withAnimation{ self.isCompleted = true }
    }
    
    
    
}


#if DEBUG
struct PairingBlock_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            PairingView(
            )
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Pairing())
                .frame(width:320,height:600)
                .background(Color.brand.bg)
        }
    }
}
#endif
