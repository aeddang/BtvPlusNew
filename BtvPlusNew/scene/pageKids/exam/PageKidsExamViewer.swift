//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI


struct PageKidsExamViewer: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var viewModel:KidsExamModel = KidsExamModel(type: .view)
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
   
   
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                ZStack(alignment: .top){
                    VStack (alignment: .center, spacing:0){
                        ExamBody(
                            viewModel:self.viewModel,
                            type:self.type,
                            isView: true
                        )
                        .modifier(MatchParent())
                    }
                    .padding(.top, DimenKids.app.pageTop)
                    PageKidsTab(
                        title:self.title,
                        titleTip: self.titleTip,
                        titleTipColor: self.titleTopColor,
                        isBack: false,
                        isClose: true,
                        style: .kidsClear)
                    
                }
                .modifier(PageFullScreen(style:.kids))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
              
            }//draging
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.initPage()
                }
            }
            .onReceive(self.viewModel.$event){evt in
                switch evt {
                case .quest(_ , let question ) :
                    withAnimation{
                        self.titleTip = question.targetType.name
                        self.titleTopColor = question.targetType.color
                    }
                case .complete :
                    self.pagePresenter.closePopup(self.pageObject?.id)
                default : break
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let type = obj.getParamValue(key: .type) as? DiagnosticReportType {
                    self.type = type
                }
                if let value = obj.getParamValue(key: .title) as? String {
                    self.examTitle = value
                }
                if let value = obj.getParamValue(key: .datas) as? [QuestionData] {
                    self.datas = value
                }
                
            }
        }//geo
    }//body
    
    @State var examTitle:String? = nil
    @State var type:DiagnosticReportType = .english
    @State var datas:[QuestionData] = []
   
    @State var title:String = ""
    @State var titleTip:String? = nil
    @State var titleTopColor:Color = Color.app.sepia
    
    private func initPage(){
        self.viewModel.setData(title:self.examTitle, questions: self.datas, reportType: self.type)
        self.title = self.viewModel.title ?? ""
        self.viewModel.start()
    }
}

#if DEBUG
struct PageKidsExamViewer_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            PageKidsExamViewer().contentBody
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
