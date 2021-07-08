//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI


struct PageKidsExam: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
   
  
    @State var isPairing:Bool = false
   
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                ZStack(alignment: .top){
                    VStack (alignment: .center, spacing:0){
                        if self.isPairing {
                            if self.isError {
                                ErrorKidsData()
                                    .modifier(MatchParent())
                            } else {
                                ExamBody()
                                    .modifier(MatchParent())
        
                            }
                            
                        } else {
                            NeedPairingInfo(
                                title: String.kidsText.kidsMyNeedPairing,
                                text: String.kidsText.kidsMyNeedPairingSub)
                                .modifier(MatchParent())
                        }
                        
                    }
                    .padding(.top, DimenKids.app.pageTop)
                    PageKidsTab(
                        title:String.kidsTitle.kidsMy,
                        isBack: false,
                        isClose: true,
                        style: .kidsClear)
                }
                .background(
                    Image(AssetKids.image.homeBg)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFill()
                        .modifier(MatchParent())
                        .opacity(self.isPairing ? 0 : 1)
                )
                .modifier(PageFullScreen(style:.kids))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
              
            }//draging
            .onReceive(self.pairing.$status){status in
                self.isPairing = ( status == .pairing )
            }
            .onReceive(self.pairing.$kid){ kid in
                self.kid = kid ?? Kid()
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.initPage()
                }
            }
            .onReceive(dataProvider.$result) { res in
                guard let res = res else { return }
                switch res.type {
                case .getEnglishLvReportExam, .getReadingReportExam,  .getCreativeReportExam :
                    guard let exams  = res.data as? KidsExams else { return }
                    self.setupExam(exams)
                default: break
                }
            }
            .onReceive(dataProvider.$error) { err in
                guard let err = err else { return }
                switch err.type {
                case .getEnglishLvReportExam, .getReadingReportExam,  .getCreativeReportExam :
                    self.isError = true
                default: break
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let type = obj.getParamValue(key: .type) as? DiagnosticReportType {
                    self.type = type
                }
                if let value = obj.getParamValue(key: .id) as? String {
                    self.value = value
                }
                
            }
        }//geo
    }//body
    
    @State var kid:Kid = Kid()
    @State var type:DiagnosticReportType = .english
    @State var value:String? = nil
    @State var isError:Bool = false
    
    private func initPage(){
        self.isError = false
        switch self.type {
        case .english:
            self.dataProvider.requestData(q: .init(type: .getEnglishLvReportExam(kid, target: value)))
        case .infantDevelopment:
            self.dataProvider.requestData(q: .init(type: .getReadingReportExam(kid, area: value)))
        case .creativeObservation:
            self.dataProvider.requestData(q: .init(type: .getCreativeReportExam(kid)))
        }
        
    }
    
    private func setupExam(_ data:KidsExams){
        guard let exam  = data.contents else {
            self.isError = true
            return
        }
        
    }
    
}

#if DEBUG
struct PageKidsExam_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            PageKidsExam().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(DataProvider())
                .environmentObject(Pairing())
                .frame(width: 360, height: 680, alignment: .center)
        }
    }
}
#endif
