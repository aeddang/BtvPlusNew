//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//
import Foundation
import SwiftUI

struct IntroItem: PageComponent, Identifiable {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    let id = UUID().uuidString
    let title:String
    let text:String
    let titleHorizontal:String
    let textHorizontal:String
    let asset: String
    
    @State var sceneOrientation: SceneOrientation = .portrait
    var body: some View {
        ZStack{
            if self.sceneOrientation == .portrait {
                VStack(alignment: .leading, spacing: 0){
                    Spacer().modifier(MatchHorizontal(height: 0))
                    Text(self.title)
                        .modifier(BoldTextStyle(size: Font.size.boldExtra, color: Color.app.white))
                        .padding(.top, Dimen.margin.heavyExtra)
                        .padding(.leading, Dimen.margin.regular)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(self.text)
                        .modifier(MediumTextStyle(size: Font.size.lightExtra, color: Color.app.greyMedium))
                        .padding(.top, Dimen.margin.thin)
                        .padding(.leading, Dimen.margin.regular)
                        .fixedSize(horizontal: false, vertical: true)
                    Image(asset)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            } else {
                HStack(alignment: .top, spacing: 0){
                    VStack(alignment: .leading, spacing: 0){
                        Text(self.titleHorizontal)
                            .modifier(BoldTextStyle(size: Font.size.boldExtra, color: Color.app.white))
                            .padding(.top, Dimen.margin.heavyExtra)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(self.textHorizontal)
                            .modifier(MediumTextStyle(size: Font.size.lightExtra, color: Color.app.greyMedium))
                            .padding(.top, Dimen.margin.thin)
                            .fixedSize(horizontal: false, vertical: true)
                        
                    }
                    .padding(.leading, Dimen.margin.regular)
                    Image(asset)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
               
            }
        }
        .onReceive(self.sceneObserver.$isUpdated){ _ in
            self.sceneOrientation = self.sceneObserver.sceneOrientation
        }
        .onAppear{
            self.sceneOrientation = self.sceneObserver.sceneOrientation
        }
    }
}


struct PageIntro: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var naviLogManager:NaviLogManager
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var viewModel:ViewPagerModel = ViewPagerModel()
    let pages: [PageViewProtocol] = SystemEnvironment.isTablet ? [
        IntroItem(title: String.pageText.introTitle1, text: String.pageText.introText1,
                  titleHorizontal: String.pageText.introTitleHorizontal1,
                  textHorizontal: String.pageText.introTextHorizontal1,
                  asset:  Asset.image.introT01),
        IntroItem(title: String.pageText.introTitle2, text: String.pageText.introText2,
                  titleHorizontal: String.pageText.introTitleHorizontal2,
                  textHorizontal: String.pageText.introTextHorizontal2,
                  asset:  Asset.image.introT02),
        IntroItem(title: String.pageText.introTitle3, text: String.pageText.introText3,
                  titleHorizontal: String.pageText.introTitleHorizontal3,
                  textHorizontal: String.pageText.introTextHorizontal3,
                  asset:  Asset.image.introT03),
        IntroItem(title: String.pageText.introTitle4, text: String.pageText.introText4,
                  titleHorizontal: String.pageText.introTitleHorizontal4,
                  textHorizontal: String.pageText.introTextHorizontal4,
                  asset:  Asset.image.introT04)
    ] :
    [
        ResourceItem(asset: Asset.image.intro01),
        ResourceItem(asset: Asset.image.intro02),
        ResourceItem(asset: Asset.image.intro03),
        ResourceItem(asset: Asset.image.intro04)
    ]
    @State var index: Int = 0
    @State var leading:CGFloat = 0
    @State var trailing:CGFloat = 0
    @State var posStr:String = ""
    @State var sceneOrientation: SceneOrientation = .portrait
    var body: some View {
        VStack(alignment: self.sceneOrientation == .portrait ? .center : .leading, spacing: 0){
            CPImageViewPager(
                viewModel : self.viewModel,
                pages: self.pages
                )
            if self.pages.count > 1 {
                HStack(spacing: 0) {
                    Text(self.posStr)
                        .modifier(NumberMediumTextStyle(size: Font.size.lightExtra, color: Color.brand.primary))
                        .fixedSize(horizontal: true, vertical: true)
                    HStack(spacing: 0) {
                        Spacer()
                            .modifier(MatchVertical(width:self.leading))
                            .background(Color.brand.primary)
                            .fixedSize(horizontal: true, vertical: false)
                        Spacer()
                            .modifier(MatchVertical(width:self.trailing))
                            .background(Color.transparent.white20)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    .frame( height: Dimen.line.regular)
                    .padding(.horizontal, Dimen.margin.tiny)
                    Text((self.pages.count).description.toFixLength(2))
                        .modifier(NumberMediumTextStyle(size: Font.size.lightExtra, color: Color.app.greyLight))
                    
                }
                .padding(.horizontal, Dimen.margin.regular)
                .frame( height:70)
            }
            if self.index < (self.pages.count - 1) {
                FillButton(
                    text: String.button.skip,
                    isSelected: true
                ){_ in
                    self.naviLogManager.actionLog(.clickGuideSkip, actionBody:.init(config:self.posStr))
                    self.appSceneObserver.event = .initate
                }
            } else {
                HStack(spacing: 0) {
                    FillButton(
                        text: String.button.home,
                        isSelected: true,
                        bgColor:Color.app.blueLightExtra
                    ){_ in
                        
                        self.naviLogManager.actionLog(
                            .clickGuideSkip, actionBody:.init(config:self.posStr, category:"바로시작하기"))
                        self.appSceneObserver.event = .initate
                    }
                    
                    FillButton(
                        text: String.button.appInit,
                        isSelected: true
                    ){_ in
                        self.naviLogManager.actionLog(
                            .clickGuideSkip, actionBody:.init(config:self.posStr, category:"B tv 연결하기"))
                        self.appSceneObserver.event = .initate
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1){
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.pairing)
                                    .addParam(key: PageParam.subType, value: "mob-my")
                            )
                        }
                    }
                }
            }
        }
        .padding(.vertical, Dimen.margin.regular)
        .modifier(PageFull())
        .onReceive( self.viewModel.$index ){ idx in
            self.setBar(idx:idx)
        }
        .onReceive(self.sceneObserver.$isUpdated){ _ in
            self.sceneOrientation = self.sceneObserver.sceneOrientation
        }
        .onAppear{
           // self.setBar(idx:self.index)
        }
        
    }//body
    
    private func setBar(idx:Int){
        let count = self.pages.count
        let size = SystemEnvironment.isTablet ? Dimen.bar.medium : Dimen.bar.regular
        self.index = idx
        let cidx = idx + 1
        self.posStr = (self.index+1).description.toFixLength(2)
        withAnimation{
            self.leading = size * CGFloat(cidx)
            self.trailing = size * CGFloat(count - cidx)
        }
    }
    
}


#if DEBUG
struct PageIntro_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageIntro().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(Repository())
                .frame(width: 325, height: 640, alignment: .center)
        }
    }
}
#endif

