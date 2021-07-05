import Foundation
import SwiftUI

struct PagePairingGuide: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var viewModel:ViewPagerModel = ViewPagerModel()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    let datas: [GuideViewData] = [
        GuideViewData(
            img: Asset.image.pairingTutorial01,
            title: nil,
            text: String.pageText.pairingGuideText1,
            info: String.pageText.pairingGuideInfo1,
            margin: Dimen.margin.regular,
            textHorizontal: String.pageText.pairingGuideText1Horizontal
            ),
        GuideViewData(
            img: Asset.image.pairingTutorial02,
            title: String.pageText.pairingGuideTitle2,
            text: String.pageText.pairingGuideText2,
            info: String.pageText.pairingGuideInfo2,
            titleHorizontal: String.pageText.pairingGuideTitle2Horizontal
            ),
        GuideViewData(
            img: Asset.image.pairingTutorial03,
            title: String.pageText.pairingGuideTitle3,
            text: String.pageText.pairingGuideText3,
            info: String.pageText.pairingGuideInfo3,
            titleHorizontal: String.pageText.pairingGuideTitle3Horizontal),
        GuideViewData(
            img: Asset.image.pairingTutorial04,
            title:String.pageText.pairingGuideTitle4,
            text: String.pageText.pairingGuideText4,
            info: String.pageText.pairingGuideInfo4,
            titleHorizontal: String.pageText.pairingGuideTitle4Horizontal
            )
    ]
    
    @State var pages: [PageViewProtocol] = []
    @State var index: Int = 0
    @State var leading:CGFloat = 0
    @State var trailing:CGFloat = 0
   
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(alignment: .leading, spacing: 0){
                    PageTab(
                        title: String.pageTitle.pairingGuide,
                        isClose: true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    CPPageViewPager(
                        pageObservable: self.pageObservable,
                        viewModel: self.viewModel,
                        pages: self.pages,
                        usePull: .vertical
                        )
                        
                    if self.pages.count > 1 {
                        HStack(spacing: 0) {
                            Text((self.index+1).description.toFixLength(2))
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
                    
                }
                .padding(.vertical, Dimen.margin.regular)
                .modifier(PageFull())
                .modifier(PageDragingSecondPriority(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }
            .onReceive(self.viewModel.$event){evt in
                guard let evt = evt else {return}
                switch evt {
                case .pullCompleted:
                    self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                case .pullCancel :
                    self.pageDragingModel.uiEvent = .pullCancel(geometry)
                case .pull(let pos) :
                    self.pageDragingModel.uiEvent = .pull(geometry, pos)
                }
            }
            .onReceive( self.viewModel.$index ){ idx in
                self.setBar(idx:idx)
            }
            .onAppear{
                self.pages = self.datas.map{
                    GuideView(data: $0)
                }
                self.setBar(idx:self.viewModel.index)
            }
        }//geo
    }//body
    
    private func setBar(idx:Int){
        let count = self.pages.count
        let size = Dimen.bar.regular
        self.index = idx
        let cidx = idx + 1
        withAnimation{
            self.leading = size * CGFloat(cidx)
            self.trailing = size * CGFloat(count - cidx)
        }
    }
    
}


#if DEBUG
struct PagePairingGuide_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePairingGuide().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(Repository())
                .frame(width: 325, height: 640, alignment: .center)
        }
    }
}
#endif

